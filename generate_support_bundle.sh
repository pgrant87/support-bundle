#!/bin/bash
# This script generates a support bundle for Airbyte


########## GLOBAL VARIABLES ##########
BUNDLE_DIR="/tmp/airbyte-support-bundle-$(date +%Y-%m-%d-%H-%M-%S)"
BUNDLE_TARBALL="$BUNDLE_DIR.tar.gz"
CONTAINER_LOGS_DIR="$BUNDLE_DIR/container_logs"
CONNECTOR_INFO_DIR="$BUNDLE_DIR/connector_info"
DOCKER_INFO_DIR="$BUNDLE_DIR/docker_info"
DOCKER_INSPECT_DIR="$DOCKER_INFO_DIR/docker_inspect"
DATABASE_INFO_DIR="$BUNDLE_DIR/database_info"
SYSTEMINFO_FILE="$BUNDLE_DIR/system_info.txt"
API_AUTH=""


########## FUNCTION DECLARATIONS ##########

# Pointless banner function for street cred:
print_banner () {
  # Make sure the console is huuuge
  if test "$(tput cols)" -ge 64; then
    # Make it green!
    echo -e "\033[32m"
    echo -e " █████╗ ██╗██████╗ ██████╗ ██╗   ██╗████████╗███████╗"
    echo -e "██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝╚══██╔══╝██╔════╝"
    echo -e "███████║██║██████╔╝██████╔╝ ╚████╔╝    ██║   █████╗  "
    echo -e "██╔══██║██║██╔══██╗██╔══██╗  ╚██╔╝     ██║   ██╔══╝  "
    echo -e "██║  ██║██║██║  ██║██████╔╝   ██║      ██║   ███████╗"
    echo -e "╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝    ╚═╝      ╚═╝   ╚══════╝"
    echo -e "                                       Support Bundle"
    # Make it less green
    echo -e "\033[0m"
    sleep 1
  fi
}

# Function to create the bundle directory structure:
build_bundle_dir () {
  mkdir -p "$CONTAINER_LOGS_DIR"
  mkdir -p "$CONNECTOR_INFO_DIR"
  mkdir -p "$DOCKER_INSPECT_DIR"
  mkdir -p "$DATABASE_INFO_DIR"
}

# Function to collect system info:
get_system_info () {
  
  # Function to collect in-depth system information for Linux:
  get_linux_info () {
    {
      printf "System Information:" 
      printf "\n------------------------\n" 
      printf "\nHostname:\n"
      hostname
      printf "\nIP Address:\n"
      hostname -I
      printf "\nOS Information:\n"
      uname -a 
      printf "\n"
      lsb_release -a
      printf "\nCPU Information:\n"
      lscpu
      printf "\nMemory Information:\n"
      free -m
      printf "\nDisk Information:\n"
      df -h
      printf "\nNetwork Information:\n"
      ifconfig -a
      printf ""
    } >> "$SYSTEMINFO_FILE"
  }

  # Function to collect in-depth system information for macOS:
  get_mac_info () {
    {
      printf "System Information" 
      printf "\n----------------------\n"
      printf "\nHostname:\n"
      hostname
      printf "\nIP Address:\n"
      ipconfig getifaddr en0
      printf "\nOS Information:\n"
      uname -a
      printf "\n"
      system_profiler SPHardwareDataType SPSoftwareDataType 
      printf "\nCPU Information:\n" 
      sysctl -a | grep machdep.cpu 
      printf "\nMemory Information:\n" 
      sysctl -a | grep hw.memsize 
      printf "\nDisk Information:\n" 
      df -h 
      printf "\nNetwork Information:\n" 
      ifconfig -a 
      printf "" 
    } >> "$SYSTEMINFO_FILE"
  }

  # Detect the operating system and get info:
  case "$(uname -s)" in
      Linux*)   get_linux_info;;
      Darwin*)  get_mac_info;;
  esac
}

# Function to collect docker details:
get_docker_info () {
  docker version > "$DOCKER_INFO_DIR/docker-version.txt" 
  docker ps -a > "$DOCKER_INFO_DIR/docker-ps.txt"
  docker network inspect airbyte_default > "$DOCKER_INFO_DIR/docker-network.txt"
  docker images > "$DOCKER_INFO_DIR/docker-images.txt"
  docker system df > "$DOCKER_INFO_DIR/docker-system.txt"
  docker info > "$DOCKER_INFO_DIR/docker-info.txt"
  docker-compose config > "$DOCKER_INFO_DIR/docker-compose.yaml"
  docker-compose ps > "$DOCKER_INFO_DIR/docker-compose-ps.txt"
  docker-compose top > "$DOCKER_INFO_DIR/docker-compose-top.txt"
  docker-compose version > "$DOCKER_INFO_DIR/docker-compose-version.txt"
  docker-compose images > "$DOCKER_INFO_DIR/docker-compose-images.txt"
}

# Function to collect all the container logs and inspect output:
get_container_info () {
  CONTAINERS=$(docker-compose ps --format "{{.Names}}")
  for CONTAINER in $CONTAINERS; do
    docker logs "$CONTAINER" > "$CONTAINER_LOGS_DIR/$CONTAINER.log" 2>&1
    docker inspect "$CONTAINER" > "$DOCKER_INSPECT_DIR/$CONTAINER-inspect.txt" 2>&1
  done
}

# function to gather base64 API authentication credintials from .env file:
get_env_credentials () {
  ENV_FILE="../.env"
  if [ -f "$ENV_FILE" ]; then
    USER=$(grep -E "BASIC_AUTH_USERNAME" "$ENV_FILE" | cut -d '=' -f2)
    PW=$(grep -E "BASIC_AUTH_PASSWORD" "$ENV_FILE" | cut -d '=' -f2)
    API_AUTH=$(echo -n "$USER:$PW" | base64)
  fi
}

# Function to collect source, destination and connection details via the airbyte API:
get_connector_details () {
  get_env_credentials

  # API endpoints
  API_SOURCE='http://localhost:8006/v1/sources/'
  API_DEST='http://localhost:8006/v1/destinations/'
  API_CONNECTIONS='http://localhost:8006/v1/connections/'

  curl -s --location --request GET "$API_SOURCE" --header "Authorization: Basic ""$API_AUTH"" " > "$CONNECTOR_INFO_DIR/sources.json"
  curl -s --location --request GET "$API_DEST" --header "Authorization: Basic ""$API_AUTH"" " > "$CONNECTOR_INFO_DIR/destinations.json"
  curl -s --location --request GET "$API_CONNECTIONS" --header "Authorization: Basic ""$API_AUTH"" " > "$CONNECTOR_INFO_DIR/connections.json"
}

# Function to collect database tables, sizes and schema
get_database_info () {
  #command to collec tthe db schema:
  docker exec -i airbyte-db pg_dump -U docker -d airbyte --schema-only > "$DATABASE_INFO_DIR/schema.sql"
}

# Function to compress the bundle directory, print the size and location of the archive 
# and then remove the bundle directory:
clean_up () {
  tar -czf "$BUNDLE_TARBALL" -C "$BUNDLE_DIR" .
  echo "$(du -sh "$BUNDLE_TARBALL" | cut -f1) support bundle generated at ""$BUNDLE_TARBALL"""
  rm -rf "$BUNDLE_DIR"
}

# Main flow and function calls:
main () {
  print_banner
  build_bundle_dir
  get_system_info
  get_docker_info
  get_container_info
  get_connector_details
  get_database_info
  clean_up
}


########## BUNDLE EXECUTION ##########
main
exit 0
