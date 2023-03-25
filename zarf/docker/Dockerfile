# Build the Go Binary
FROM golang:1.17 as build_service-api
ENV CGO_ENABLED 0
ARG BUILD_REF

# Copy the source code to the container
COPY . /service

# Build the service binary
WORKDIR /service
RUN go build -ldflags "-X main.build=${BUILD_REF}"

# Run the go binary in Alpine.
FROM alpine:3.17.2
ARG BUILD_DATE
ARG BUILD_REF

RUN addgroup -g 1000 -S service && \
    adduser -u 1000 -h /service -G service -S service

COPY --from=build_service-api --chown=service:service /service /service
WORKDIR /service
USER service
CMD ["./go-service"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="service-api" \
      org.opencontainers.image.authors="Brice Lalu <brice.lalu@free.fr>" \
      org.opencontainers.image.source="https://github.com/ardanlabs/service/app/service-api" \
      org.opencontainers.image.revision="${BUILD_REF}" \
      org.opencontainers.image.vendor="Brice Lalu"