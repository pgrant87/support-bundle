#!/bin/bash

CONTAINERS=$(docker-compose ps --format "{{.Names}}")
BUNDLE_DIR="/tmp/airbyte-support-bundle-$(date +%Y-%m-%d-%H-%M-%S)"
mkdir -p "$BUNDLE_DIR"

for CONTAINER in $CONTAINERS; do
  docker logs "$CONTAINER" > "$BUNDLE_DIR/$CONTAINER.log"
done

tar -czf "$BUNDLE_DIR.tar.gz" "$BUNDLE_DIR"

echo "Support bundle generated at $BUNDLE_DIR"

exit 0
