# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Run stage — listen on fixed 8080 (matches Railway public port)
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.default.conf /etc/nginx/nginx.default.conf
COPY start-nginx.sh /start-nginx.sh
RUN sed -i 's/\r$//' /start-nginx.sh && chmod +x /start-nginx.sh \
  && rm -f /etc/nginx/conf.d/default.conf

EXPOSE 80 8080
ENTRYPOINT ["/start-nginx.sh"]
