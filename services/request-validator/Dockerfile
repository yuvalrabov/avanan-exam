FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt ./
COPY app.py ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV AWS_REGION=eu-north-1
ENV PORT=5000
ENV PARAMETER_NAME=ValidationToken

CMD ["python", "app.py"]
