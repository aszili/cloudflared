FROM golang:1.24-alpine as build

WORKDIR /src
RUN apk add --no-cache ca-certificates git build-base
ARG CLOUDFLARED_VERSION
RUN git clone https://github.com/cloudflare/cloudflared --depth=1 --branch ${CLOUDFLARED_VERSION} .
RUN GOARCH=amd64 GO111MODULE=on CGO_ENABLED=0 make -j "$(nproc)" cloudflared

FROM alpine:3
RUN apk add --no-cache ca-certificates tzdata curl
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared
ENTRYPOINT ["cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
