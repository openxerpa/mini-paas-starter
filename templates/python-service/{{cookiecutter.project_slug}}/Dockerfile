FROM python:3.13-slim
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY src/ ./src/
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt 2>/dev/null || true
USER app
EXPOSE {{ cookiecutter.service_port }}
CMD ["python", "-m", "src.main"]
