FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
# why we doing it like that and not wit specific name
COPY . . 

CMD ["python", "app.py"]
