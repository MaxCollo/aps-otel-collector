FROM alpine:3.21 AS base
RUN apk add --no-cache ca-certificates

FROM otel/opentelemetry-collector-contrib:0.149.0 AS otel

FROM base
COPY --from=otel /otelcol-contrib /otelcol-contrib
COPY --chmod=755 entrypoint.sh /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:13133/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
