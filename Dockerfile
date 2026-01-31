# Etapa 1: Build automático do app Vue (sem você precisar rodar nada)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json yarn.lock* ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# Etapa 2: Servidor Nginx leve servindo os arquivos prontos
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html

# Config Nginx para Vue (rotas funcionam, sem erro 404 no refresh)
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html =404; \
    } \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 30d; \
        add_header Cache-Control "public"; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
