#!/usr/bin/env bash

# Script to run the compiled Wt application
# Usage: ./scripts/app/run.sh [options]

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCRIPT_NAME="$(basename "$0")"
OUTPUT_DIR="$SCRIPT_DIR/output"
LOG_FILE="$OUTPUT_DIR/${SCRIPT_NAME%.sh}.log"

mkdir -p "$OUTPUT_DIR"
> "$LOG_FILE"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_status() {
    local msg="$1"
    echo -e "${BLUE}[INFO]${NC} $msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $msg" >> "$LOG_FILE"
}

print_success() {
    local msg="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $msg" >> "$LOG_FILE"
}

print_warning() {
    local msg="$1"
    echo -e "${YELLOW}[WARNING]${NC} $msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $msg" >> "$LOG_FILE"
}

print_error() {
    local msg="$1"
    echo -e "${RED}[ERROR]${NC} $msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $msg" >> "$LOG_FILE"
}

show_usage() {
    echo -e "${BOLD}${BLUE}Usage:${NC} $0 [options]"
    echo ""
    echo -e "${BOLD}${GREEN}Description:${NC}"
    echo "  Run the compiled Wt application binary"
    echo ""
    echo -e "${BOLD}${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}-d, --debug${NC}        Use debug build (default)"
    echo -e "  ${CYAN}-r, --release${NC}      Use release build"
    echo -e "  ${CYAN}-h, --help${NC}         Show this help message"
    echo ""
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_usage
    exit 0
fi

print_status "Starting ${SCRIPT_NAME%.sh}..."

set -o pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
ORIGINAL_OUTPUT_DIR="$OUTPUT_DIR"
ORIGINAL_LOG_FILE="$LOG_FILE"

SCRIPTS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck disable=SC1090,SC1091
source "$SCRIPTS_ROOT/utils.sh"
# shellcheck disable=SC1090,SC1091
source "$SCRIPTS_ROOT/environment.sh"

if ! init_script_environment "$SCRIPT_SOURCE"; then
    print_error "Failed to initialise shared environment for $SCRIPT_SOURCE"
    exit 1
fi

if [ "$OUTPUT_DIR" != "$ORIGINAL_OUTPUT_DIR" ]; then
    if [ -f "$ORIGINAL_LOG_FILE" ]; then
        cat "$ORIGINAL_LOG_FILE" >> "$LOG_FILE"
        rm -f "$ORIGINAL_LOG_FILE"
    fi
    rmdir "$ORIGINAL_OUTPUT_DIR" 2>/dev/null || true
fi

print_status "Project root: $PROJECT_ROOT"
print_status "Log file: $LOG_FILE"

APP_BINARY_NAME="app"
BUILD_TYPE="debug"
DOCROOT="$PROJECT_ROOT/static;$PROJECT_ROOT/resources"
HTTP_ADDRESS="127.0.0.1"
HTTP_PORT="8080"
DEPLOY_PATH="/"

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug|-d)
            BUILD_TYPE="debug"
            shift
            ;;
        --release|-r)
            BUILD_TYPE="release"
            shift
            ;;
        *)
            print_error "Unknown argument: $1"
            show_usage
            exit 1
            ;;
    esac
done

BUILD_SCRIPT="$SCRIPT_DIR/build.sh"
if [ ! -f "$BUILD_SCRIPT" ]; then
    print_error "Missing build script at $BUILD_SCRIPT"
    exit 1
fi

BUILD_DIR="$PROJECT_ROOT/build/$BUILD_TYPE"
BINARY_PATH="$BUILD_DIR/$APP_BINARY_NAME"
WORK_DIR="$PROJECT_ROOT/build"

print_status "Selected build type: $BUILD_TYPE"
print_status "Document root: $DOCROOT"
print_status "HTTP address: $HTTP_ADDRESS"
print_status "HTTP port: $HTTP_PORT"
print_status "Deploy path: $DEPLOY_PATH"

if [ ! -x "$BINARY_PATH" ]; then
    print_error "Application binary not found at $BINARY_PATH"
    print_status "Run ./scripts/app/build.sh --$BUILD_TYPE to build the application"
    exit 1
fi

if [ ! -d "$WORK_DIR" ]; then
    print_error "Build directory not found: $WORK_DIR"
    exit 1
fi

WT_ARGS=("--docroot" "$DOCROOT" "--http-address" "$HTTP_ADDRESS" "--http-port" "$HTTP_PORT" "--deploy-path" "$DEPLOY_PATH")

printf -v wt_args_string "%q " "${WT_ARGS[@]}"
print_status "Wt arguments: ${wt_args_string% }"

print_status "Launching $BUILD_TYPE build from $WORK_DIR/$BUILD_TYPE"
print_status "Executable: $BINARY_PATH"

if ! pushd "$WORK_DIR" >/dev/null; then
    print_error "Failed to change directory to $WORK_DIR"
    exit 1
fi

set +e
CMD=("./$BUILD_TYPE/$APP_BINARY_NAME" "${WT_ARGS[@]}")
# Run application while duplicating output into the log file.
"${CMD[@]}" 2>&1 | tee -a "$LOG_FILE"
APP_EXIT_CODE=${PIPESTATUS[0]}
set -e

popd >/dev/null || true

if [ "$APP_EXIT_CODE" -eq 130 ]; then
    print_warning "Application interrupted by signal (exit code 130)"
elif [ "$APP_EXIT_CODE" -ne 0 ]; then
    print_error "Application exited with code $APP_EXIT_CODE"
    exit "$APP_EXIT_CODE"
else
    print_success "Application exited cleanly"
fi

print_success "${SCRIPT_NAME%.sh} completed successfully!"
