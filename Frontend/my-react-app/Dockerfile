# Build stage
FROM node:20-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Run stage — static site + optional API proxy
FROM nginx:alpine
RUN apk add --no-cache gettext

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY start-nginx.sh /start-nginx.sh
RUN chmod +x /start-nginx.sh && sed -i 's/\r$//' /start-nginx.sh

ENV PORT=8080
EXPOSE 8080

CMD ["/start-nginx.sh"]
