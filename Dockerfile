FROM otel/opentelemetry-collector-contrib:0.149.0

COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod +x /entrypoint.sh
USER 1000

ENTRYPOINT ["/entrypoint.sh"]
