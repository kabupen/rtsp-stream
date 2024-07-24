## Build stage
FROM golang:1.16-alpine AS build-env
ADD ./main.go /go/src/github.com/Roverr/rtsp-stream/main.go
ADD ./core /go/src/github.com/Roverr/rtsp-stream/core
ADD ./Gopkg.toml /go/src/github.com/Roverr/rtsp-stream/Gopkg.toml
ADD ./go.mod /go/src/github.com/Roverr/rtsp-stream/go.mod
WORKDIR /go/src/github.com/Roverr/rtsp-stream
RUN apk add --update --no-cache git

RUN go mod tidy
RUN go build -o server

## Creating potential production image
FROM alpine
RUN apk update && apk add bash ca-certificates ffmpeg && rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=build-env /go/src/github.com/Roverr/rtsp-stream/server /app/
COPY ./build/rtsp-stream.yml /app/rtsp-stream.yml
ENTRYPOINT [ "/app/server" ]
