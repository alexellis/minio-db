FROM golang:1.11 as build

WORKDIR /go/src/github.com/alexellis/minio-kv/

COPY .git               .git
COPY vendor             vendor
COPY main.go            .

ARG GIT_COMMIT
ARG VERSION

RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.GitCommit=${GIT_COMMIT} -X main.Version=${VERSION}" -a -installsuffix cgo -o /usr/bin/minio-kv

FROM alpine:3.10
RUN apk add --force-refresh ca-certificates

# Add non-root user
RUN addgroup -S app && adduser -S -g app app \
  && mkdir -p /home/app || : \
  && chown -R app /home/app

RUN touch /tmp/.lock

COPY --from=build /usr/bin/minio-kv /usr/bin/
WORKDIR /home/app

USER app
EXPOSE 8080

ENTRYPOINT ["minio-kv"]
