#!/bin/sh
set -e

echo "🔧 Setting up environment variables..."
if [ -n "$DATABASE_URL" ]; then
  cat > /app/env/.env <<EOF
IS_CONFIGURED="${IS_CONFIGURED:-false}"
DATABASE_URL="${DATABASE_URL}"
JWT_SECRET_KEY="${JWT_SECRET_KEY}"
UPDATER_HTTP_API_TOKEN="${UPDATER_HTTP_API_TOKEN}"
BODY_SIZE_LIMIT=${BODY_SIZE_LIMIT:-Infinity}
EOF
else
  if [ -f /app/env/.env ]; then
    echo ".env file found."
  else
    echo ".env file not found, creating a new one."
    cp /app/env/.env.default /app/env/.env
  fi
fi

if [ ! -L /app/.env ]; then
  echo "Creating symlink to .env file..."
  ln -s /app/env/.env /app/.env
else
  echo "Symlink to .env file already exists."
fi

DB_HOST="${DB_HOST:-$(echo "$DATABASE_URL" | sed -E 's|.*@([^:/?]+).*|\\1|')}"
DB_PORT="${DB_PORT:-5432}"

echo "⏳ Waiting for database at $DB_HOST:$DB_PORT..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 1
done

echo "✅ Database available. Applying 'prisma db push'..."
npx dotenv -e /app/.env -- prisma db push

echo "🚀 Starting application"
exec npm run serve
