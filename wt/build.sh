#!/bin/bash
# Script to build the Wt library using configuration files
# Usage: ./scripts/libs/wt/build.sh [config_file_path]

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common variables and functions
source "$SCRIPT_DIR/../../variables.sh"

# Script-specific variables
LOG_FILE="$OUTPUT_DIR/build_wt.log"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Clear the log file for this run
> "$LOG_FILE"

# Colorized help function (REQUIRED)
show_usage() {
    echo -e "${BOLD}${BLUE}Usage:${NC} $0 [config_file_path]"
    echo ""
    echo -e "${BOLD}${GREEN}Description:${NC}"
    echo "  Builds the Wt library from source using configuration files"
    echo "  Uses default configuration if no config file is specified"
    echo ""
    echo -e "${BOLD}${YELLOW}Arguments:${NC}"
    echo -e "  ${CYAN}config_file_path${NC}          Path to configuration file (optional)"
    echo -e "                                Default: $SCRIPT_DIR/build_configurations/default.conf"
    echo ""
    echo -e "${BOLD}${YELLOW}Available Configurations:${NC}"
    if [ -d "$SCRIPT_DIR/build_configurations" ]; then
        for config_file in "$SCRIPT_DIR/build_configurations"/*.conf; do
            if [ -f "$config_file" ]; then
                local basename=$(basename "$config_file" .conf)
                echo -e "  ${CYAN}$basename${NC}                    $(basename "$config_file")"
            fi
        done
    fi
    echo ""
    echo -e "${BOLD}${YELLOW}Examples:${NC}"
    echo -e "  ${GREEN}$0${NC}                          # Use default configuration"
    echo -e "  ${GREEN}$0 debug.conf${NC}              # Use debug configuration"
    echo -e "  ${GREEN}$0 /path/to/custom.conf${NC}    # Use custom configuration file"
}

# Configuration file path
CONFIG_FILE=""

# Default build settings (will be overridden by config file)
BUILD_TYPE="Release"
INSTALL_PREFIX="/usr/local"
JOBS="auto"
CLEAN_BUILD="false"
DRY_RUN="false"
VERBOSE="false"

# Library configuration - defaults
SHARED_LIBS="ON"
MULTI_THREADED="ON"

# Database backends - defaults
ENABLE_SQLITE="ON"
ENABLE_POSTGRES="ON"
ENABLE_MYSQL="OFF"
ENABLE_FIREBIRD="OFF"
ENABLE_MSSQLSERVER="OFF"

# Security & Graphics - defaults
ENABLE_SSL="ON"
ENABLE_HARU="ON"
ENABLE_PANGO="ON"
ENABLE_OPENGL="ON"
ENABLE_SAML="OFF"

# Qt integration - defaults
ENABLE_QT4="ON"
ENABLE_QT5="OFF"
ENABLE_QT6="OFF"

# Libraries & Components - defaults
ENABLE_LIBWTDBO="ON"
ENABLE_LIBWTTEST="ON"
ENABLE_UNWIND="OFF"

# Installation options - defaults
BUILD_EXAMPLES="ON"
INSTALL_EXAMPLES="OFF"
INSTALL_DOCUMENTATION="OFF"
INSTALL_RESOURCES="ON"
INSTALL_THEMES="ON"

# Development options
DEBUG_JS="OFF"

# Advanced options
ADDITIONAL_CMAKE_ARGS=""

LIBS_DIR="$PROJECT_ROOT/libs"
WT_SOURCE_DIR="$LIBS_DIR/wt"
# BUILD_DIR will be set after configuration is loaded

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            # Treat as config file path
            CONFIG_FILE="$1"
            shift
            ;;
    esac
done

# Load configuration from file if specified
load_config_file() {
    # Default configuration file path
    local DEFAULT_CONFIG_FILE="$SCRIPT_DIR/build_configurations/default.conf"
    
    # Determine which config file to use
    if [ -z "$CONFIG_FILE" ]; then
        # No config file specified, use default
        if [ -f "$DEFAULT_CONFIG_FILE" ]; then
            CONFIG_FILE="$DEFAULT_CONFIG_FILE"
            print_status "Using default configuration file: $(basename "$CONFIG_FILE")"
        else
            print_warning "Default configuration file not found: $DEFAULT_CONFIG_FILE"
            print_status "Using built-in defaults"
            return 0
        fi
    else
        # Config file specified, resolve path
        if [ ! -f "$CONFIG_FILE" ]; then
            # Try relative to build_configurations directory
            local relative_config="$SCRIPT_DIR/build_configurations/$CONFIG_FILE"
            if [ -f "$relative_config" ]; then
                CONFIG_FILE="$relative_config"
            elif [ -f "$SCRIPT_DIR/build_configurations/${CONFIG_FILE}.conf" ]; then
                CONFIG_FILE="$SCRIPT_DIR/build_configurations/${CONFIG_FILE}.conf"
            else
                print_error "Configuration file not found: $CONFIG_FILE"
                print_error "Also tried: $relative_config"
                print_error "Also tried: $SCRIPT_DIR/build_configurations/${CONFIG_FILE}.conf"
                exit 1
            fi
        fi
        print_status "Using configuration file: $(basename "$CONFIG_FILE")"
    fi
    
    # Load the configuration file
    if [ -f "$CONFIG_FILE" ]; then
        print_status "Loading configuration from: $CONFIG_FILE"
        
        # Source the configuration file
        source "$CONFIG_FILE"
        
        # Handle special cases for numeric values
        if [ "$JOBS" = "auto" ]; then
            JOBS=$(nproc 2>/dev/null || echo "4")
        fi
        
        # Convert string boolean values to actual booleans for scripts
        case "$CLEAN_BUILD" in
            "true"|"TRUE"|"1") CLEAN_BUILD=true ;;
            *) CLEAN_BUILD=false ;;
        esac
        
        case "$DRY_RUN" in
            "true"|"TRUE"|"1") DRY_RUN=true ;;
            *) DRY_RUN=false ;;
        esac
        
        case "$VERBOSE" in
            "true"|"TRUE"|"1") VERBOSE=true ;;
            *) VERBOSE=false ;;
        esac
        
        print_success "Configuration loaded successfully"
    else
        print_error "Failed to load configuration file: $CONFIG_FILE"
        exit 1
    fi
}

# Set build directory based on configuration file
set_build_directory() {
    local config_basename=""
    
    if [ -n "$CONFIG_FILE" ]; then
        config_basename=$(basename "$CONFIG_FILE" .conf)
    fi
    
    # If no configuration file specified, use default
    if [ -z "$config_basename" ]; then
        config_basename="default"
    fi
    
    # All builds go in subdirectories named after the configuration
    BUILD_DIR="$WT_SOURCE_DIR/build/$config_basename"
    print_status "Using configuration-specific build directory: build/$config_basename/"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Wt source exists
    if [ ! -d "$WT_SOURCE_DIR" ]; then
        print_error "Wt source not found at: $WT_SOURCE_DIR"
        print_status "Please run: ./scripts/libs/wt/download.sh"
        exit 1
    fi
    
    if [ ! -f "$WT_SOURCE_DIR/CMakeLists.txt" ]; then
        print_error "Invalid Wt source directory (CMakeLists.txt not found)"
        exit 1
    fi
    
    # Check essential tools
    local missing_tools=()
    
    if ! command -v cmake &> /dev/null; then
        missing_tools+=("cmake")
    fi
    
    if ! command -v make &> /dev/null; then
        missing_tools+=("make")
    fi
    
    if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
        missing_tools+=("g++ or clang++")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_status "Please run: ./scripts/dependencies/install_ubuntu.sh"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Prepare build directory
prepare_build_dir() {
    if [ "$CLEAN_BUILD" = true ] && [ -d "$BUILD_DIR" ]; then
        print_warning "Cleaning existing build directory"
        rm -rf "$BUILD_DIR"
    fi
    
    print_status "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
}

# Show configuration summary
show_configuration() {
    echo ""
    print_status "Build Configuration Summary:"
    echo -e "  ${CYAN}Build Type:${NC} $BUILD_TYPE"
    echo -e "  ${CYAN}Install Prefix:${NC} $INSTALL_PREFIX"
    echo -e "  ${CYAN}Parallel Jobs:${NC} $JOBS"
    echo -e "  ${CYAN}Source Directory:${NC} $WT_SOURCE_DIR"
    echo -e "  ${CYAN}Build Directory:${NC} $BUILD_DIR"
    echo ""
    
    echo -e "${BOLD}${YELLOW}Library Configuration:${NC}"
    echo -e "  ${CYAN}Shared Libraries:${NC} $([ "$SHARED_LIBS" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Multi-threaded:${NC} $([ "$MULTI_THREADED" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo ""
    
    echo -e "${BOLD}${YELLOW}Database Backends:${NC}"
    echo -e "  ${CYAN}SQLite:${NC} $([ "$ENABLE_SQLITE" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}PostgreSQL:${NC} $([ "$ENABLE_POSTGRES" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}MySQL/MariaDB:${NC} $([ "$ENABLE_MYSQL" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Firebird:${NC} $([ "$ENABLE_FIREBIRD" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}MS SQL Server:${NC} $([ "$ENABLE_MSSQLSERVER" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo ""
    
    echo -e "${BOLD}${YELLOW}Security & Graphics:${NC}"
    echo -e "  ${CYAN}SSL/TLS:${NC} $([ "$ENABLE_SSL" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Haru PDF:${NC} $([ "$ENABLE_HARU" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Pango Fonts:${NC} $([ "$ENABLE_PANGO" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}OpenGL:${NC} $([ "$ENABLE_OPENGL" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}SAML Auth:${NC} $([ "$ENABLE_SAML" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo ""
    
    echo -e "${BOLD}${YELLOW}Qt Integration:${NC}"
    echo -e "  ${CYAN}Qt4:${NC} $([ "$ENABLE_QT4" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Qt5:${NC} $([ "$ENABLE_QT5" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Qt6:${NC} $([ "$ENABLE_QT6" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo ""
    
    echo -e "${BOLD}${YELLOW}Components:${NC}"
    echo -e "  ${CYAN}Wt::Dbo ORM:${NC} $([ "$ENABLE_LIBWTDBO" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Wt::Test:${NC} $([ "$ENABLE_LIBWTTEST" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}libunwind:${NC} $([ "$ENABLE_UNWIND" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo ""
    
    echo -e "${BOLD}${YELLOW}Installation:${NC}"
    echo -e "  ${CYAN}Build Examples:${NC} $([ "$BUILD_EXAMPLES" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Install Examples:${NC} $([ "$INSTALL_EXAMPLES" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Install Documentation:${NC} $([ "$INSTALL_DOCUMENTATION" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Install Resources:${NC} $([ "$INSTALL_RESOURCES" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo -e "  ${CYAN}Install Themes:${NC} $([ "$INSTALL_THEMES" = "ON" ] && echo "${GREEN}enabled${NC}" || echo "${RED}disabled${NC}")"
    echo ""
    
    if [ "$DEBUG_JS" = "ON" ]; then
        echo -e "${BOLD}${YELLOW}Development:${NC}"
        echo -e "  ${CYAN}Debug JavaScript:${NC} ${GREEN}enabled${NC}"
        echo ""
    fi
    
    if [ -n "$ADDITIONAL_CMAKE_ARGS" ]; then
        echo -e "${BOLD}${YELLOW}Additional CMake Args:${NC}"
        echo -e "  ${CYAN}$ADDITIONAL_CMAKE_ARGS${NC}"
        echo ""
    fi
}

# Configure build with CMake
configure_build() {
    print_status "Configuring Wt build with CMake..."
    
    cd "$BUILD_DIR"
    
    local cmake_args=(
        "-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
        "-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX"
        "-DSHARED_LIBS=$SHARED_LIBS"
        "-DMULTI_THREADED=$MULTI_THREADED"
        
        # Database backends
        "-DENABLE_SQLITE=$ENABLE_SQLITE"
        "-DENABLE_POSTGRES=$ENABLE_POSTGRES"
        "-DENABLE_MYSQL=$ENABLE_MYSQL"
        "-DENABLE_FIREBIRD=$ENABLE_FIREBIRD"
        "-DENABLE_MSSQLSERVER=$ENABLE_MSSQLSERVER"
        
        # Security & Graphics
        "-DENABLE_SSL=$ENABLE_SSL"
        "-DENABLE_HARU=$ENABLE_HARU"
        "-DENABLE_PANGO=$ENABLE_PANGO"
        "-DENABLE_OPENGL=$ENABLE_OPENGL"
        "-DENABLE_SAML=$ENABLE_SAML"
        
        # Qt integration
        "-DENABLE_QT4=$ENABLE_QT4"
        "-DENABLE_QT5=$ENABLE_QT5"
        "-DENABLE_QT6=$ENABLE_QT6"
        
        # Libraries & Components
        "-DENABLE_LIBWTDBO=$ENABLE_LIBWTDBO"
        "-DENABLE_LIBWTTEST=$ENABLE_LIBWTTEST"
        "-DENABLE_UNWIND=$ENABLE_UNWIND"
        
        # Installation options
        "-DBUILD_EXAMPLES=$BUILD_EXAMPLES"
        "-DBUILD_TESTS=$BUILD_TESTS"
        "-DINSTALL_EXAMPLES=$INSTALL_EXAMPLES"
        "-DINSTALL_DOCUMENTATION=$INSTALL_DOCUMENTATION"
        "-DINSTALL_RESOURCES=$INSTALL_RESOURCES"
        "-DINSTALL_THEMES=$INSTALL_THEMES"
        
        # Connector options
        "-DCONNECTOR_HTTP=$CONNECTOR_HTTP"
        "-DCONNECTOR_FCGI=$CONNECTOR_FCGI"
        "-DEXAMPLES_CONNECTOR=$EXAMPLES_CONNECTOR"
        
        # Development options
        "-DDEBUG_JS=$DEBUG_JS"
    )
    
    # Add directory configuration only if values are provided and not default
    if [ -n "$CONFIGDIR" ] && [ "$CONFIGDIR" != "/etc/wt" ]; then
        cmake_args+=("-DCONFIGDIR=$CONFIGDIR")
    fi
    
    if [ -n "$RUNDIR" ] && [ "$RUNDIR" != "/var/run/wt" ]; then
        cmake_args+=("-DRUNDIR=$RUNDIR")  
    fi
    
    if [ -n "$WTHTTP_CONFIGURATION" ] && [ "$WTHTTP_CONFIGURATION" != "/etc/wt/wthttpd" ]; then
        cmake_args+=("-DWTHTTP_CONFIGURATION=$WTHTTP_CONFIGURATION")
    fi
    
    # Add additional CMake arguments if provided
    if [ -n "$ADDITIONAL_CMAKE_ARGS" ]; then
        # Split additional args and add them to array
        IFS=' ' read -ra EXTRA_ARGS <<< "$ADDITIONAL_CMAKE_ARGS"
        cmake_args+=("${EXTRA_ARGS[@]}")
    fi
    
    if [ "$VERBOSE" = true ]; then
        print_status "CMake command:"
        echo "  cmake ${cmake_args[*]} $WT_SOURCE_DIR"
        echo ""
    fi
    
    if cmake "${cmake_args[@]}" "$WT_SOURCE_DIR"; then
        print_success "CMake configuration completed"
    else
        print_error "CMake configuration failed"
        exit 1
    fi
}

# Build Wt
build_wt() {
    print_status "Building Wt library..."
    print_status "Using $JOBS parallel jobs"
    
    cd "$BUILD_DIR"
    
    local start_time=$(date +%s)
    local make_args=("-j$JOBS")
    
    if [ "$VERBOSE" = true ]; then
        make_args+=("VERBOSE=1")
    fi
    
    if make "${make_args[@]}"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_success "Wt library built successfully in ${duration}s"
    else
        print_error "Wt library build failed"
        exit 1
    fi
}

# Install Wt (optional)
install_wt() {
    print_status "Installing Wt library to: $INSTALL_PREFIX"
    
    cd "$BUILD_DIR"
    
    # Check if we need sudo for installation
    if [ ! -w "$INSTALL_PREFIX" ] && [ "$EUID" -ne 0 ]; then
        print_warning "Installation requires sudo privileges"
        if sudo make install; then
            print_success "Wt library installed successfully"
        else
            print_error "Wt library installation failed"
            exit 1
        fi
    else
        if make install; then
            print_success "Wt library installed successfully"
        else
            print_error "Wt library installation failed"
            exit 1
        fi
    fi
    
    # Configure system library paths
    configure_library_paths
}

# Configure system library paths for Wt
configure_library_paths() {
    print_status "Configuring system library paths..."
    
    local lib_config_file="/etc/ld.so.conf.d/wt-local.conf"
    local lib_dir="$INSTALL_PREFIX/lib"
    
    # Check if the library directory exists
    if [ ! -d "$lib_dir" ]; then
        print_warning "Library directory not found: $lib_dir"
        return 1
    fi
    
    # Create or update the library configuration file
    if [ ! -f "$lib_config_file" ] || ! grep -q "$lib_dir" "$lib_config_file" 2>/dev/null; then
        print_status "Adding $lib_dir to system library path..."
        
        if [ "$EUID" -ne 0 ]; then
            # Need sudo to create/modify system configuration
            if echo "$lib_dir" | sudo tee "$lib_config_file" > /dev/null; then
                print_success "Created library configuration: $lib_config_file"
            else
                print_error "Failed to create library configuration file"
                return 1
            fi
        else
            # Running as root
            if echo "$lib_dir" > "$lib_config_file"; then
                print_success "Created library configuration: $lib_config_file"
            else
                print_error "Failed to create library configuration file"
                return 1
            fi
        fi
    else
        print_status "Library path already configured in: $lib_config_file"
    fi
    
    # Update the system library cache
    print_status "Updating system library cache..."
    if [ "$EUID" -ne 0 ]; then
        if sudo ldconfig; then
            print_success "System library cache updated successfully"
        else
            print_warning "Failed to update library cache - libraries may not be found"
            return 1
        fi
    else
        if ldconfig; then
            print_success "System library cache updated successfully"
        else
            print_warning "Failed to update library cache - libraries may not be found"
            return 1
        fi
    fi
    
    # Verify that Wt libraries are now findable
    if ldconfig -p | grep -q "libwt"; then
        print_success "Wt libraries are now available system-wide"
        
        # Show which Wt libraries are available
        echo ""
        print_status "Available Wt libraries:"
        ldconfig -p | grep "libwt" | while read -r line; do
            echo -e "  ${CYAN}$line${NC}"
        done
        echo ""
    else
        print_warning "Wt libraries may not be properly configured in system path"
    fi
}

# Show build summary
show_build_summary() {
    echo ""
    print_status "Build Summary:"
    echo -e "  ${CYAN}Build completed successfully${NC}"
    echo -e "  ${CYAN}Build directory:${NC} $BUILD_DIR"
    echo -e "  ${CYAN}Install prefix:${NC} $INSTALL_PREFIX"
    echo ""
    
    if [ -d "$BUILD_DIR" ]; then
        local lib_files=($(find "$BUILD_DIR" -name "libwt*" -type f 2>/dev/null))
        if [ ${#lib_files[@]} -gt 0 ]; then
            echo -e "  ${CYAN}Built Libraries:${NC}"
            for lib in "${lib_files[@]}"; do
                local size=$(du -h "$lib" 2>/dev/null | cut -f1 || echo "unknown")
                echo -e "    $(basename "$lib") (${size})"
            done
            echo ""
        fi
        
        if [ "$BUILD_EXAMPLES" = "ON" ] && [ -d "$BUILD_DIR/examples" ]; then
            local example_count=$(find "$BUILD_DIR/examples" -type f -executable 2>/dev/null | wc -l)
            if [ "$example_count" -gt 0 ]; then
                echo -e "  ${CYAN}Built Examples:${NC} $example_count"
                echo ""
            fi
        fi
    fi
}

# Main execution
main() {
    print_status "Starting Wt library build..."
    
    # Load configuration file
    load_config_file
    
    # Set build directory based on configuration
    set_build_directory
    
    # Show configuration
    show_configuration
    
    # Exit early if dry run
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run mode - exiting without building"
        exit 0
    fi
    
    # Perform the build
    check_prerequisites
    prepare_build_dir
    configure_build
    build_wt
    
    show_build_summary
    
    print_success "Wt library build completed successfully!"

}

# Run main function
main "$@"
