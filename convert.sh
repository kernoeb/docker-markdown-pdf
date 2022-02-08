#!/bin/bash

RED='\033[0;31m'
RESET='\033[0m'

USAGE="Usage ./convert.sh -o <output_file> <doc_dir>"

if [[ $1 == "-o" || $1 == "--output" ]]; then
    OUTPUT=$2
    shift
    shift
else
   echo -e "${RED}Error:${RESET} No output file specified : $USAGE"
   exit 1
fi

if [ -z "$OUTPUT" ]; then
  echo -e "${RED}No argument supplied : $USAGE${RESET}"
  exit 1
fi

if [ -d "$OUTPUT" ]; then
  echo -e "${RED}Argument is a directory : $USAGE${RESET}"
  exit 1
fi

if [ ! -w "$(dirname "$OUTPUT")" ]; then
  echo -e "${RED}Directory $(dirname "$OUTPUT") is not writable.${RESET}"
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

if [ -z "$1" ]; then
  echo -e "${RED}No documentation directory supplied : $USAGE${RESET}"
  exit 1
fi

if [ ! -d "$1" ]; then
  echo -e "${RED}Chosen documentation path is not a directory : $USAGE${RESET}"
  exit 1
fi

if [ ! -f "$1/_sidebar.md" ]; then
  echo -e "${RED}Output directory needs a _sidebar.md : $USAGE${RESET}"
  exit 1
fi

DOCUMENTATION_PATH="$(cd "$(dirname "$1")" || exit; pwd)/$(basename "$1")"

VERSION="latest"
#VERSION="main"

rm "$OUTPUT"
#docker build --tag pandoc-make .
docker pull ghcr.io/kernoeb/docker-markdown-pdf:"$VERSION"
docker run \
  -e "CHOWN_IDU=$(id -u)" -e "CHOWN_IDG=$(id -g)" -e "FILE_LOCATION=$OUTPUT" \
  -v "$(pwd)/resources:/resources" -v "$DOCUMENTATION_PATH":/app/documentation/:ro -v "$(dirname "$OUTPUT")":/tmp:rw \
  ghcr.io/kernoeb/docker-markdown-pdf:"$VERSION"
