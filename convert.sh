#!/bin/bash

RED='\033[0;31m'
RESET='\033[0m'

if [ -z "$1" ]; then
  echo -e "${RED}No argument supplied : Usage ./convert.sh /dir/to/file_output.pdf${RESET}"
  exit 1
fi

if [ -d "$1" ]; then
  echo -e "${RED}Argument is a directory : Usage ./convert.sh /dir/to/file_output.pdf${RESET}"
  exit 1
fi

if [ ! -w "$(dirname "$1")" ]; then
  echo -e "${RED}Directory $(dirname "$1") is not writable.${RESET}"
  exit 1
fi

if [ ! -d "resources" ]; then
  echo -e "${RED}Resources folder does not exist.${RESET}"
  exit 1
fi

if [ ! -f "resources/cover.pdf" ]; then
  echo -e "${RED}cover.pdf does not exist in resources folder.${RESET}"
  exit 1
fi

rm "$1"
docker build --tag pandoc-make .
docker run \
  -e "CHOWN_IDU=$(id -u)" -e "CHOWN_IDG=$(id -g)" -e "FILE_LOCATION=$1" \
  -v "$(pwd)/resources:/resources" -v "$(pwd)/documentation:/workdir:ro" -v "$(dirname "$1")":/tmp:rw \
  pandoc-make .
