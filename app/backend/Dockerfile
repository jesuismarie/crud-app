FROM python:3.12-slim

WORKDIR /app
RUN useradd --create-home --uid 10001 appuser

COPY --chown=appuser:appuser ./app/ ./app
COPY --chown=appuser:appuser ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "60", "app.wsgi:app"]
