# Build stage
FROM ghcr.io/astral-sh/uv:python3.14-alpine AS builder
WORKDIR /app
COPY requirements.txt ./
RUN uv pip install --no-cache -r requirements.txt --target /app/packages

# Runtime stage
FROM gcr.io/distroless/python3-debian13:nonroot
WORKDIR /app
ENV PYTHONPATH=/app/packages
COPY --from=builder /app/packages /app/packages
COPY src/ ./src/
EXPOSE {{ cookiecutter.service_port }}
CMD ["-m", "src.main"]
