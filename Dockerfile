ARG BASETAG=latest
FROM postgres:$BASETAG

ARG GOCRONVER=v0.0.8
ARG TARGETOS=linux
ARG TARGETARCH=amd64
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \ 
    curl \
    sendemail \
    libnet-ssleay-perl \
    libio-socket-ssl-perl \
  && rm -rf /var/lib/apt/lists/* \
  && curl -L https://github.com/prodrigestivill/go-cron/releases/download/$GOCRONVER/go-cron-$TARGETOS-$TARGETARCH.gz | zcat > /usr/local/bin/go-cron \
  && chmod a+x /usr/local/bin/go-cron \
  && apt-get purge -y --auto-remove ca-certificates \
  && apt-get clean

ENV POSTGRES_DB="**None**" \
    POSTGRES_DB_FILE="**None**" \
    POSTGRES_HOST="**None**" \
    POSTGRES_PORT=5432 \
    POSTGRES_USER="**None**" \
    POSTGRES_USER_FILE="**None**" \
    POSTGRES_PASSWORD="**None**" \
    POSTGRES_PASSWORD_FILE="**None**" \
    POSTGRES_EXTRA_OPTS="-Z9" \
    SCHEDULE="@daily" \
    BACKUP_DIR="/backups" \
    BACKUP_KEEP_DAYS=7 \
    BACKUP_KEEP_WEEKS=4 \
    BACKUP_KEEP_MONTHS=6 \
    HEALTHCHECK_PORT=8080 \
    MAIL_BACKUP="FALSE" \
    SMTP_SERVER="**None**" \
    SMTP_PORT="**None**" \
    MAIL_USER="**None**" \
    MAIL_PASSWORD="**None**" \    
    MAIL_FROM="**None**" \
    MAIL_TO="**None**" \
    MAIL_SUBJECT="**None**"


COPY backup.sh /backup.sh

VOLUME /backups

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["exec /usr/local/bin/go-cron -s \"$SCHEDULE\" -p \"$HEALTHCHECK_PORT\" -- /backup.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$HEALTHCHECK_PORT/" || exit 1
