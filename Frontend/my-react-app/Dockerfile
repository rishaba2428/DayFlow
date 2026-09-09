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
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

ENV PORT=8080
ENV BACKEND_HOST=backend:8080

EXPOSE 8080

# Inline start avoids Windows CRLF breaking a separate shell script
CMD ["/bin/sh", "-c", "PORT=${PORT:-8080}; HOST=${BACKEND_HOST:-backend:8080}; HOST=${HOST#http://}; HOST=${HOST#https://}; export PORT HOST; envsubst '${PORT} ${HOST}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf; nginx -t && exec nginx -g 'daemon off;'"]
