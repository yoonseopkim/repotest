import discord
from discord import commands

# FastAPI 앱 생성
app = FastAPI()

# Discord 봇 설정
intents = discord.Intents.default()
intents.message_content = True

class SentryBot(commands.Bot):
    def __init__(self):
        super().__init__(
            command_prefix="/",                              # 명령어 접두사 설정
            intents=intents.all(),                           # 모든 권한 활성화
            sync_command=True,
            application_id=settings.DISCORD_SENTRY_BOT_ID    # 봇 ID
        )

    async def setup_hook(self):
        await bot.tree.sync()

    async def on_ready(self):
        print("Bot online")
        activity = discord.Game("Sentry 감시 중")
        await self.change_presence(status=discord.Status.online, activity=activity)

    @command.command(name="status")
    async def ping(self, ctx: commands.Context) -> None:
        await ctx.send("봇 작동 중")

bot = SentryBot()
bot.run(settings.DISCORD_SENTRY_TOKEN)