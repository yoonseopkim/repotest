from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Discord 설정
    DISCORD_SENTRY_TOKEN: str
    DISCORD_SENTRY_BOT_ID: int
    DISCORD_SENTRY_CHANNEL_ID: int

    HOST: str
    PORT: int

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()