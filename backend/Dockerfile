FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY pyproject.toml ./
COPY uspace_api ./uspace_api
RUN pip install --no-cache-dir .
RUN useradd --uid 10001 --create-home appuser
USER appuser
EXPOSE 8000
CMD ["uvicorn", "uspace_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
