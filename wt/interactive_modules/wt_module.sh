#!/bin/bash
# Wt Library Management Module for Interactive Scripts
# This module contains all Wt-specific functionality for the interactive system (excluding build configuration)

# Get the module directory for proper path resolution
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_SCRIPT_DIR="$(dirname "$MODULE_DIR")"  # Go up to scripts/ directory

# ===================================================================
# Wt Menu System
# ===================================================================

# Show Wt library management menu
wt_show_menu() {
    local wt_options=(
        "Run Examples"
        "Download Library"
        "Build Library"
        "Install Library (System-wide)"
        "Uninstall Library (System-wide)"
    )
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Wt Library Management${NC}"
        echo ""
        echo -e "${MAGENTA}Available Operations:${NC}"
        echo ""
        
        for i in "${!wt_options[@]}"; do
            local status=""
            local option="${wt_options[$i]}"
            local is_disabled=false
            
            # Add status indicators
            case $i in
                0)  # Run Examples
                    if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                        status=" ${DIM}(${RED}Not Downloaded${DIM})${NC}"
                        is_disabled=true
                    else
                        # Check for examples in configuration-specific build directory
                        local config_basename=$(basename "$WT_CURRENT_CONFIG" .conf)
                        local config_build_dir="$PROJECT_ROOT/libs/wt/build/$config_basename"
                        if [ -f "$config_build_dir/examples/hello/hello.wt" ]; then
                            status=" ${DIM}(${GREEN}Available${DIM})${NC}"
                        else
                            status=" ${DIM}(${YELLOW}Build Required${DIM})${NC}"
                        fi
                    fi
                    ;;
                1)  # Download
                    if [ -d "$PROJECT_ROOT/libs/wt" ]; then
                        status=" ${DIM}(${GREEN}Downloaded${DIM})${NC}"
                    else
                        status=" ${DIM}(${YELLOW}Not Downloaded${DIM})${NC}"
                    fi
                    ;;
                2)  # Build
                    if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                        status=" ${DIM}(${RED}Not Downloaded${DIM})${NC}"
                        is_disabled=true
                    else
                        local build_script="$MODULE_SCRIPT_DIR/libs/wt/build.sh"
                        status=" ${DIM}($(check_script_status "$build_script"))${NC}"
                        
                        # Check for configuration-specific build directory
                        local config_basename=$(basename "$WT_CURRENT_CONFIG" .conf)
                        local config_build_dir="$PROJECT_ROOT/libs/wt/build/$config_basename"
                        if [ -d "$config_build_dir" ]; then
                            status=" ${DIM}(${GREEN}Built${DIM})${NC}"
                        fi
                    fi
                    ;;
                3)  # Install
                    if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                        status=" ${DIM}(${RED}Not Downloaded${DIM})${NC}"
                        is_disabled=true
                    elif wt_check_system_installation; then
                        status=" ${DIM}(${GREEN}Installed${DIM})${NC}"
                    else
                        # Check for configuration-specific build directory
                        local config_basename=$(basename "$WT_CURRENT_CONFIG" .conf)
                        local config_build_dir="$PROJECT_ROOT/libs/wt/build/$config_basename"
                        if [ -d "$config_build_dir" ]; then
                            status=" ${DIM}(${YELLOW}Ready to Install${DIM})${NC}"
                        else
                            status=" ${DIM}(${RED}Build Required${DIM})${NC}"
                        fi
                    fi
                    ;;
                4)  # Uninstall
                    if wt_check_system_installation; then
                        status=" ${DIM}(${YELLOW}Can Uninstall${DIM})${NC}"
                    else
                        status=" ${DIM}(${GREEN}Not Installed${DIM})${NC}"
                        is_disabled=true
                    fi
                    ;;
            esac
            
            # Display the menu item with appropriate formatting
            if [ $i -eq $selected ]; then
                if [ "$is_disabled" = true ]; then
                    echo -e "${DIM}→ $option${NC}$status"
                else
                    echo -e "${BOLD}${GREEN}→ $option${NC}$status"
                fi
            else
                if [ "$is_disabled" = true ]; then
                    echo -e "${DIM}  $option$status${NC}"
                else
                    echo -e "  $option$status"
                fi
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ↑/↓ arrows to navigate, Enter to select, 'q' to go back${NC}"
        
        # Show additional help if install option is disabled
        if wt_check_system_installation && wt_check_version_mismatch; then
            echo ""
            echo -e "${YELLOW}ℹ${NC} ${DIM}Install option disabled due to version mismatch. Use Uninstall first.${NC}"
        fi
        
        read -n 1 -s key
        case $key in
            $'\033')  # ESC sequence for arrow keys
                read -n 2 -s rest
                case $rest in
                    '[A')  # Up arrow
                        if [ $selected -gt 0 ]; then
                            selected=$((selected - 1))
                        fi
                        ;;
                    '[B')  # Down arrow
                        if [ $selected -lt $((${#wt_options[@]} - 1)) ]; then
                            selected=$((selected + 1))
                        fi
                        ;;
                esac
                ;;
            '')  # Enter key
                # Check if the selected item is disabled
                local is_item_disabled=false
                case $selected in
                    0)  # Run Examples
                        if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                            is_item_disabled=true
                        fi
                        ;;
                    2)  # Build Library
                        if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                            is_item_disabled=true
                        fi
                        ;;
                    3)  # Install Library
                        if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                            is_item_disabled=true
                        fi
                        ;;
                    4)  # Uninstall Library
                        if ! wt_check_system_installation; then
                            is_item_disabled=true
                        fi
                        ;;
                esac
                
                if [ "$is_item_disabled" = true ]; then
                    # Flash a message for disabled items
                    echo ""
                    case $selected in
                        0|2|3)  # Library dependent options
                            echo -e "${RED}This option requires the library to be downloaded first.${NC}"
                            echo -e "${YELLOW}Please download the library first (option 2).${NC}"
                            ;;
                        4)  # Uninstall option
                            echo -e "${RED}This option requires Wt to be installed system-wide.${NC}"
                            echo -e "${YELLOW}Nothing to uninstall.${NC}"
                            ;;
                    esac
                    sleep 2
                else
                    wt_handle_selection $selected
                fi
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Handle Wt menu selections
wt_handle_selection() {
    local selection="$1"
    
    case $selection in
        0)  # Run Examples
            wt_examples_menu
            ;;
        1)  # Download Library
            execute_script "Wt Library Download" "$MODULE_SCRIPT_DIR/libs/wt/download.sh"
            ;;
        2)  # Build
            if [ ! -d "$PROJECT_ROOT/libs/wt" ]; then
                show_error_page "Library not downloaded" "Please download the library first (option 2)"
                return
            fi
            wt_show_build_config_selection_menu
            ;;
        3)  # Install
            # Check for version mismatch first
            if wt_check_system_installation && wt_check_version_mismatch; then
                show_error_page "Version Mismatch Detected" "Cannot install when there's a version mismatch. Please uninstall the existing system installation first, then try installing again."
                return
            fi
            
            wt_show_install_build_selection_menu
            ;;
        4)  # Uninstall Library
            wt_execute_uninstall
            ;;
    esac
}

