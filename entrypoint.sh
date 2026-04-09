#!/bin/sh
set -e

CONFIG_FILE="/tmp/otel-config.yaml"

if [ -n "$OTEL_CONFIG" ]; then
  echo "$OTEL_CONFIG" > "$CONFIG_FILE"
else
  cat > "$CONFIG_FILE" <<EOF
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  clickhouse:
    endpoint: ${CLICKHOUSE_ENDPOINT:-tcp://central-station-clickhouse.central-station.svc.cluster.local:9000}
    username: ${CLICKHOUSE_USER:-central_station}
    password: ${CLICKHOUSE_PASSWORD:-central_station}
    database: otel
    traces_table_name: otel_traces
    logs_table_name: otel_logs
    create_schema: true
  debug:
    verbosity: basic

extensions:
  health_check:
    endpoint: 0.0.0.0:13133

service:
  extensions: [health_check]
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [clickhouse, debug]
    logs:
      receivers: [otlp]
      exporters: [clickhouse, debug]
EOF
fi

exec /otelcol-contrib --config "$CONFIG_FILE"
