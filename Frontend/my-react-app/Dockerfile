# Build stage
FROM node:20-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Run stage
FROM nginx:alpine
RUN apk add --no-cache gettext

COPY --from=build /app/dist /usr/share/nginx/html
# Keep template OUT of /etc/nginx/templates so image entrypoint won't
# envsubst nginx vars like $host / $uri (that crashes the container).
COPY nginx.conf.template /etc/nginx/dayflow.conf.template
COPY start-nginx.sh /start-nginx.sh
RUN chmod +x /start-nginx.sh && sed -i 's/\r$//' /start-nginx.sh

ENV PORT=8080
EXPOSE 8080

# Bypass nginx docker-entrypoint template auto-processing
ENTRYPOINT ["/start-nginx.sh"]