# ===================================================================
# Build Execution
# ===================================================================

# Execute build with current configuration
wt_execute_build_with_config() {
    local build_script="$MODULE_SCRIPT_DIR/libs/wt/build.sh"
    local config_path="$WT_CONFIG_DIR/$WT_CURRENT_CONFIG"
    
    # Check if configuration is set
    if [ -z "$WT_CURRENT_CONFIG" ] || [ ! -f "$config_path" ]; then
        show_error_page "No Configuration Selected" "Please configure build settings first."
        echo ""
        echo -e "${YELLOW}To configure build settings:${NC}"
        echo -e "1. Go back to main menu"
        echo -e "2. Select 'Configuration Management'"
        echo -e "3. Configure your build settings"
        wait_for_input
        return 1
    fi
    
    print_status "Executing build with configuration: $(basename "$WT_CURRENT_CONFIG" .conf)"
    execute_script "Wt Library Build ($(basename "$WT_CURRENT_CONFIG" .conf))" "$build_script" "$config_path"
}

# Show build selection menu for installation
wt_show_install_build_selection_menu() {
    # Find all available built configurations
    local build_dirs=()
    local config_names=()
    
    if [ -d "$PROJECT_ROOT/libs/wt/build" ]; then
        for build_dir in "$PROJECT_ROOT/libs/wt/build"/*; do
            if [ -d "$build_dir" ] && [ -f "$build_dir/Makefile" ]; then
                local config_name=$(basename "$build_dir")
                build_dirs+=("$build_dir")
                config_names+=("$config_name")
            fi
        done
    fi
    
    if [ ${#config_names[@]} -eq 0 ]; then
        show_error_page "No built configurations found" "Please build Wt with at least one configuration first (option 2)"
        return 1
    fi
    
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Select Build Configuration to Install${NC}"
        echo ""
        echo -e "${MAGENTA}Available Built Configurations:${NC}"
        echo ""
        
        for i in "${!config_names[@]}"; do
            local config_name="${config_names[$i]}"
            local build_dir="${build_dirs[$i]}"
            
            # Get build information
            local build_info=""
            if [ -f "$build_dir/CMakeCache.txt" ]; then
                local build_type=$(grep "CMAKE_BUILD_TYPE:STRING=" "$build_dir/CMakeCache.txt" 2>/dev/null | cut -d'=' -f2)
                local shared_libs=$(grep "SHARED_LIBS:BOOL=" "$build_dir/CMakeCache.txt" 2>/dev/null | cut -d'=' -f2)
                local lib_type="$([ "$shared_libs" = "ON" ] && echo "Shared" || echo "Static")"
                build_info=" ${DIM}(${build_type:-Release}, ${lib_type} libs)${NC}"
            fi
            
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}$config_name${NC}$build_info"
            else
                echo -e "    $config_name$build_info"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to install selected configuration, ${CYAN}q${DIM} to return${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')  # Arrow key sequence
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#config_names[@]}) % ${#config_names[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#config_names[@]} )) ;;
                esac
                ;;
            '')  # Enter key
                wt_execute_install_with_config "${config_names[$selected]}"
                return $?
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Execute Wt library installation with specific configuration
wt_execute_install_with_config() {
    local config_name="$1"
    local config_build_dir="$PROJECT_ROOT/libs/wt/build/$config_name"
    local config_file="$MODULE_SCRIPT_DIR/libs/wt/build_configurations/$config_name.conf"
    
    show_header
    echo -e "${BOLD}${BLUE}Install Wt Library System-wide${NC}"
    echo -e "${BOLD}${YELLOW}Configuration: $config_name${NC}"
    echo ""
    
    if [ ! -d "$config_build_dir" ]; then
        show_error_page "Build directory not found for configuration '$config_name'" "Please build this configuration first"
        return 1
    fi
    
    # Show installation information
    local install_prefix="/usr/local"
    if [ -f "$config_file" ]; then
        install_prefix=$(grep "INSTALL_PREFIX=" "$config_file" | cut -d'=' -f2 | tr -d '"')
    fi
    
    echo -e "${YELLOW}Installation Details:${NC}"
    echo -e "  • Configuration: ${CYAN}$config_name${NC}"
    echo -e "  • Build directory: ${CYAN}build/$config_name${NC}"
    echo -e "  • Install location: ${CYAN}$install_prefix${NC}"
    echo -e "  • Libraries will be copied to: ${CYAN}$install_prefix/lib${NC}"
    echo -e "  • Headers will be copied to: ${CYAN}$install_prefix/include${NC}"
    echo -e "  • CMake files will be copied to: ${CYAN}$install_prefix/lib/cmake/wt${NC}"
    echo -e "  • Library paths will be configured system-wide"
    echo ""
    
    if ! confirm_action "This will install Wt system-wide using the '$config_name' configuration. Continue?" true; then
        print_status "Installation cancelled."
        wait_for_input
        return 0
    fi
    
    # Run the installation
    print_status "Installing Wt library (configuration: $config_name)..."
    echo ""
    
    # Change to the specific build directory and run make install
    cd "$config_build_dir"
    if sudo make install; then
        print_success "Wt library installed successfully!"
        echo ""
        echo -e "${GREEN}Installation completed using configuration: $config_name${NC}"
        
        # Update ldconfig to recognize new libraries
        print_status "Updating library cache..."
        sudo ldconfig
        
        print_success "Library installation completed successfully!"
    else
        print_error "Installation failed!"
        echo ""
        print_status "Make sure you have sufficient permissions and all dependencies are installed."
    fi
    
    wait_for_input
}

# Execute Wt library installation (legacy function - kept for compatibility)
wt_execute_install() {
    # Use current configuration for legacy compatibility
    local config_basename=$(basename "$WT_CURRENT_CONFIG" .conf)
    wt_execute_install_with_config "$config_basename"
}

# Uninstall Wt library system-wide
wt_execute_uninstall() {
    show_header
    echo -e "${BOLD}${BLUE}Uninstall Wt Library System-wide${NC}"
    echo ""
    
    # Check if Wt is installed
    if ! wt_check_system_installation; then
        print_warning "Wt library does not appear to be installed system-wide."
        wait_for_input
        return 0
    fi
    
    # Show version information if available
    local system_version=$(wt_get_system_version)
    local local_version=$(wt_get_local_version)
    
    echo -e "${YELLOW}Current Installation:${NC}"
    echo -e "  • System version: ${CYAN}$system_version${NC}"
    echo -e "  • Local build version: ${CYAN}$local_version${NC}"
    echo ""
    
    # Warn about consequences
    echo -e "${RED}⚠️  Warning: This will remove Wt from your system${NC}"
    echo -e "${YELLOW}Files that will be removed:${NC}"
    echo -e "  • Libraries from /usr/local/lib/ and /usr/lib/"
    echo -e "  • Headers from /usr/local/include/Wt/"
    echo -e "  • Shared resources from /usr/local/share/Wt/"
    echo -e "  • CMake files from /usr/local/lib/cmake/wt/"
    echo -e "  • pkg-config files"
    echo -e "  • System library path configuration"
    echo ""
    echo -e "${YELLOW}Note: This may affect other applications that depend on Wt${NC}"
    echo ""
    
    if ! confirm_action "Are you sure you want to uninstall Wt system-wide?" false; then
        print_status "Uninstallation cancelled."
        wait_for_input
        return 0
    fi
    
    # Execute the dedicated uninstall script
    local uninstall_script="$MODULE_SCRIPT_DIR/libs/wt/uninstall.sh"
    
    if [ -f "$uninstall_script" ]; then
        print_status "Executing dedicated uninstall script..."
        echo ""
        
        # Run the uninstall script with force mode (since we already confirmed)
        if bash "$uninstall_script" --force --verbose 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Uninstall script completed successfully!"
        else
            print_error "Uninstall script failed!"
            echo ""
            echo -e "${YELLOW}You can try running the script manually:${NC}"
            echo -e "${GREEN}bash $uninstall_script --help${NC}"
        fi
    else
        print_error "Uninstall script not found: $uninstall_script"
        print_status "Falling back to basic manual removal..."
        wt_manual_uninstall_fallback
    fi
    
    wait_for_input
}

# Fallback manual uninstall (simplified version for emergencies)
wt_manual_uninstall_fallback() {
    print_status "Performing fallback manual uninstall..."
    
    # Basic cleanup of common locations
    local prefixes=("/usr/local" "/usr")
    
    for prefix in "${prefixes[@]}"; do
        print_status "Cleaning $prefix..."
        
        # Remove main directories
        if [ -d "$prefix/include/Wt" ]; then
            print_status "Removing headers: $prefix/include/Wt"
            sudo rm -rf "$prefix/include/Wt" 2>/dev/null || print_warning "Failed to remove headers"
        fi
        
        if [ -d "$prefix/share/Wt" ]; then
            print_status "Removing shared resources: $prefix/share/Wt"
            sudo rm -rf "$prefix/share/Wt" 2>/dev/null || print_warning "Failed to remove shared resources"
        fi
        
        if [ -d "$prefix/lib/cmake/wt" ]; then
            print_status "Removing CMake files: $prefix/lib/cmake/wt"
            sudo rm -rf "$prefix/lib/cmake/wt" 2>/dev/null || print_warning "Failed to remove CMake files"
        fi
        
        # Remove libraries (basic approach)
        if sudo find "$prefix/lib" -name "libwt*" -type f 2>/dev/null | head -1 >/dev/null; then
            print_status "Removing Wt libraries from $prefix/lib"
            sudo find "$prefix/lib" -name "libwt*" -delete 2>/dev/null || print_warning "Some libraries may not have been removed"
        fi
    done
    
    # Update library cache
    print_status "Updating library cache..."
    sudo ldconfig 2>/dev/null || print_warning "Failed to update library cache"
    
    print_success "Fallback uninstall completed"
}

# Check if Wt is installed system-wide
wt_check_system_installation() {
    # Check for Wt library files in common system locations
    local common_locations=(
        "/usr/local/lib/libwt.so"
        "/usr/lib/libwt.so"
        "/usr/local/lib/x86_64-linux-gnu/libwt.so"
        "/usr/lib/x86_64-linux-gnu/libwt.so"
    )
    
    for location in "${common_locations[@]}"; do
        if [ -f "$location" ]; then
            return 0
        fi
    done
    
    # Also check using pkg-config
    if pkg-config --exists wt 2>/dev/null; then
        return 0
    fi
    
    # Check using ldconfig
    if ldconfig -p 2>/dev/null | grep -q "libwt\.so"; then
        return 0
    fi
    
    return 1
}

# Get system-installed Wt version
wt_get_system_version() {
    local version=""
    
    # Try pkg-config first
    if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists wt 2>/dev/null; then
        version=$(pkg-config --modversion wt 2>/dev/null)
        if [ -n "$version" ]; then
            echo "$version"
            return 0
        fi
    fi
    
    # Try to extract version from library files
    local common_locations=(
        "/usr/local/lib/libwt.so"
        "/usr/lib/libwt.so"
        "/usr/local/lib/x86_64-linux-gnu/libwt.so"
        "/usr/lib/x86_64-linux-gnu/libwt.so"
    )
    
    for location in "${common_locations[@]}"; do
        if [ -f "$location" ]; then
            # Try to extract version from symlink or filename
            version=$(readlink "$location" 2>/dev/null | grep -oP 'libwt\.so\.\K[0-9]+\.[0-9]+\.[0-9]+' || echo "")
            if [ -n "$version" ]; then
                echo "$version"
                return 0
            fi
        fi
    done
    
    # Try to find version in include headers
    local header_locations=(
        "/usr/local/include/Wt/WConfig.h"
        "/usr/include/Wt/WConfig.h"
    )
    
    for header in "${header_locations[@]}"; do
        if [ -f "$header" ]; then
            version=$(grep -E "#define WT_VERSION_STR" "$header" 2>/dev/null | cut -d'"' -f2)
            if [ -n "$version" ]; then
                echo "$version"
                return 0
            fi
        fi
    done
    
    echo "Unknown"
    return 1
}

# Get local build Wt version
wt_get_local_version() {
    local version=""
    
    # Check all built configurations for version info
    local build_dirs=()
    if [ -d "$PROJECT_ROOT/libs/wt/build" ]; then
        for build_dir in "$PROJECT_ROOT/libs/wt/build"/*; do
            if [ -d "$build_dir" ] && [ -f "$build_dir/Makefile" ]; then
                build_dirs+=("$build_dir")
            fi
        done
    fi
    
    # If we have specific build directories, check them first
    for build_dir in "${build_dirs[@]}"; do
        # Check WConfig.h in build directory
        if [ -f "$build_dir/Wt/WConfig.h" ]; then
            version=$(grep -E "#define WT_VERSION_STR" "$build_dir/Wt/WConfig.h" 2>/dev/null | cut -d'"' -f2)
            if [ -n "$version" ] && [ "$version" != "Unknown" ]; then
                echo "$version"
                return 0
            fi
        fi
        
        # Check CMakeCache.txt for version info
        if [ -f "$build_dir/CMakeCache.txt" ]; then
            version=$(grep -E "CMAKE_PROJECT_VERSION:STATIC=" "$build_dir/CMakeCache.txt" 2>/dev/null | cut -d'=' -f2)
            if [ -n "$version" ] && [ "$version" != "Unknown" ]; then
                echo "$version"
                return 0
            fi
        fi
    done
    
    # Fallback: Check legacy build directory
    if [ -f "$PROJECT_ROOT/libs/wt/build/CMakeCache.txt" ]; then
        version=$(grep -E "CMAKE_PROJECT_VERSION:STATIC=" "$PROJECT_ROOT/libs/wt/build/CMakeCache.txt" 2>/dev/null | cut -d'=' -f2)
        if [ -n "$version" ] && [ "$version" != "Unknown" ]; then
            echo "$version"
            return 0
        fi
    fi
    
    # Check WConfig.h in legacy build directory
    if [ -f "$PROJECT_ROOT/libs/wt/build/Wt/WConfig.h" ]; then
        version=$(grep -E "#define WT_VERSION_STR" "$PROJECT_ROOT/libs/wt/build/Wt/WConfig.h" 2>/dev/null | cut -d'"' -f2)
        if [ -n "$version" ] && [ "$version" != "Unknown" ]; then
            echo "$version"
            return 0
        fi
    fi
    
    # Last resort: Parse CMakeLists.txt for version components
    if [ -f "$PROJECT_ROOT/libs/wt/CMakeLists.txt" ]; then
        local version_series=$(grep -E "SET\(VERSION_SERIES" "$PROJECT_ROOT/libs/wt/CMakeLists.txt" 2>/dev/null | grep -oP '[0-9]+')
        local version_major=$(grep -E "SET\(VERSION_MAJOR" "$PROJECT_ROOT/libs/wt/CMakeLists.txt" 2>/dev/null | grep -oP '[0-9]+')
        local version_minor=$(grep -E "SET\(VERSION_MINOR" "$PROJECT_ROOT/libs/wt/CMakeLists.txt" 2>/dev/null | grep -oP '[0-9]+')
        
        if [ -n "$version_series" ] && [ -n "$version_major" ] && [ -n "$version_minor" ]; then
            version="${version_series}.${version_major}.${version_minor}"
            echo "$version"
            return 0
        fi
    fi
    
    echo "Unknown"
    return 1
}

# Check for version mismatch between system and local build
wt_check_version_mismatch() {
    if ! wt_check_system_installation; then
        return 1  # No system installation
    fi
    
    local system_version=$(wt_get_system_version)
    local local_version=$(wt_get_local_version)
    
    if [ "$system_version" = "Unknown" ] || [ "$local_version" = "Unknown" ]; then
        return 2  # Version unknown
    fi
    
    if [ "$system_version" != "$local_version" ]; then
        return 0  # Mismatch detected
    fi
    
    return 1  # No mismatch
}

# ===================================================================
# Status and Information Display
# ===================================================================

# Show detailed installation status
wt_show_installation_status() {
    show_header
    echo -e "${BOLD}${BLUE}Wt Library Installation Status${NC}"
    echo ""
    
    # Merged Wt Library Source and Build Status
    echo -e "${MAGENTA}Wt Library Source & Build Status:${NC}"
    if [ -d "$PROJECT_ROOT/libs/wt" ]; then
        echo -e "  ${GREEN}✓${NC} Downloaded to: ${CYAN}$PROJECT_ROOT/libs/wt${NC}"
        
        if [ -d "$PROJECT_ROOT/libs/wt/.git" ]; then
            cd "$PROJECT_ROOT/libs/wt"
            local last_commit=$(git log -1 --format='%h - %s (%cr)' 2>/dev/null || echo "Unknown")
            echo -e "  ${BLUE}ℹ${NC} Last commit: ${DIM}$last_commit${NC}"
        fi
        
        # Check build status
        if [ -d "$PROJECT_ROOT/libs/wt/build" ]; then
            echo -e "  ${GREEN}✓${NC} Build directory exists: ${CYAN}$PROJECT_ROOT/libs/wt/build${NC}"
            
            # Check for built libraries
            local lib_count=$(find "$PROJECT_ROOT/libs/wt/build" -name "*.so" -o -name "*.a" -o -name "*.dylib" 2>/dev/null | wc -l)
            if [ "$lib_count" -gt 0 ]; then
                echo -e "  ${GREEN}✓${NC} Found $lib_count built library files"
            else
                echo -e "  ${YELLOW}!${NC} Build directory exists but no libraries found"
            fi
            
            # Check for examples
            if [ -d "$PROJECT_ROOT/libs/wt/build/examples" ]; then
                local example_count=$(find "$PROJECT_ROOT/libs/wt/build/examples" -type f -executable 2>/dev/null | wc -l)
                echo -e "  ${GREEN}✓${NC} Found $example_count built examples"
            fi
        else
            echo -e "  ${YELLOW}!${NC} Not built - ${YELLOW}Use option 3 to build${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} Not downloaded"
        echo -e "    ${YELLOW}Use option 2 to download${NC}"
    fi
    echo ""
    
    # Check system installation status
    echo -e "${MAGENTA}System Installation:${NC}"
    if wt_check_system_installation; then
        echo -e "  ${GREEN}✓${NC} Wt library installed system-wide"
        
        # Try multiple methods to get version information
        local wt_version="Unknown"
        
        # Method 1: pkg-config (most reliable if available)
        if pkg-config --exists wt 2>/dev/null; then
            wt_version=$(pkg-config --modversion wt 2>/dev/null || echo "Unknown")
            echo -e "  ${BLUE}ℹ${NC} Version: $wt_version (via pkg-config)"
            local wt_libdir=$(pkg-config --variable=libdir wt 2>/dev/null || echo "Unknown")
            if [ "$wt_libdir" != "Unknown" ]; then
                echo -e "  ${BLUE}ℹ${NC} Library path: $wt_libdir"
            fi
        else
            # Method 2: Extract version from library filename
            for location in "/usr/local/lib" "/usr/lib" "/usr/local/lib/x86_64-linux-gnu" "/usr/lib/x86_64-linux-gnu"; do
                if [ -f "$location/libwt.so" ]; then
                    # Look for versioned library files
                    local versioned_lib=$(find "$location" -name "libwt.so.*" 2>/dev/null | head -1)
                    if [ -n "$versioned_lib" ]; then
                        wt_version=$(basename "$versioned_lib" | sed 's/libwt\.so\.//')
                        echo -e "  ${BLUE}ℹ${NC} Version: $wt_version (detected from library)"
                        break
                    fi
                fi
            done
        fi
        
        # Check for library files in common locations
        local found_libs=()
        for location in "/usr/local/lib" "/usr/lib" "/usr/local/lib/x86_64-linux-gnu" "/usr/lib/x86_64-linux-gnu"; do
            if [ -f "$location/libwt.so" ]; then
                found_libs+=("$location")
            fi
        done
        
        if [ ${#found_libs[@]} -gt 0 ]; then
            echo -e "  ${BLUE}ℹ${NC} Found libraries in: ${CYAN}${found_libs[0]}${NC}"
            
            # Show additional library details
            if [ ${#found_libs[@]} -gt 1 ]; then
                echo -e "  ${BLUE}ℹ${NC} Additional locations: ${#found_libs[@]} total"
            fi
        fi
    else
        echo -e "  ${RED}✗${NC} Not installed system-wide"
        echo -e "    ${YELLOW}Use option 3 to install after building${NC}"
    fi
    echo ""
    
    # Show system dependencies status
    echo -e "${MAGENTA}System Dependencies Status:${NC}"
    dependencies_show_status_overview
    echo ""
    
    wait_for_input
}

# ===================================================================
# Public Interface Functions
# ===================================================================

# Initialize the Wt module
wt_module_init() {
    print_status "Initializing Wt module..."
    print_success "Wt module initialized"
}

# Main Wt menu entry point
wt_main_menu() {
    wt_show_menu
}

# Get Wt library status
wt_get_status() {
    local status=""
    local warning=""
    
    if [ -d "$PROJECT_ROOT/libs/wt" ]; then
        if [ -d "$PROJECT_ROOT/libs/wt/build" ]; then
            if wt_check_system_installation; then
                status="Downloaded, Built & Installed"
                
                # Check for version mismatch
                if wt_check_version_mismatch; then
                    warning=" (⚠ Version Mismatch)"
                fi
            else
                status="Downloaded & Built"
            fi
        else
            status="Downloaded"
        fi
    else
        status="Not Downloaded"
    fi
    
    echo "${status}${warning}"
}
