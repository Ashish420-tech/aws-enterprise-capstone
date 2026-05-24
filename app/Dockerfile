FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip wheel && \
    pip install --no-cache-dir --upgrade jaraco.context && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd -r -u 10001 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
