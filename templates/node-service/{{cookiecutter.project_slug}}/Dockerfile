# Build stage
FROM node:24-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --omit=dev
COPY . .

# Runtime stage
FROM gcr.io/distroless/nodejs24-debian13:nonroot
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./
EXPOSE {{ cookiecutter.service_port }}
CMD ["src/index.js"]
