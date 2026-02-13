FROM localhost:8080/box_starting/local_ubuntu
WORKDIR /app

# Set environment variables (critical for cron to work properly)
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install dependencies in one layer
RUN apt-get update && \
    apt-get install -y cron rsync docker.io && \
    rm -rf /var/lib/apt/lists/*

# Copy sync script
COPY entry.sh /app/

# Configure everything in one layer: permissions, logs, env, crontab
# Runs every hour at minute 30
RUN chmod +x /app/entry.sh && \
    touch /var/log/zot-sync.log && \
    { \
        echo "LANG=C.UTF-8"; \
        echo "LC_ALL=C.UTF-8"; \
        echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; \
    } >> /etc/environment && \
    (crontab -l 2>/dev/null || true; echo "30 * * * * . /etc/environment; /app/entry.sh >> /var/log/zot-sync.log 2>&1") | crontab -

ENTRYPOINT ["cron", "-f", "-L 15"]
