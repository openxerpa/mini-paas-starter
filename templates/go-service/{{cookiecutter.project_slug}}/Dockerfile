# Build stage
FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server
RUN CGO_ENABLED=0 go build -o /healthcheck ./cmd/healthcheck

# Runtime stage
FROM gcr.io/distroless/static-debian13:nonroot
COPY --from=builder /server /server
COPY --from=builder /healthcheck /healthcheck
EXPOSE {{ cookiecutter.service_port }}
ENTRYPOINT ["/server"]
