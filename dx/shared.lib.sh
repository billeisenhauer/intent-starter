#!/usr/bin/env bash
# dx/shared.lib.sh

DIRNAME=$(dirname -- "${0}")
SCRIPT_DIR=$(cd -- "${DIRNAME}" > /dev/null 2>&1 && pwd)
ROOT_DIR=$(cd -- "${SCRIPT_DIR}"/.. > /dev/null 2>&1 && pwd)

log() {
  echo "[ ${0} ]" "${@}"
}

check_for_docker() {
  if ! command -v "docker" > /dev/null 2>&1; then
    log "Docker is not installed."
    log "Please visit https://docs.docker.com/get-docker/"
    exit 1
  fi
  log "Docker is installed!"
}
