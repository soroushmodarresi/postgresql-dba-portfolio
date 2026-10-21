FROM postgres:16

RUN apt-get update \
 && apt-get install -y --no-install-recommends pgbackrest postgresql-16-pgaudit openssl \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/lib/pgbackrest /var/log/pgbackrest /etc/pgbackrest /etc/ssl/pgcerts

# Self-signed cert for the demo. Use a real CA in production.
RUN openssl req -new -x509 -days 365 -nodes -subj "/CN=postgres" \
      -keyout /etc/ssl/pgcerts/server.key -out /etc/ssl/pgcerts/server.crt \
 && chmod 600 /etc/ssl/pgcerts/server.key \
 && chown -R postgres:postgres /etc/ssl/pgcerts /var/lib/pgbackrest /var/log/pgbackrest

COPY pgbackrest.conf /etc/pgbackrest/pgbackrest.conf
COPY replica-entrypoint.sh /usr/local/bin/replica-entrypoint.sh
RUN chmod +x /usr/local/bin/replica-entrypoint.sh \
 && chown postgres:postgres /etc/pgbackrest/pgbackrest.conf
