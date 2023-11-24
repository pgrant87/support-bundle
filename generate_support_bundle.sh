#!/bin/bash
# This script generates a support bundle for Airbyte

### GLOBAL VARIABLES ###
BUNDLE_DIR="/tmp/airbyte-support-bundle-$(date +%Y-%m-%d-%H-%M-%S)"
BUNDLE_TARBALL="$BUNDLE_DIR.tar.gz"
CONTAINER_LOGS_DIR="$BUNDLE_DIR/container_logs"
SYSTEMINFO_FILE="$BUNDLE_DIR/system_info.txt"

### FUNCTION DECLARATIONS ###

# Function to create the bundle directory structure:
build_bundle_dir () {
  mkdir -p "$CONTAINER_LOGS_DIR"
}

# Banner function for street cred:
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

# Function to collect system info:
get_system_info () {
  
  # Function to collect in-depth system information for Linux:
  get_linux_info () {
    {
      printf "System Information:" 
      printf "\n------------------------\n" 
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
  docker-compose config > "$BUNDLE_DIR/docker-compose.yaml"
}

# Function to collect all the container logs:
get_container_logs () {
  CONTAINERS=$(docker-compose ps --format "{{.Names}}")
  for CONTAINER in $CONTAINERS; do
    docker logs "$CONTAINER" > "$CONTAINER_LOGS_DIR/$CONTAINER.log" 2>&1
  done
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
  get_container_logs
  clean_up
}

### BUNDLE EXECUTION ###
main
exit 0
