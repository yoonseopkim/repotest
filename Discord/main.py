import discord
from discord.ext import commands
from fastapi import FastAPI, Request
import uvicorn
from datetime import datetime, timezone
from settings import settings
import asyncio
from hypercorn.asyncio import serve
from hypercorn.config import Config

# FastAPI 앱 생성
app = FastAPI()

# Discord 봇 설정
intents = discord.Intents.default()
bot = commands.Bot(command_prefix="!", intents=intents)

# Discord 채널 객체를 저장할 변수
notification_channel = None

@bot.event
async def on_ready():
    global notification_channel
    print(f"Bot is ready as {bot.user}")
    notification_channel = bot.get_channel(settings.DISCORD_CHANNEL_ID)
    if not notification_channel:
        print(f"Warning: Could not find channel with ID {settings.DISCORD_CHANNEL_ID}")

def create_error_embed(webhook_data):
    """Sentry 웹훅 데이터로부터 Discord 임베드 생성"""
    event = webhook_data.get("data", {}).get("event", {})
    
    # 기본 정보 추출
    error_title = event.get("title", "Unknown Error")
    project = event.get("project", "Unknown Project")
    environment = event.get("environment", "Unknown Environment")
    level = event.get("level", "error")
    
    # 타임스탬프 처리
    timestamp_str = event.get("dateCreated")
    if timestamp_str:
        try:
            timestamp = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
        except:
            timestamp = datetime.now(timezone.utc)
    else:
        timestamp = datetime.now(timezone.utc)
    
    # 에러 상세 정보
    error_message = event.get("message", "No error message")
    exception = event.get("exception", {})
    if isinstance(exception, dict):
        exception_value = exception.get("values", [{}])[0].get("value", "No exception details")
    else:
        exception_value = "No exception details"

    # 임베드 생성
    embed = discord.Embed(
        title=f"🚨 {error_title}",
        description=f"```{error_message}```",
        color=discord.Color.red(),
        timestamp=timestamp
    )
    
    # 필드 추가
    embed.add_field(name="Project", value=project, inline=True)
    embed.add_field(name="Environment", value=environment, inline=True)
    embed.add_field(name="Level", value=level, inline=True)
    embed.add_field(name="Exception", value=f"```{exception_value}```", inline=False)
    
    # URL이 있다면 추가
    if "url" in webhook_data:
        embed.url = webhook_data["url"]
    
    return embed

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return notification_channel.send("관리자") # bot 스스로가 보낸 메세지는 무시
    if message.content.startswith("Hello"):
        await notification_channel.send("바보")

@app.post("/webhook/sentry-bot")
async def sentry_webhook(request: Request):
    """Sentry 웹훅 엔드포인트"""
    try:
        webhook_data = await request.json()
        
        # 알림 채널이 설정되어 있는지 확인
        if notification_channel is None:
            return {"status": "error", "message": "Discord channel not configured"}
        
        # 임베드 생성 및 전송
        embed = create_error_embed(webhook_data)
        await notification_channel.send(embed=embed)
        
        return {"status": "success"}
    except Exception as e:
        print(f"Error processing webhook: {e}")
        return {"status": "error", "message": str(e)}

# Discord 봇 명령어
@bot.command()
async def status(ctx):
    """봇 상태 확인 명령어"""
    await ctx.send("Sentry 모니터링 봇이 정상 작동 중입니다! 🟢")

def run_bot():
    """Discord 봇과 FastAPI 서버 실행"""
    # 실행
    print("run both")
    asyncio.run(start_both())
    
async def start_bot():
    print(f"Start bot")
    try:
        print(f"Start bot try")
        await bot.start(settings.DISCORD_TOKEN)
    except Exception as e:
        print(f"Bot error: {e}")

async def start_server():
    config = Config()
    config.bind = [f"{settings.HOST}:{settings.PORT}"]
    
    print(f"Start server")
    try:
        print(f"Start server at {settings.HOST}:{settings.PORT}")
        await serve(app, config)
    except Exception as e:
        print(f"Server error: {e}")

async def start_both():
    # create_task로 두 코루틴을 동시에 실행
    bot_task = asyncio.create_task(start_bot())
    server_task = asyncio.create_task(start_server())
    
    try:
        # 둘 중 하나라도 완료될 때까지 대기
        done, pending = await asyncio.wait(
            [bot_task, server_task],
            return_when=asyncio.FIRST_COMPLETED
        )
        
        # 에러 체크
        for task in done:
            try:
                await task
            except Exception as e:
                print(f"Task failed with error: {e}")
                
    finally:
        # 남은 태스크들 정리
        for task in pending:
            task.cancel()
        
        # 취소된 태스크들이 정리될 때까지 대기
        await asyncio.gather(*pending, return_exceptions=True)

if __name__ == "__main__":
    print("run main")
    run_bot()