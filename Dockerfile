FROM node:20-slim AS builder

WORKDIR /app

# Копируем файлы зависимостей
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Устанавливаем pnpm и зависимости
RUN npm install -g pnpm && pnpm install

# Копируем остальной код
COPY . .

# Собираем проект
RUN pnpm run build

# Финальный образ
FROM node:20-slim

WORKDIR /app

# Устанавливаем playwright и браузеры
RUN apt-get update && apt-get install -y \
    libnss3 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxkbcommon0 \
    libasound2 \
    libcups2 \
    && rm -rf /var/lib/apt/lists/*

# Копируем собранные файлы из билдера
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Устанавливаем переменные окружения
ENV NODE_ENV=production
ENV PORT=3000
ENV BROWSER_HEADLESS=true

# Открываем порт
EXPOSE 3000

# Запускаем приложение
CMD ["npm", "start"]
