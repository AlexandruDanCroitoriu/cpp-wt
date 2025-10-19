#!/bin/bash
# Script to download the Wt library source code
# Usage: ./scripts/libs/wt/download.sh [options]

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common variables and functions
source "$SCRIPT_DIR/../../variables.sh"

# Script-specific variables
LOG_FILE="$OUTPUT_DIR/download_wt.log"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Clear the log file for this run
> "$LOG_FILE"

# Colorized help function (REQUIRED)
show_usage() {
    echo -e "${BOLD}${BLUE}Usage:${NC} $0 [options]"
    echo ""
    echo -e "${BOLD}${GREEN}Description:${NC}"
    echo "  Downloads the Wt library source code from the official repository"
    echo "  and places it in the libs/ directory for building and installation."
    echo ""
    echo -e "${BOLD}${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}-h, --help${NC}        Show this help message"
    echo -e "  ${CYAN}--version VERSION${NC} Download specific version (default: latest)"
    echo -e "  ${CYAN}--force${NC}           Force re-download even if already exists"
    echo ""
    echo -e "${BOLD}${YELLOW}Examples:${NC}"
    echo -e "  ${GREEN}$0${NC}                    # Download latest Wt version"
    echo -e "  ${GREEN}$0 --version 4.10.0${NC}  # Download specific version"
    echo -e "  ${GREEN}$0 --force${NC}            # Force re-download"
}

# Default values
WT_VERSION="latest"
FORCE_DOWNLOAD=false
LIBS_DIR="$PROJECT_ROOT/libs"
WT_SOURCE_DIR="$LIBS_DIR/wt"

# Argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --version)
            WT_VERSION="$2"
            shift 2
            ;;
        --force)
            FORCE_DOWNLOAD=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if git is available
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install git first."
        exit 1
    fi
}

# Check if Wt is already downloaded
check_existing_wt() {
    if [ -d "$WT_SOURCE_DIR" ] && [ "$FORCE_DOWNLOAD" = false ]; then
        print_warning "Wt source already exists at: $WT_SOURCE_DIR"
        print_status "Use --force to re-download or remove the directory manually"
        
        # Check if it's a valid git repository
        if [ -d "$WT_SOURCE_DIR/.git" ]; then
            cd "$WT_SOURCE_DIR"
            local current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "unknown")
            print_status "Current version: $current_version"
        fi
        
        return 1
    fi
    return 0
}

# Download Wt source code
download_wt() {
    local repo_url="https://github.com/emweb/wt.git"
    
    print_status "Creating libs directory: $LIBS_DIR"
    mkdir -p "$LIBS_DIR"
    
    # Remove existing directory if force download
    if [ "$FORCE_DOWNLOAD" = true ] && [ -d "$WT_SOURCE_DIR" ]; then
        print_warning "Removing existing Wt source directory"
        rm -rf "$WT_SOURCE_DIR"
    fi
    
    print_status "Downloading Wt library source code..."
    print_status "Repository: $repo_url"
    print_status "Target directory: $WT_SOURCE_DIR"
    
    if [ "$WT_VERSION" = "latest" ]; then
        print_status "Cloning latest version..."
        if git clone "$repo_url" "$WT_SOURCE_DIR"; then
            cd "$WT_SOURCE_DIR"
            local latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "main")
            print_success "Downloaded Wt source code (version: $latest_tag)"
        else
            print_error "Failed to clone Wt repository"
            return 1
        fi
    else
        print_status "Cloning and checking out version: $WT_VERSION"
        if git clone "$repo_url" "$WT_SOURCE_DIR"; then
            cd "$WT_SOURCE_DIR"
            if git checkout "tags/$WT_VERSION" 2>/dev/null || git checkout "$WT_VERSION"; then
                print_success "Downloaded Wt source code version: $WT_VERSION"
            else
                print_error "Failed to checkout version: $WT_VERSION"
                print_warning "Available tags:"
                git tag --list | tail -10
                return 1
            fi
        else
            print_error "Failed to clone Wt repository"
            return 1
        fi
    fi
}

# Verify download
verify_download() {
    if [ ! -d "$WT_SOURCE_DIR" ]; then
        print_error "Wt source directory not found after download"
        return 1
    fi
    
    if [ ! -f "$WT_SOURCE_DIR/CMakeLists.txt" ]; then
        print_error "CMakeLists.txt not found in Wt source directory"
        return 1
    fi
    
    print_success "Wt source code verification passed"
    
    # Show download summary
    cd "$WT_SOURCE_DIR"
    local version=$(git describe --tags --abbrev=0 2>/dev/null || echo "unknown")
    local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local size=$(du -sh . 2>/dev/null | cut -f1 || echo "unknown")
    
    echo ""
    print_status "Download Summary:"
    echo -e "  ${CYAN}Version:${NC} $version"
    echo -e "  ${CYAN}Commit:${NC} $commit"
    echo -e "  ${CYAN}Size:${NC} $size"
    echo -e "  ${CYAN}Location:${NC} $WT_SOURCE_DIR"
    echo ""
}

# Main execution
main() {
    print_status "Starting Wt library download..."
    
    check_git
    
    if check_existing_wt; then
        download_wt
        verify_download
        
        print_success "Wt library download completed successfully!"
    else
        print_status "Wt library already available"
    fi
}

# Run main function
main "$@"
