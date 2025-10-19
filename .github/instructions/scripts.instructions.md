---
applyTo: "scripts/**"
---

# Script Creation Rules

## Required Template
Use this template verbatim for every new script. Replace placeholders with the script name and purpose, but keep the helper functions and color constants untouched. Begin each file with the shebang made from a number sign, an exclamation mark, and `/usr/bin/env bash`, then include the block below.

```text
# Script to <short description>
# Usage: ./scripts/<script-name>.sh [options]

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
SCRIPTS_ROOT="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPTS_ROOT")"
SCRIPT_NAME="$(basename "$0")"
OUTPUT_DIR="$SCRIPTS_ROOT/output"
LOG_FILE="$OUTPUT_DIR/${SCRIPT_NAME%.sh}.log"

mkdir -p "$OUTPUT_DIR"
> "$LOG_FILE"

# Source shared utilities
# shellcheck disable=SC1090,SC1091
source "$SCRIPTS_ROOT/utils.sh"

show_usage() {
    echo -e "${BOLD}${BLUE}Usage:${NC} $0 [options]"
    echo ""
    echo -e "${BOLD}${GREEN}Description:${NC}"
    echo "  <what the script does>"
    echo ""
    echo -e "${BOLD}${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}-h, --help${NC}    Show this help message"
    echo ""
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_usage
    exit 0
fi

print_status "Starting ${SCRIPT_NAME%.sh}..."
# ... main logic ...
print_success "${SCRIPT_NAME%.sh} completed successfully!"
```

## Directory Structure Standards

### Script Organization
```
scripts/
├── interactive.sh                    # Main interactive menu
├── utils.sh                         # Shared utilities (colors, logging functions)
├── environment.sh                   # Environment setup helpers
├── output/                          # All log files go here
│   ├── app/                        # Logs from scripts/app/
│   └── libs/                       # Logs from scripts/libs/
│       └── wt/                     # Logs from scripts/libs/wt/
├── app/                            # Application management scripts
│   ├── interactive.sh              # App interactive menu
│   ├── interactive_configuration.sh # Configuration state management
│   ├── build.sh                    # Build application
│   └── run.sh                      # Run application
└── libs/                           # Library management scripts
    └── wt/                         # Wt library specific scripts
        ├── download.sh             # Download Wt source
        ├── install.sh              # Build and install Wt
        ├── uninstall.sh            # Uninstall Wt
        └── build_configurations/   # Configuration files
            ├── default.conf
            ├── debug.conf
            ├── release.conf
            └── minimal.conf
```

### Variable Naming for Nested Scripts
For scripts in subdirectories (e.g., `scripts/libs/wt/`), use unique variable names to avoid conflicts with sourced utilities:

```bash
# For scripts in scripts/libs/wt/
WT_SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
SCRIPTS_ROOT="$(cd "$WT_SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$SCRIPTS_ROOT/output/libs/wt"

# For scripts in scripts/app/
APP_SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
SCRIPTS_ROOT="$(dirname "$APP_SCRIPT_DIR")"
OUTPUT_DIR="$SCRIPTS_ROOT/output/app"
```

## Logging Standards

### Log File Placement
- **Root scripts** (`scripts/script.sh`): Log to `scripts/output/script.log`
- **App scripts** (`scripts/app/script.sh`): Log to `scripts/output/app/script.log`
- **Library scripts** (`scripts/libs/wt/script.sh`): Log to `scripts/output/libs/wt/script.log`

### Directory Creation Pattern
```bash
# Calculate output directory based on script location relative to scripts/
RELATIVE_PATH="${SCRIPT_DIR#$SCRIPTS_ROOT/}"
if [ "$RELATIVE_PATH" != "$SCRIPT_DIR" ]; then
    OUTPUT_DIR="$SCRIPTS_ROOT/output/$RELATIVE_PATH"
else
    OUTPUT_DIR="$SCRIPTS_ROOT/output"
fi
```

## Mandatory Practices

### Script Requirements
- Keep scripts in `scripts/` and log files in `scripts/output/` with matching subdirectory structure
- Call sibling scripts with `bash "$SCRIPT_DIR/<name>.sh" "$@"`; never duplicate their logic
- Preserve `set -e`, the logging helpers, and use shared utilities from `utils.sh`
- Validate prerequisites (e.g., `require_command cmake`) and fail fast with `print_error` when checks fail
- Quote variables, check exit codes, and exit non-zero on unrecoverable errors
- Use `readlink -f` for robust path resolution to avoid issues with symbolic links

### Shared Utilities Usage
- **Always source** `utils.sh` for color constants and print functions
- **Never duplicate** color definitions or logging functions
- Use `require_command` for dependency checking
- Use `get_cpu_cores` for parallel build jobs

### Interactive Script Standards
- Each subdirectory with scripts should have an `interactive.sh` menu
- Interactive scripts should use `dialog` for TUI interfaces
- Always reset terminal colors after dialog interactions:
  ```bash
  printf '\033c'  # Full terminal reset
  clear
  printf '\033[0m'  # Reset colors
  tput sgr0 2>/dev/null || true  # Reset all attributes
  ```
- Handle dialog exits gracefully (Esc, Cancel, etc.)

## Interactive Menu Implementation

### Purpose and Structure
Interactive scripts provide user-friendly TUI menus to execute scripts and manage configurations without remembering command-line arguments. Each script folder should have an `interactive.sh` that presents options to run scripts within that folder.

