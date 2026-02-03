#!/bin/sh\nset -e\n\nDEFAULT_ORIGIN="${ORIGIN:-${RENDER_EXTERNAL_URL:-}}"
if [ -z "$DEFAULT_ORIGIN" ] && [ -n "$RENDER_EXTERNAL_HOSTNAME" ]; then
  DEFAULT_ORIGIN="https://$RENDER_EXTERNAL_HOSTNAME"
fi
if [ -z "$DEFAULT_ORIGIN" ]; then
  DEFAULT_ORIGIN="https://eml-admintool.onrender.com"
fi

ALLOWED_ORIGINS="${ALLOWED_ORIGINS:-$DEFAULT_ORIGIN}"
ORIGIN="${ORIGIN:-$DEFAULT_ORIGIN}"
echo "рџ”§ Setting up environment variables..."\nif [ -n "$DATABASE_URL" ]; then\n  cat > /app/env/.env <<EOF\nIS_CONFIGURED="${IS_CONFIGURED:-false}"\nDATABASE_URL="${DATABASE_URL}"\nJWT_SECRET_KEY="${JWT_SECRET_KEY}"\nUPDATER_HTTP_API_TOKEN="${UPDATER_HTTP_API_TOKEN}"
ALLOWED_ORIGINS="${ALLOWED_ORIGINS}"
ORIGIN="${ORIGIN}"\nBODY_SIZE_LIMIT=${BODY_SIZE_LIMIT:-Infinity}\nEOF\nelse\n  if [ -f /app/env/.env ]; then\n    echo ".env file found."\n  else\n    echo ".env file not found, creating a new one."\n    cp /app/env/.env.default /app/env/.env\n  fi\nfi\n\nif [ ! -L /app/.env ]; then\n  echo "Creating symlink to .env file..."\n  ln -s /app/env/.env /app/.env\nelse\n  echo "Symlink to .env file already exists."\nfi\n\nset -a\n. /app/.env\nset +a\n\nDB_HOST="${DB_HOST:-$(echo "$DATABASE_URL" | sed -E 's|.*@([^:/?]+).*|\\1|')}"\nDB_PORT="${DB_PORT:-5432}"\n\necho "вЏі Waiting for database at $DB_HOST:$DB_PORT..."\nuntil nc -z "$DB_HOST" "$DB_PORT"; do\n  sleep 1\ndone\n\necho "вњ… Database available. Applying 'prisma db push'..."\nnpx dotenv -e /app/.env -- prisma db push\n\necho "рџљЂ Starting application"\nexec npm run serve\n\n\n