# Build stage (stdlib-only: no deps, but keeps pattern for when teams add deps)
FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --omit=dev
COPY . .

# Runtime stage
FROM node:22-alpine
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./
USER nodejs
EXPOSE {{ cookiecutter.service_port }}
CMD ["npm", "start"]
