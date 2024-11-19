FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

RUN chmod +x bot.py

EXPOSE 8000

CMD ["python", "bot.py"]