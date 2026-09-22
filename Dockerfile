FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependencies first so this layer is cached until requirements.txt changes.
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code last (it changes most often).
COPY app/ .

# Run as an unprivileged user with a numeric UID.
RUN useradd --create-home --uid 10001 appuser
USER 10001

EXPOSE 8000

# One worker with several threads: init_db() runs when a worker imports the app,
# and a single worker keeps that startup step simple.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "--threads", "4", "app:app"]