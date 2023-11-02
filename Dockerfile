FROM alpine:3.10
COPY entrypoint.sh /usr/bin/
RUN apk add --no-cache bash
RUN ln -s /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