### Required Interactive Menu Features
1. **Script Execution**: Menu items to run each script in the folder
2. **Configuration Management**: Options to view and change script configurations
3. **Status Display**: Show current configuration state in menu descriptions
4. **Error Handling**: Display error messages and logs when operations fail

### Interactive Menu Template
```bash
#!/usr/bin/env bash
# Script to launch interactive menu for [folder purpose]
# Usage: ./scripts/[folder]/interactive.sh

set -e  # Exit on any error

[FOLDER]_SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
SCRIPTS_ROOT="$(dirname "$[FOLDER]_SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$SCRIPTS_ROOT")"
SCRIPT_NAME="$(basename "$0")"
OUTPUT_DIR="$SCRIPTS_ROOT/output/[folder]"
LOG_FILE="$OUTPUT_DIR/${SCRIPT_NAME%.sh}.log"

mkdir -p "$OUTPUT_DIR"
> "$LOG_FILE"

# Source shared utilities
# shellcheck disable=SC1090,SC1091
source "$SCRIPTS_ROOT/utils.sh"

DIALOG_USED=false

cleanup_screen() {
    if [ "$DIALOG_USED" = true ]; then
        printf '\033c'  # Full terminal reset
        clear
        printf '\033[0m'  # Reset colors
        tput sgr0 2>/dev/null || true  # Reset all attributes
    fi
}

trap cleanup_screen EXIT

ensure_dialog() {
    if ! command -v dialog >/dev/null 2>&1; then
        print_error "The 'dialog' command is required. Install it via your package manager (e.g. sudo apt install dialog)."
        exit 1
    fi
}

# Load current configuration if applicable
load_current_config() {
    # Implementation depends on configuration system
}

# Run script functions
run_script_name() {
    if bash "$[FOLDER]_SCRIPT_DIR/script.sh" "$@"; then
        dialog --title "Success" --msgbox "Script completed successfully." 7 60
    else
        dialog --title "Error" --msgbox "Script failed. Check logs for details." 7 60
    fi
}

show_menu() {
    ensure_dialog
    
    while true; do
        load_current_config  # Update current state
        
        local choice
        choice=$(dialog \
            --colors \
            --clear \
            --no-ok \
            --no-cancel \
            --backtitle "[Folder] Management" \
            --title "[Folder] Control Panel" \
            --menu "Available Operations:" 18 80 7 \
            script1 "Run script1.sh (current config: $CURRENT_CONFIG)" \
            script2 "Run script2.sh" \
            configure "Configure settings" \
            back "Back to main menu" \
            3>&1 1>&2 2>&3)
        DIALOG_USED=true
        local status=$?
        
        # Always reset terminal after dialog
        printf '\033c'  # Full terminal reset
        clear
        printf '\033[0m'  # Reset colors
        tput sgr0 2>/dev/null || true  # Reset all attributes
        
        if [ $status -ne 0 ]; then
            print_status "User exited from menu."
            break
        fi
        
        case "$choice" in
            script1)
                run_script_name
                ;;
            configure)
                configure_settings
                ;;
            back)
                break
                ;;
            *)
                print_warning "Unknown menu selection: $choice"
                ;;
        esac
    done
}

show_menu
print_success "${SCRIPT_NAME%.sh} completed successfully!"
```

### Configuration Integration
Interactive scripts should integrate with configuration management:
- **Display current config** in menu item descriptions
- **Provide configuration menu** to change settings
- **Persist configuration** between sessions using configuration scripts
- **Pass correct parameters** to underlying scripts based on current config

### Menu Navigation Standards
- Use **arrow keys** for navigation
- **Enter** to select items
- **Esc** to exit/go back
- **No OK/Cancel buttons** (use `--no-ok --no-cancel`)
- **Clear terminal state** after each dialog interaction

### Error Display
When scripts fail, interactive menus should:
```bash
if bash "$SCRIPT_DIR/script.sh" "$@"; then
    dialog --title "Success" --msgbox "Operation completed successfully." 7 60
else
    dialog --title "Error" --msgbox "Operation failed. Check logs at $LOG_FILE for details." 8 70
fi
```

### Help Message Standards
- All scripts must support `-h` and `--help`
- Help format should include: Usage, Description, Options
- Do not include Examples section (keep help concise)
- For scripts with configurations, list available configurations in help

### Error Handling
- Use `set -e` for fail-fast behavior
- Provide meaningful error messages with `print_error`
- Log errors to both console and log file
- Exit with appropriate exit codes (0 for success, non-zero for errors)

### Configuration Management
- Use `.conf` files for build configurations
- Store configurations in `build_configurations/` subdirectories
- Support `--config` parameter to select configurations
- Validate configuration names and provide helpful error messages

## Permission & Environment Helpers
Copy these helpers when dealing with Docker or privileged operations. Keep their names unchanged so other scripts can reuse them.

```bash
need_sudo_for_docker() {
    if docker info &> /dev/null; then
        return 1
    elif sudo docker info &> /dev/null 2>&1; then
        return 0
    fi
    print_error "Cannot access Docker even with sudo. Check the Docker installation."
    exit 1
}

check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        print_status "Running as root user"
        return 0
    fi
    if ! sudo -n true 2>/dev/null; then
        print_status "Elevated privileges required. You may be prompted for your password."
        sudo -v || {
            print_error "Cannot obtain sudo privileges."
            exit 1
        }
    fi
}

detect_environment() {
    if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
        echo "docker"
    else
        echo "host"
    fi
}
```