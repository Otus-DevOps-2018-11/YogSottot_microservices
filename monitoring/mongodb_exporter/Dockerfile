FROM       golang:alpine as builder

RUN apk --no-cache --update add git curl make libc-dev gcc libgcc && \
    curl -s https://glide.sh/get | sh && \
    mkdir -p  /go/src/github.com/percona/mongodb_exporter \
    && cd /go/src/github.com/percona/mongodb_exporter \
    &&  git clone --depth 1 --branch v0.6.3 https://github.com/percona/mongodb_exporter.git . && \
    cd /go/src/github.com/percona/mongodb_exporter && make build

#FROM       alpine:3.7
FROM       busybox:latest
EXPOSE     9216
#RUN apk add --no-cache ca-certificates
#COPY --from=builder /go/src/github.com/percona/mongodb_exporter/mongodb_exporter /usr/local/bin/mongodb_exporter
COPY --from=builder /go/src/github.com/percona/mongodb_exporter/mongodb_exporter /bin/mongodb_exporter

ENTRYPOINT [ "mongodb_exporter", "-collect.database" ]
