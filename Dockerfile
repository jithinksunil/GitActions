FROM node:22.12.0-bullseye AS base
WORKDIR /app

# Install dependencies (uses package-lock if present)
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci --silent

# Build the app
FROM base AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build

# Production image
FROM node:22.12.0-bullseye-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

CMD ["node", "server.js"]
