## --- Build stage: compile Vue app with Vite ---
FROM node:20-alpine AS build

WORKDIR /app

# Install deps first (better cache)
COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./
RUN npm ci || npm install

# Copy sources
COPY . .

# Build production assets
RUN npm run build

## --- Runtime stage: serve static via Nginx ---
FROM nginx:alpine AS runtime

# Copy custom nginx config (SPA fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


