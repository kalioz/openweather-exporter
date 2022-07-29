########################
# Build Container Creation
########################

FROM golang:1.17 as build

ARG LD_FLAGS

WORKDIR /go/src/github.com/billykwooten/openweather-exporter
COPY . .

RUN go version
RUN go mod vendor
# RUN GO111MODULE=on CGO_ENABLED=1 go test -race -mod vendor ./...
RUN GO111MODULE=on CGO_ENABLED=0 go build -mod vendor -ldflags "$LD_FLAGS" -o /go/bin/app .

# fetch SSL dependencies
RUN apt update && apt install -y git ca-certificates && update-ca-certificates

ENTRYPOINT ["/go/bin/app"]

########################
# Build App Container
########################

FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/app /
ENTRYPOINT ["/app"]
