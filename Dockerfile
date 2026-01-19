FROM golang:1.24-alpine as build

WORKDIR /src
RUN apk add --no-cache git ca-certificates
ARG CLOUDFLARED_VERSION
RUN git clone https://github.com/cloudflare/cloudflared --depth=1 --branch ${CLOUDFLARED_VERSION} .
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -trimpath -ldflags="-s -w" -o cloudflared ./cmd/cloudflared

FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /src/cloudflared /cloudflared
ENTRYPOINT ["/cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]

