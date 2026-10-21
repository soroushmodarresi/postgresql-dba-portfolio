FROM postgres:16
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-pip curl \
 && pip3 install --no-cache-dir --break-system-packages "patroni[etcd3]" psycopg2-binary \
 && rm -rf /var/lib/apt/lists/*
USER postgres
ENTRYPOINT ["patroni", "/etc/patroni.yml"]
