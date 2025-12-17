FROM golang:1.23.1-alpine AS builder

RUN apk add --no-cache git

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o /build/test-task-dmrtx .

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/test-task-dmrtx /test-task-dmrtx
COPY --from=builder /build/my-chart /my-chart
COPY --from=builder /build/Chart.yaml /Chart.yaml

ENTRYPOINT ["/test-task-dmrtx"]