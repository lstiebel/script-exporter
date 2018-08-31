FROM alpine:3.8
RUN apk add --no-cache bash ca-certificates openssl && update-ca-certificates
WORKDIR /root/

COPY script-exporter /bin/script-exporter
COPY scripts/ /root/scripts
RUN chmod +x /bin/script-exporter /root/scripts/*

CMD /bin/script-exporter -script.path /root/scripts -web.listen-address :9661
