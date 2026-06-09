FROM pubhub.aiursoft.com/bytemark/webdav:latest

COPY webdav-config.yaml /config.yaml

EXPOSE 8080

ENTRYPOINT ["/usr/bin/webdav", "--config", "/config.yaml"]
