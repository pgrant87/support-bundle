#!/bin/bash
# This script generates a support bundle for Airbyte

### GLOBAL VARIABLES ###
CONTAINERS=$(docker-compose ps --format "{{.Names}}")
BUNDLE_DIR="/tmp/airbyte-support-bundle-$(date +%Y-%m-%d-%H-%M-%S)"
CONTAINER_LOGS_DIR="$BUNDLE_DIR/container_logs"

### FUNCTION DECLARATIONS ###
# Function to create the bundle directory structure:
build_bundle_dir () {
  mkdir -p "$CONTAINER_LOGS_DIR"
}

# Function to collect the docker details:
get_docker_info () {
  docker-compose config --quiet > "$BUNDLE_DIR/docker-compose.yaml"
}

# Function to collect all the container logs:
get_container_logs () {
  for CONTAINER in $CONTAINERS; do
    docker logs "$CONTAINER" > "$CONTAINER_LOGS_DIR/$CONTAINER.log" 2>&1
  done
}

# Function to compress the bundle directory, print the size and location of the archive 
# and then remove the bundle directory:
clean_up () {
  tar -czf "$BUNDLE_DIR.tar.gz" -C $BUNDLE_DIR .
  echo "$(du -sh "$BUNDLE_DIR.tar.gz" | cut -f1) support bundle generated at "$BUNDLE_DIR.tar.gz""
  rm -rf "$BUNDLE_DIR"
}

# Main flow and function calls:
main () {
  build_bundle_dir
  get_docker_info
  get_container_logs
  clean_up
}

### BUNDLE EXECUTION ###
main
exit 0
