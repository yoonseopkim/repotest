FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

RUN chmod +x main.py

EXPOSE 8000

CMD ["python", "main.py"]