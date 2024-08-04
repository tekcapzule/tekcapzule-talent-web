#!/bin/sh

SHELL_ARG="yarn start:dev"
SERVER_PORT="4200"
NG_CLI_VERSION="17.3.8"

print_help() {
  echo "\nUsage: ./run_script.sh [option]\n"
  echo "Options:"
  echo "  start [--port 4200]   Install dependencies and start local dev server"
  echo "  serve [--port 4200]   Start local dev server"
  echo "  install               Install local dependencies"
  echo "  build                 Generate the dev build"
  echo "  prod                  Generate the prod build"
  echo "  shell                 Open shell prompt in the container"
  echo "  clean                 Delete dependencies and build files"
  echo "  help                  Show this help\n"
}

docker_run_it() {
  docker run -it --rm \
    --name tekcapzule-tatent-web-$(date +%s) \
    -p "$SERVER_PORT":"$SERVER_PORT" \
    --mount type=bind,source=$(pwd),target=/app \
    --platform=linux/amd64 \
    akhilpb001/ng-cli:$NG_CLI_VERSION \
    /bin/sh -c "$SHELL_ARG"
}

docker_run_nonit() {
  docker run --rm \
    --name tekcapzule-talent-web-runner-$(date +%s) \
    --mount type=bind,source=$(pwd),target=/app \
    --platform=linux/amd64 \
    akhilpb001/ng-cli:$NG_CLI_VERSION \
    /bin/sh -c "$SHELL_ARG"
}

docker_run_shell() {
  docker run -it --rm \
    --name tekcapzule-talent-web-shell-$(date +%s) \
    --mount type=bind,source=$(pwd),target=/app \
    --platform=linux/amd64 \
    akhilpb001/ng-cli:$NG_CLI_VERSION /bin/sh
}

install_dependencies() {
  echo "[INFO] Installing dependencies..."
  SHELL_ARG="yarn install --frozen-lockfile"
  docker_run_nonit
}

generate_dev_build() {
  echo "[INFO] Generating dev build..."
  SHELL_ARG="yarn build"
  docker_run_nonit
}

generate_prod_build() {
  echo "[INFO] Generating prod build..."
  SHELL_ARG="yarn build:prod"
  docker_run_nonit
}

start_dev_server() {
  echo "[INFO] Starting local dev server..."
  SHELL_ARG="yarn start:dev --port $SERVER_PORT"
  docker_run_it
}

# Print help if there are no arguments
if [ -z "$1" ]; then
  print_help
  exit
fi

# Extracting server port from the CLI command
if [[ "$2" == "--port" ]]; then
  echo "Extracting server port..."
  SERVER_PORT=$3
fi

# Extracting server port from the CLI command
if [[ "$2" == "--port="* ]]; then
echo "Extracting server port..."
  SERVER_PORT="$(echo $2 | sed 's/--port=//')"
fi

# Parsing CLI commands and running actions
if [[ "$1" == "build" ]]; then
  echo "[INFO] Deleting generated files..."
  sh -c "rm -rf dist/"
  install_dependencies
  generate_dev_build
  exit
elif [[ "$1" == "prod" ]]; then
  echo "[INFO] Deleting generated files..."
  sh -c "rm -rf dist/"
  install_dependencies
  generate_prod_build
  exit
elif [[ "$1" == "start" ]]; then
  install_dependencies
  start_dev_server
  exit
elif [[ "$1" == "serve" ]]; then
  start_dev_server
  exit
elif [[ "$1" == "install" ]]; then
  install_dependencies
  exit
elif [[ "$1" == "shell" ]]; then
  echo "[INFO] Opening shell prompt in the container..."
  docker_run_shell
  exit
elif [[ "$1" == "clean" ]]; then
  echo "[INFO] Deleting dependencies..."
  sh -c "rm -rf node_modules/"
  echo "[INFO] Deleting build files..."
  sh -c "rm -rf dist/"
  exit
elif [[ "$1" == "help" ]]; then
  print_help
  exit
else
  echo "\nError: Invalid option"
  print_help
  exit
fi


