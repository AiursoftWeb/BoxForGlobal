FROM pubhub.aiursoft.com/hacdias/webdav:latest

COPY webdav-config.yaml /config.yaml

EXPOSE 8080

ENTRYPOINT ["/webdav", "-c", "/config.yaml"]
