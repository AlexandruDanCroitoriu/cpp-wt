#!/bin/bash
# Wt Build Configuration Module for Interactive Scripts
# This module contains all build configuration functionality for the Wt library

# ===================================================================
# Build Configuration Variables
# ===================================================================

# Module-specific configuration
WT_CONFIG_DIR="$SCRIPT_DIR/libs/wt/build_configurations"
WT_CURRENT_CONFIG="default.conf"
declare -A WT_BUILD_CONFIG

# ===================================================================
# Build Configuration Management
# ===================================================================

# Load build configuration from file
wt_load_build_config() {
    local config_file="$WT_CONFIG_DIR/$WT_CURRENT_CONFIG"
    
    # Initialize with defaults
    WT_BUILD_CONFIG=(
        ["BUILD_TYPE"]="Release"
        ["INSTALL_PREFIX"]="/usr/local"
        ["JOBS"]="auto"
        ["CLEAN_BUILD"]="false"
        ["SHARED_LIBS"]="ON"
        ["MULTI_THREADED"]="ON"
        ["ENABLE_SQLITE"]="ON"
        ["ENABLE_POSTGRES"]="ON"
        ["ENABLE_MYSQL"]="OFF"
        ["ENABLE_FIREBIRD"]="OFF"
        ["ENABLE_MSSQLSERVER"]="OFF"
        ["ENABLE_SSL"]="ON"
        ["ENABLE_HARU"]="ON"
        ["ENABLE_PANGO"]="ON"
        ["ENABLE_OPENGL"]="ON"
        ["ENABLE_SAML"]="OFF"
        ["ENABLE_QT4"]="ON"
        ["ENABLE_QT5"]="OFF"
        ["ENABLE_QT6"]="OFF"
        ["ENABLE_LIBWTDBO"]="ON"
        ["ENABLE_LIBWTTEST"]="ON"
        ["ENABLE_UNWIND"]="OFF"
        ["BUILD_EXAMPLES"]="ON"
        ["BUILD_TESTS"]="OFF"
        ["INSTALL_EXAMPLES"]="OFF"
        ["INSTALL_DOCUMENTATION"]="OFF"
        ["INSTALL_RESOURCES"]="ON"
        ["INSTALL_THEMES"]="ON"
        ["CONNECTOR_HTTP"]="ON"
        ["CONNECTOR_FCGI"]="OFF"
        ["EXAMPLES_CONNECTOR"]="wthttp"
        ["CONFIGDIR"]="/etc/wt"
        ["RUNDIR"]="/var/run/wt"
        ["WTHTTP_CONFIGURATION"]="/etc/wt/wthttpd"
        ["DEBUG_JS"]="OFF"
        ["ADDITIONAL_CMAKE_ARGS"]=""
        ["DRY_RUN"]="false"
        ["VERBOSE"]="false"
    )
    
    # Load from file if it exists
    if [ -f "$config_file" ]; then
        print_status "Loading build configuration from: $(basename "$config_file")"
        
        # Read the config file and populate WT_BUILD_CONFIG
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ ! "$key" =~ ^[[:space:]]*# ]] && [[ -n "$key" ]] && [[ -n "$value" ]]; then
                # Remove quotes from value if present
                value=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')
                WT_BUILD_CONFIG["$key"]="$value"
            fi
        done < "$config_file"
        
        print_success "Build configuration loaded"
    else
        print_warning "Configuration file not found, using defaults"
        wt_save_build_config  # Create default configuration file
    fi
}

# Save build configuration to file
wt_save_build_config() {
    local config_file="$WT_CONFIG_DIR/$WT_CURRENT_CONFIG"
    
    print_status "Saving build configuration to: $(basename "$config_file")"
    
    # Create directory if it doesn't exist
    mkdir -p "$WT_CONFIG_DIR"
    
    # Write configuration to file
    cat > "$config_file" << EOF
# Wt Library Build Configuration - $(basename "$config_file" .conf)
# This file contains build configuration settings for the Wt library
# Edit these values to customize your build or use the interactive script

# Build Configuration
BUILD_TYPE="${WT_BUILD_CONFIG[BUILD_TYPE]}"
INSTALL_PREFIX="${WT_BUILD_CONFIG[INSTALL_PREFIX]}"
JOBS="${WT_BUILD_CONFIG[JOBS]}"
CLEAN_BUILD="${WT_BUILD_CONFIG[CLEAN_BUILD]}"

# Library Options
SHARED_LIBS="${WT_BUILD_CONFIG[SHARED_LIBS]}"
MULTI_THREADED="${WT_BUILD_CONFIG[MULTI_THREADED]}"

# Database Backends
ENABLE_SQLITE="${WT_BUILD_CONFIG[ENABLE_SQLITE]}"
ENABLE_POSTGRES="${WT_BUILD_CONFIG[ENABLE_POSTGRES]}"
ENABLE_MYSQL="${WT_BUILD_CONFIG[ENABLE_MYSQL]}"
ENABLE_FIREBIRD="${WT_BUILD_CONFIG[ENABLE_FIREBIRD]}"
ENABLE_MSSQLSERVER="${WT_BUILD_CONFIG[ENABLE_MSSQLSERVER]}"

# Security & Graphics
ENABLE_SSL="${WT_BUILD_CONFIG[ENABLE_SSL]}"
ENABLE_HARU="${WT_BUILD_CONFIG[ENABLE_HARU]}"
ENABLE_PANGO="${WT_BUILD_CONFIG[ENABLE_PANGO]}"
ENABLE_OPENGL="${WT_BUILD_CONFIG[ENABLE_OPENGL]}"
ENABLE_SAML="${WT_BUILD_CONFIG[ENABLE_SAML]}"

# Qt Integration
ENABLE_QT4="${WT_BUILD_CONFIG[ENABLE_QT4]}"
ENABLE_QT5="${WT_BUILD_CONFIG[ENABLE_QT5]}"
ENABLE_QT6="${WT_BUILD_CONFIG[ENABLE_QT6]}"

# Libraries & Components
ENABLE_LIBWTDBO="${WT_BUILD_CONFIG[ENABLE_LIBWTDBO]}"
ENABLE_LIBWTTEST="${WT_BUILD_CONFIG[ENABLE_LIBWTTEST]}"
ENABLE_UNWIND="${WT_BUILD_CONFIG[ENABLE_UNWIND]}"

# Installation Options
BUILD_EXAMPLES="${WT_BUILD_CONFIG[BUILD_EXAMPLES]}"
BUILD_TESTS="${WT_BUILD_CONFIG[BUILD_TESTS]}"
INSTALL_EXAMPLES="${WT_BUILD_CONFIG[INSTALL_EXAMPLES]}"
INSTALL_DOCUMENTATION="${WT_BUILD_CONFIG[INSTALL_DOCUMENTATION]}"
INSTALL_RESOURCES="${WT_BUILD_CONFIG[INSTALL_RESOURCES]}"
INSTALL_THEMES="${WT_BUILD_CONFIG[INSTALL_THEMES]}"

# Connector Options
CONNECTOR_HTTP="${WT_BUILD_CONFIG[CONNECTOR_HTTP]}"
CONNECTOR_FCGI="${WT_BUILD_CONFIG[CONNECTOR_FCGI]}"
EXAMPLES_CONNECTOR="${WT_BUILD_CONFIG[EXAMPLES_CONNECTOR]}"

# Directory Configuration
CONFIGDIR="${WT_BUILD_CONFIG[CONFIGDIR]}"
RUNDIR="${WT_BUILD_CONFIG[RUNDIR]}"
WTHTTP_CONFIGURATION="${WT_BUILD_CONFIG[WTHTTP_CONFIGURATION]}"

# Development Options
DEBUG_JS="${WT_BUILD_CONFIG[DEBUG_JS]}"

# Advanced Options
ADDITIONAL_CMAKE_ARGS="${WT_BUILD_CONFIG[ADDITIONAL_CMAKE_ARGS]}"
DRY_RUN="${WT_BUILD_CONFIG[DRY_RUN]}"
VERBOSE="${WT_BUILD_CONFIG[VERBOSE]}"
EOF
    
    print_success "Build configuration saved"
}

# List available configuration files
wt_list_config_files() {
    local configs=()
    
    if [ -d "$WT_CONFIG_DIR" ]; then
        for config_file in "$WT_CONFIG_DIR"/*.conf; do
            if [ -f "$config_file" ]; then
                configs+=($(basename "$config_file"))
            fi
        done
    fi
    
    printf '%s\n' "${configs[@]}"
}

# ===================================================================
# Configuration Selection Menu
# ===================================================================

# Show configuration selection menu for building
wt_show_build_config_selection_menu() {
    local configs=($(wt_list_config_files))
    local config_selected=0
    local action_selected=0
    local menu_mode="config"  # "config" or "action"
    
    if [ ${#configs[@]} -eq 0 ]; then
        show_header
        echo -e "${RED}No configuration files found!${NC}"
        echo ""
        echo -e "${YELLOW}Creating default configuration...${NC}"
        wt_save_build_config
        configs=($(wt_list_config_files))
    fi
    
    local actions=(
        "b - Build with selected configuration"
        "w - Wipe (clean) selected configuration build folder"
    )
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Select Configuration for Building${NC}"
        echo ""
        echo -e "${MAGENTA}Available Configurations:${NC}"
        echo ""
        
        for i in "${!configs[@]}"; do
            local config_name="${configs[$i]}"
            local config_basename=$(basename "$config_name" .conf)
            local build_status=""
            
            # Check if this configuration has been built
            local config_build_dir="$PROJECT_ROOT/libs/wt/build/$config_basename"
            if [ -d "$config_build_dir" ]; then
                build_status=" ${DIM}(${GREEN}built${DIM})${NC}"
            else
                build_status=" ${DIM}(${YELLOW}not built${DIM})${NC}"
            fi
            
            if [ $i -eq $config_selected ] && [ "$menu_mode" = "config" ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}$config_basename${NC}$build_status"
            else
                echo -e "    $config_basename$build_status"
            fi
        done
        
        echo ""
        echo -e "${BOLD}${YELLOW}Actions:${NC}"
        echo ""
        
        for i in "${!actions[@]}"; do
            if [ $i -eq $action_selected ] && [ "$menu_mode" = "action" ]; then
                echo -e "  ${GREEN}▶${NC} ${actions[$i]}"
            else
                echo -e "    ${actions[$i]}"
            fi
        done
        
        echo ""
        if [ "$menu_mode" = "config" ]; then
            echo -e "${DIM}Use ↑/↓ to select configuration, Tab to switch to actions, Enter to edit, 'q' to go back${NC}"
            echo -e "${DIM}Quick actions: 'b' build, 'w' wipe${NC}"
        else
            echo -e "${DIM}Use ↑/↓ to select action, Tab to switch to configurations, Enter to execute, 'q' to go back${NC}"
        fi
        echo ""
        
        read -n 1 -s key
        case $key in
            $'\033')  # ESC sequence for arrow keys
                read -n 2 -s rest
                case $rest in
                    '[A')  # Up arrow
                        if [ "$menu_mode" = "config" ]; then
                            if [ $config_selected -gt 0 ]; then
                                config_selected=$((config_selected - 1))
                            fi
                        else
                            if [ $action_selected -gt 0 ]; then
                                action_selected=$((action_selected - 1))
                            fi
                        fi
                        ;;
                    '[B')  # Down arrow
                        if [ "$menu_mode" = "config" ]; then
                            if [ $config_selected -lt $((${#configs[@]} - 1)) ]; then
                                config_selected=$((config_selected + 1))
                            fi
                        else
                            if [ $action_selected -lt $((${#actions[@]} - 1)) ]; then
                                action_selected=$((action_selected + 1))
                            fi
                        fi
                        ;;
                esac
                ;;
            $'\t')  # Tab key - switch between config and action selection
                if [ "$menu_mode" = "config" ]; then
                    menu_mode="action"
                else
                    menu_mode="config"
                fi
                ;;
            '')  # Enter key
                if [ "$menu_mode" = "config" ]; then
                    # Edit selected configuration (default action when selecting a config)
                    echo -e "${YELLOW}DEBUG: Enter pressed on config, about to edit configuration${NC}"
                    local temp_current_config="$WT_CURRENT_CONFIG"
                    WT_CURRENT_CONFIG="${configs[$config_selected]}"
                    wt_load_build_config
                    print_status "Editing configuration: $(basename "$WT_CURRENT_CONFIG" .conf)"
                    echo -e "${YELLOW}DEBUG: About to call wt_show_build_configuration_menu${NC}"
                    wt_show_build_configuration_menu
                    echo -e "${YELLOW}DEBUG: Returned from wt_show_build_configuration_menu${NC}"
                    # Restore previous current config after editing
                    WT_CURRENT_CONFIG="$temp_current_config"
                    wt_load_build_config
                else
                    # Execute selected action
                    case $action_selected in
                        0)  # Build with selected configuration
                            local selected_config="${configs[$config_selected]}"
                            local temp_current_config="$WT_CURRENT_CONFIG"
                            
                            # Temporarily switch to selected config for building
                            WT_CURRENT_CONFIG="$selected_config"
                            wt_load_build_config
                            
                            print_status "Building with configuration: $(basename "$selected_config" .conf)"
                            
                            # Execute the build
                            local build_script="$SCRIPT_DIR/libs/wt/build.sh"
                            local config_path="$WT_CONFIG_DIR/$selected_config"
                            execute_script "Wt Library Build ($(basename "$selected_config" .conf))" "$build_script" "$config_path"
                            
                            # Restore previous current config
                            WT_CURRENT_CONFIG="$temp_current_config"
                            wt_load_build_config
                            
                            return 0
                            ;;
                        1)  # Wipe (clean) selected configuration build folder
                            config_basename=$(basename "${configs[$config_selected]}" .conf)
                            wt_config_wipe_build "$config_basename"
                            # Switch back to config selection after wipe
                            menu_mode="config"
                            ;;
                    esac
                fi
                ;;
            'w'|'W')  # Wipe build directory (single key shortcut)
                if [ "$menu_mode" = "config" ] && [ ${#configs[@]} -gt 0 ]; then
                    config_basename=$(basename "${configs[$config_selected]}" .conf)
                    wt_config_wipe_build "$config_basename"
                fi
                ;;
            'b'|'B')  # Build with selected configuration (single key shortcut)
                if [ "$menu_mode" = "config" ]; then
                    local selected_config="${configs[$config_selected]}"
                    local temp_current_config="$WT_CURRENT_CONFIG"
                    
                    # Temporarily switch to selected config for building
                    WT_CURRENT_CONFIG="$selected_config"
                    wt_load_build_config
                    
                    print_status "Building with configuration: $(basename "$selected_config" .conf)"
                    
                    # Execute the build
                    local build_script="$SCRIPT_DIR/libs/wt/build.sh"
                    local config_path="$WT_CONFIG_DIR/$selected_config"
                    execute_script "Wt Library Build ($(basename "$selected_config" .conf))" "$build_script" "$config_path"
                    
                    # Restore previous current config
                    WT_CURRENT_CONFIG="$temp_current_config"
                    wt_load_build_config
                    
                    return 0
                fi
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# ===================================================================
# Build Configuration Menu System
# ===================================================================

# Show build configuration menu
wt_show_build_configuration_menu() {
    echo -e "${YELLOW}DEBUG: wt_show_build_configuration_menu called${NC}"
    local config_categories=(
        "Build Type & Libraries"
        "Database Backends"
        "Security & Graphics"
        "Qt Integration"
        "Components & Examples"
        "Connector & Deployment"
        "Reset to Defaults"
    )
    local selected=0
    local category_descriptions=(
        "Configure build type, library type, and threading options"
        "Select which database backends to include in the build"
        "Configure security, PDF generation, fonts, and graphics features"
        "Enable or disable Qt5/Qt6 integration capabilities"
        "Choose components and example applications to build"
        "Configure HTTP/FastCGI connectors and deployment paths"
        "Reset all settings to their default values"
    )
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Wt Build Configuration${NC}"
        echo ""
        echo -e "${MAGENTA}Configuration Categories:${NC}"
        echo ""
        
        for i in "${!config_categories[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${config_categories[$i]}${NC}"
            else
                echo -e "    ${config_categories[$i]}"
            fi
        done
        
        echo ""
        echo -e "${DIM}Current Configuration Summary:${NC}"
        echo -e "  ${CYAN}Build Type:${NC} ${WT_BUILD_CONFIG[BUILD_TYPE]}"
        echo -e "  ${CYAN}Libraries:${NC} $([ "${WT_BUILD_CONFIG[SHARED_LIBS]}" = "ON" ] && echo "Shared" || echo "Static")"
        echo -e "  ${CYAN}SSL:${NC} ${WT_BUILD_CONFIG[ENABLE_SSL]}"
        echo -e "  ${CYAN}Databases:${NC} SQLite:${WT_BUILD_CONFIG[ENABLE_SQLITE]} PG:${WT_BUILD_CONFIG[ENABLE_POSTGRES]} MySQL:${WT_BUILD_CONFIG[ENABLE_MYSQL]}"
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to select, ${CYAN}q${DIM} to return${NC}"
        echo ""
        
        # Show description for selected category
        echo -e "${DIM}${category_descriptions[$selected]}${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')  # Arrow key sequence
                read -s -n 2 key
                case "$key" in
                    '[A') # Up arrow
                        selected=$(( (selected - 1 + ${#config_categories[@]}) % ${#config_categories[@]} ))
                        ;;
                    '[B') # Down arrow  
                        selected=$(( (selected + 1) % ${#config_categories[@]} ))
                        ;;
                esac
                ;;
            '') # Enter key
                wt_handle_config_selection $selected
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Handle configuration category selection
wt_handle_config_selection() {
    local selection="$1"
    
    case $selection in
        0)  # Build Type & Libraries
            wt_show_build_type_config
            ;;
        1)  # Database Backends
            wt_show_database_config
            ;;
        2)  # Security & Graphics
            wt_show_security_graphics_config
            ;;
        3)  # Qt Integration
            wt_show_qt_config
            ;;
        4)  # Components & Examples
            wt_show_components_config
            ;;
        5)  # Connector & Deployment
            wt_show_connector_deployment_config
            ;;
        6)  # Reset to Defaults
            wt_reset_to_defaults
            ;;
    esac
}

# ===================================================================
# Configuration Category Menus
# ===================================================================

# Build Type & Libraries configuration
wt_show_build_type_config() {
    local options=(
        "Build Type"
        "Library Type"
        "Multi-threading"
    )
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Build Type & Libraries Configuration${NC}"
        echo ""
        
        for i in "${!options[@]}"; do
            local value=""
            local description=""
            case $i in
                0) 
                    value="${WT_BUILD_CONFIG[BUILD_TYPE]}"
                    case "$value" in
                        "Release") description="Optimized for performance, no debug info" ;;
                        "Debug") description="Unoptimized with full debug information" ;;
                        "RelWithDebInfo") description="Optimized but includes debug symbols" ;;
                        "MinSizeRel") description="Optimized for smallest binary size" ;;
                    esac
                    ;;
                1) 
                    value="$([ "${WT_BUILD_CONFIG[SHARED_LIBS]}" = "ON" ] && echo "Shared" || echo "Static")"
                    if [ "${WT_BUILD_CONFIG[SHARED_LIBS]}" = "ON" ]; then
                        description="Dynamic libraries (.so) - smaller executables, runtime dependencies"
                    else
                        description="Static libraries (.a) - larger executables, no runtime dependencies"
                    fi
                    ;;
                2) 
                    value="${WT_BUILD_CONFIG[MULTI_THREADED]}"
                    if [ "${WT_BUILD_CONFIG[MULTI_THREADED]}" = "ON" ]; then
                        description="Enable concurrent request handling and thread safety"
                    else
                        description="Single-threaded mode - simpler but limited concurrency"
                    fi
                    ;;
            esac
            
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${options[$i]}:${NC} ${CYAN}$value${NC}"
            else
                echo -e "    ${options[$i]}: $value"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to toggle, ${CYAN}q${DIM} to return${NC}"
        echo ""
        
        # Show description for selected option
        case $selected in
            0)
                case "${WT_BUILD_CONFIG[BUILD_TYPE]}" in
                    "Release") echo -e "${DIM}Optimized for performance, no debug info${NC}" ;;
                    "Debug") echo -e "${DIM}Unoptimized with full debug information${NC}" ;;
                    "RelWithDebInfo") echo -e "${DIM}Optimized but includes debug symbols${NC}" ;;
                    "MinSizeRel") echo -e "${DIM}Optimized for smallest binary size${NC}" ;;
                esac
                ;;
            1)
                if [ "${WT_BUILD_CONFIG[SHARED_LIBS]}" = "ON" ]; then
                    echo -e "${DIM}Dynamic libraries (.so) - smaller executables, runtime dependencies${NC}"
                else
                    echo -e "${DIM}Static libraries (.a) - larger executables, no runtime dependencies${NC}"
                fi
                ;;
            2)
                if [ "${WT_BUILD_CONFIG[MULTI_THREADED]}" = "ON" ]; then
                    echo -e "${DIM}Enable concurrent request handling and thread safety${NC}"
                else
                    echo -e "${DIM}Single-threaded mode - simpler but limited concurrency${NC}"
                fi
                ;;
        esac
        
        read -s -n 1 key
        case "$key" in
            $'\e')
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#options[@]} )) ;;
                esac
                ;;
            '')
                case $selected in
                    0) wt_toggle_build_type ;;
                    1) wt_toggle_library_type ;;
                    2) wt_toggle_multi_threading ;;
                esac
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Database configuration
wt_show_database_config() {
    local options=(
        "SQLite"
        "PostgreSQL"
        "MySQL/MariaDB"
        "Firebird"
        "MS SQL Server"
    )
    local descriptions=(
        "Lightweight embedded SQL database engine, perfect for development"
        "Advanced open-source relational database with strong standards compliance"
        "Popular open-source relational database, compatible with MariaDB"
        "Cross-platform SQL relational database management system"
        "Microsoft's enterprise-grade relational database management system"
    )
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Database Backends Configuration${NC}"
        echo ""
        
        for i in "${!options[@]}"; do
            local key=""
            case $i in
                0) key="ENABLE_SQLITE" ;;
                1) key="ENABLE_POSTGRES" ;;
                2) key="ENABLE_MYSQL" ;;
                3) key="ENABLE_FIREBIRD" ;;
                4) key="ENABLE_MSSQLSERVER" ;;
            esac
            
            local status_color=""
            if [ "${WT_BUILD_CONFIG[$key]}" = "ON" ]; then
                status_color="${GREEN}ENABLED${NC}"
            else
                status_color="${RED}DISABLED${NC}"
            fi
            
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${options[$i]}:${NC} $status_color"
            else
                echo -e "    ${options[$i]}: $status_color"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to toggle, ${CYAN}q${DIM} to return${NC}"
        echo ""
        
        # Show description for selected option
        echo -e "${DIM}${descriptions[$selected]}${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#options[@]} )) ;;
                esac
                ;;
            '')
                case $selected in
                    0) wt_toggle_config "ENABLE_SQLITE" ;;
                    1) wt_toggle_config "ENABLE_POSTGRES" ;;
                    2) wt_toggle_config "ENABLE_MYSQL" ;;
                    3) wt_toggle_config "ENABLE_FIREBIRD" ;;
                    4) wt_toggle_config "ENABLE_MSSQLSERVER" ;;
                esac
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Security & Graphics configuration
wt_show_security_graphics_config() {
    local options=(
        "SSL Support"
        "PDF Generation (Haru)"
        "Font Rendering (Pango)"
        "OpenGL Support"
    )
    local descriptions=(
        "Enable SSL/TLS support for secure HTTPS connections"
        "Enable Haru PDF library for server-side PDF generation"
        "Enable Pango for advanced font rendering and text layout"
        "Enable OpenGL support for hardware-accelerated graphics"
    )
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Security & Graphics Configuration${NC}"
        echo ""
        
        for i in "${!options[@]}"; do
            local key=""
            case $i in
                0) key="ENABLE_SSL" ;;
                1) key="ENABLE_HARU" ;;
                2) key="ENABLE_PANGO" ;;
                3) key="ENABLE_OPENGL" ;;
            esac
            
            local status_color=""
            if [ "${WT_BUILD_CONFIG[$key]}" = "ON" ]; then
                status_color="${GREEN}ENABLED${NC}"
            else
                status_color="${RED}DISABLED${NC}"
            fi
            
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${options[$i]}:${NC} $status_color"
            else
                echo -e "    ${options[$i]}: $status_color"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to toggle, ${CYAN}q${DIM} to return${NC}"
        echo ""
        
        # Show description for selected option
        echo -e "${DIM}${descriptions[$selected]}${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#options[@]} )) ;;
                esac
                ;;
            '')
                case $selected in
                    0) wt_toggle_config "ENABLE_SSL" ;;
                    1) wt_toggle_config "ENABLE_HARU" ;;
                    2) wt_toggle_config "ENABLE_PANGO" ;;
                    3) wt_toggle_config "ENABLE_OPENGL" ;;
                esac
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Qt Integration configuration
wt_show_qt_config() {
    local options=(
        "Qt4 Integration"
        "Qt5 Integration"
        "Qt6 Integration"
    )
    local descriptions=(
        "Enable Qt4 integration (deprecated, will disable Qt5/Qt6)"
        "Enable Qt5 integration (will disable Qt4/Qt6)"
        "Enable Qt6 integration (newer, will disable Qt4/Qt5)"
    )
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Qt Integration Configuration${NC}"
        echo -e "${DIM}Note: Only one Qt version can be enabled at a time${NC}"
        echo ""
        
        for i in "${!options[@]}"; do
            local key=""
            case $i in
                0) key="ENABLE_QT4" ;;
                1) key="ENABLE_QT5" ;;
                2) key="ENABLE_QT6" ;;
            esac
            
            local status_color=""
            if [ "${WT_BUILD_CONFIG[$key]}" = "ON" ]; then
                status_color="${GREEN}ENABLED${NC}"
            else
                status_color="${RED}DISABLED${NC}"
            fi
            
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${options[$i]}:${NC} $status_color"
            else
                echo -e "    ${options[$i]}: $status_color"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to toggle, ${CYAN}q${DIM} to return${NC}"
        echo ""
        
        # Show description for selected option
        echo -e "${DIM}${descriptions[$selected]}${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#options[@]} )) ;;
                esac
                ;;
            '')
                case $selected in
                    0) wt_toggle_qt_version "ENABLE_QT4" ;;
                    1) wt_toggle_qt_version "ENABLE_QT5" ;;
                    2) wt_toggle_qt_version "ENABLE_QT6" ;;
                esac
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Components & Examples configuration
wt_show_components_config() {
    local options=(
        "Build Examples"
        "Build Tests"
        "DBO Library"
        "Test Library"
        "Unwind Library"
        "Install Examples"
        "Install Documentation"
        "Install Resources"
        "Install Themes"
    )
    local descriptions=(
        "Build example applications to demonstrate Wt features"
        "Build unit tests for Wt library (requires Boost.Test)"
        "Build Wt::Dbo - Object Relational Mapping library"
        "Build Wt::Test - Testing framework for Wt applications"
        "Enable libunwind for enhanced stack traces and debugging"
        "Install built example applications to system directory"
        "Install Wt API documentation (requires Doxygen)"
        "Install Wt web resources (CSS, JS files) to system directory"
        "Install Wt built-in themes (Bootstrap, Polaris) to system directory"
    )
    local selected=0
    
    while true; do
        show_header
        echo -e "${BOLD}${BLUE}Components & Examples Configuration${NC}"
        echo ""
        
        for i in "${!options[@]}"; do
            local key=""
            case $i in
                0) key="BUILD_EXAMPLES" ;;
                1) key="BUILD_TESTS" ;;
                2) key="ENABLE_LIBWTDBO" ;;
                3) key="ENABLE_LIBWTTEST" ;;
                4) key="ENABLE_UNWIND" ;;
                5) key="INSTALL_EXAMPLES" ;;
                6) key="INSTALL_DOCUMENTATION" ;;
                7) key="INSTALL_RESOURCES" ;;
                8) key="INSTALL_THEMES" ;;
            esac
            
            local status_color=""
            if [ "${WT_BUILD_CONFIG[$key]}" = "ON" ]; then
                status_color="${GREEN}ENABLED${NC}"
            else
                status_color="${RED}DISABLED${NC}"
            fi
            
            if [ $i -eq $selected ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${options[$i]}:${NC} $status_color"
            else
                echo -e "    ${options[$i]}: $status_color"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ${CYAN}↑/↓${DIM} to navigate, ${CYAN}Enter${DIM} to toggle, ${CYAN}q${DIM} to return${NC}"
        echo ""
        
        # Show description for selected option
        echo -e "${DIM}${descriptions[$selected]}${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#options[@]} )) ;;
                esac
                ;;
            '')
                case $selected in
                    0) wt_toggle_config "BUILD_EXAMPLES" ;;
                    1) wt_toggle_config "BUILD_TESTS" ;;
                    2) wt_toggle_config "ENABLE_LIBWTDBO" ;;
                    3) wt_toggle_config "ENABLE_LIBWTTEST" ;;
                    4) wt_toggle_config "ENABLE_UNWIND" ;;
                    5) wt_toggle_config "INSTALL_EXAMPLES" ;;
                    6) wt_toggle_config "INSTALL_DOCUMENTATION" ;;
                    7) wt_toggle_config "INSTALL_RESOURCES" ;;
                    8) wt_toggle_config "INSTALL_THEMES" ;;
                esac
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Connector & Deployment Configuration Menu
wt_show_connector_deployment_config() {
    local selected=0
    local options=(
        "CONNECTOR_HTTP ${GREEN}(HTTP Connector)${NC}"
        "CONNECTOR_FCGI ${GREEN}(FastCGI Connector)${NC}"
        "EXAMPLES_CONNECTOR ${GREEN}(Examples Connector)${NC}"
        "CONFIGDIR ${GREEN}(Config Directory)${NC}"
        "RUNDIR ${GREEN}(Runtime Directory)${NC}"
        "WTHTTP_CONFIGURATION ${GREEN}(HTTP Config File)${NC}"
    )
    
    while true; do
        clear
        echo -e "${HEADER_SEPARATOR}"
        echo -e "${CYAN}Wt Build Configuration - Connector & Deployment${NC}"
        echo -e "${HEADER_SEPARATOR}"
        echo
        
        for i in "${!options[@]}"; do
            local option_name="${options[i]%% *}"
            local option_desc="${options[i]#* }"
            local status_color=${RED}
            local status="OFF"
            
            # Get current value from config
            local current_value=$(wt_get_config_value "$option_name")
            
            if [[ "$option_name" == "CONFIGDIR" || "$option_name" == "RUNDIR" || "$option_name" == "WTHTTP_CONFIGURATION" ]]; then
                # Directory/file options show the path
                if [[ -n "$current_value" ]]; then
                    status_color=${GREEN}
                    status="$current_value"
                else
                    status_color=${RED}
                    status="DEFAULT"
                fi
            else
                # Boolean options
                if [[ "$current_value" == "ON" ]]; then
                    status_color=${GREEN}
                    status="ON"
                fi
            fi
            
            if [[ $i -eq $selected ]]; then
                echo -e "  ${YELLOW}►${NC} $option_desc - ${status_color}$status${NC}"
            else
                echo -e "    $option_desc - ${status_color}$status${NC}"
            fi
        done
        
        echo
        echo -e "${YELLOW}Use arrow keys to navigate, Enter to toggle, 'q' to go back${NC}"
        
        read -s -n 1 key
        case "$key" in
            $'\e')
                read -s -n 2 key
                case "$key" in
                    '[A') selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') selected=$(( (selected + 1) % ${#options[@]} )) ;;
                esac
                ;;
            '')
                case $selected in
                    0) wt_toggle_config "CONNECTOR_HTTP" ;;
                    1) wt_toggle_config "CONNECTOR_FCGI" ;;
                    2) wt_toggle_config "EXAMPLES_CONNECTOR" ;;
                    3) wt_prompt_directory_config "CONFIGDIR" "Configuration Directory" "/etc/wt" ;;
                    4) wt_prompt_directory_config "RUNDIR" "Runtime Directory" "/var/run/wt" ;;
                    5) wt_prompt_file_config "WTHTTP_CONFIGURATION" "HTTP Configuration File" "/etc/wt/wthttpd" ;;
                esac
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Directory configuration prompt
wt_prompt_directory_config() {
    local config_name="$1"
    local display_name="$2"
    local default_value="$3"
    
    echo
    echo -e "${CYAN}Configure $display_name${NC}"
    echo -e "Current: ${YELLOW}$(wt_get_config_value "$config_name" || echo "DEFAULT ($default_value)")${NC}"
    echo
    echo -e "Enter new path (or press Enter to use default '$default_value'):"
    read -r new_path
    
    if [[ -z "$new_path" ]]; then
        new_path="$default_value"
    fi
    
    wt_set_config_value "$config_name" "$new_path"
    echo -e "${GREEN}Set $display_name to: $new_path${NC}"
    sleep 1
}

# File configuration prompt
wt_prompt_file_config() {
    local config_name="$1"
    local display_name="$2"
    local default_value="$3"
    
    echo
    echo -e "${CYAN}Configure $display_name${NC}"
    echo -e "Current: ${YELLOW}$(wt_get_config_value "$config_name" || echo "DEFAULT ($default_value)")${NC}"
    echo
    echo -e "Enter new file path (or press Enter to use default '$default_value'):"
    read -r new_path
    
    if [[ -z "$new_path" ]]; then
        new_path="$default_value"
    fi
    
    wt_set_config_value "$config_name" "$new_path"
    echo -e "${GREEN}Set $display_name to: $new_path${NC}"
    sleep 1
}

# Reset configuration to defaults
wt_reset_to_defaults() {
    show_header
    echo -e "${BOLD}${BLUE}Reset Configuration to Defaults${NC}"
    echo ""
    echo -e "${YELLOW}This will reset all configuration settings to their default values.${NC}"
    echo -e "${YELLOW}Current configuration: $(basename "$WT_CURRENT_CONFIG" .conf)${NC}"
    echo ""
    
    if confirm_action "Are you sure you want to reset to defaults?" false; then
        # Reinitialize with defaults by calling load without file
        local temp_config="$WT_CURRENT_CONFIG"
        WT_CURRENT_CONFIG="__temp_nonexistent__.conf"
        wt_load_build_config  # This will use defaults since file doesn't exist
        WT_CURRENT_CONFIG="$temp_config"
        wt_save_build_config  # Save the defaults to the actual file
        
        print_success "Configuration reset to defaults!"
    else
        print_status "Reset cancelled."
    fi
    
    wait_for_input
}

# ===================================================================
# Configuration Toggle Functions
# ===================================================================

# Generic toggle function for ON/OFF settings
wt_toggle_config() {
    local key="$1"
    if [ "${WT_BUILD_CONFIG[$key]}" = "ON" ]; then
        WT_BUILD_CONFIG[$key]="OFF"
    else
        WT_BUILD_CONFIG[$key]="ON"
    fi
    wt_save_build_config
}

# Toggle build type through the cycle
wt_toggle_build_type() {
    case "${WT_BUILD_CONFIG[BUILD_TYPE]}" in
        "Release") WT_BUILD_CONFIG[BUILD_TYPE]="Debug" ;;
        "Debug") WT_BUILD_CONFIG[BUILD_TYPE]="RelWithDebInfo" ;;
        "RelWithDebInfo") WT_BUILD_CONFIG[BUILD_TYPE]="MinSizeRel" ;;
        "MinSizeRel") WT_BUILD_CONFIG[BUILD_TYPE]="Release" ;;
    esac
    wt_save_build_config
}

# Toggle library type between shared and static
wt_toggle_library_type() {
    if [ "${WT_BUILD_CONFIG[SHARED_LIBS]}" = "ON" ]; then
        WT_BUILD_CONFIG[SHARED_LIBS]="OFF"
    else
        WT_BUILD_CONFIG[SHARED_LIBS]="ON"
    fi
    wt_save_build_config
}

# Toggle multi-threading support
wt_toggle_multi_threading() {
    wt_toggle_config "MULTI_THREADED"
}

# Get configuration value
wt_get_config_value() {
    local key="$1"
    echo "${WT_BUILD_CONFIG[$key]}"
}

# Set configuration value
wt_set_config_value() {
    local key="$1"
    local value="$2"
    WT_BUILD_CONFIG[$key]="$value"
    wt_save_build_config
}

# Toggle Qt version with mutual exclusion (only one Qt version can be enabled)
wt_toggle_qt_version() {
    local qt_version="$1"
    
    # If the selected Qt version is currently OFF, enable it and disable others
    if [ "${WT_BUILD_CONFIG[$qt_version]}" = "OFF" ]; then
        # Enable the selected version
        WT_BUILD_CONFIG[$qt_version]="ON"
        
        # Disable all other Qt versions
        case $qt_version in
            "ENABLE_QT4")
                WT_BUILD_CONFIG[ENABLE_QT5]="OFF"
                WT_BUILD_CONFIG[ENABLE_QT6]="OFF"
                ;;
            "ENABLE_QT5")
                WT_BUILD_CONFIG[ENABLE_QT4]="OFF"
                WT_BUILD_CONFIG[ENABLE_QT6]="OFF"
                ;;
            "ENABLE_QT6")
                WT_BUILD_CONFIG[ENABLE_QT4]="OFF"
                WT_BUILD_CONFIG[ENABLE_QT5]="OFF"
                ;;
        esac
    else
        # If the selected Qt version is currently ON, just disable it
        WT_BUILD_CONFIG[$qt_version]="OFF"
    fi
    
    wt_save_build_config
}

# ===================================================================
# Public Interface Functions
# ===================================================================

# Initialize the build configuration module
wt_build_config_init() {
    print_status "Initializing Wt build configuration module..."
    wt_load_build_config
    print_success "Wt build configuration module initialized"
}

# ===================================================================
# Configuration Management Functions
# ===================================================================

# Wipe build folder for selected configuration
wt_config_wipe_build() {
    local config_name="$1"
    local build_dir="$BUILD_DIR/$config_name"
    
    if [ ! -d "$build_dir" ]; then
        show_message "No build directory exists for configuration '$config_name'" "warning"
        return 0
    fi
    
    echo -e "${YELLOW}This will remove the entire build directory for configuration '${BOLD}$config_name${NC}${YELLOW}'${NC}"
    echo -e "${YELLOW}Path: ${CYAN}$build_dir${NC}"
    echo ""
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    
    if confirm_action "Are you sure you want to wipe the build directory?" false; then
        print_status "Wiping build directory: $build_dir"
        
        if rm -rf "$build_dir"; then
            print_success "Build directory wiped successfully"
        else
            print_error "Failed to wipe build directory"
            return 1
        fi
    else
        print_status "Wipe cancelled"
    fi
    
    wait_for_input
    return 0
}

# Delete a configuration file and its build folder
wt_delete_configuration() {
    local config_file="$1"
    local config_basename=$(basename "$config_file" .conf)
    local build_dir="$PROJECT_ROOT/libs/wt/build/$config_basename"
    
    show_header
    echo -e "${BOLD}${RED}Delete Configuration${NC}"
    echo ""
    echo -e "${YELLOW}Configuration to delete:${NC} ${CYAN}$config_basename${NC}"
    echo -e "${YELLOW}Configuration file:${NC} ${CYAN}$config_file${NC}"
    
    if [ -d "$build_dir" ]; then
        echo -e "${YELLOW}Build directory:${NC} ${CYAN}$build_dir${NC}"
        local build_size=$(du -sh "$build_dir" 2>/dev/null | cut -f1 || echo "Unknown")
        echo -e "${YELLOW}Build directory size:${NC} ${CYAN}$build_size${NC}"
    else
        echo -e "${YELLOW}Build directory:${NC} ${DIM}Not found${NC}"
    fi
    
    echo ""
    echo -e "${RED}⚠️  Warning: This action cannot be undone!${NC}"
    echo -e "${YELLOW}The following will be permanently deleted:${NC}"
    echo -e "  • Configuration file: $config_file"
    if [ -d "$build_dir" ]; then
        echo -e "  • Build directory and all compiled files: $build_dir"
    fi
    echo ""
    
    if ! confirm_action "Are you sure you want to delete this configuration?" false; then
        print_status "Deletion cancelled."
        wait_for_input
        return 0
    fi
    
    # Delete the configuration file
    if [ -f "$config_file" ]; then
        if rm "$config_file" 2>/dev/null; then
            print_success "Configuration file deleted: $config_file"
        else
            print_error "Failed to delete configuration file: $config_file"
            wait_for_input
            return 1
        fi
    fi
    
    # Delete the build directory if it exists
    if [ -d "$build_dir" ]; then
        print_status "Removing build directory: $build_dir"
        if rm -rf "$build_dir" 2>/dev/null; then
            print_success "Build directory deleted: $build_dir"
        else
            print_error "Failed to delete build directory: $build_dir"
            wait_for_input
            return 1
        fi
    fi
    
    print_success "Configuration '$config_basename' deleted successfully!"
    
    # If we deleted the current configuration, reset to default
    if [ "$config_file" = "$WT_CONFIG_DIR/$WT_CURRENT_CONFIG" ]; then
        print_status "Deleted configuration was active. Switching to default..."
        WT_CURRENT_CONFIG="default.conf"
        wt_load_build_config
    fi
    
    wait_for_input
}

# Create a new configuration file
wt_create_new_configuration() {
    show_header
    echo -e "${BOLD}${GREEN}Create New Configuration${NC}"
    echo ""
    
    echo -e "${YELLOW}Enter name for new configuration (without .conf extension):${NC}"
    echo -e "${DIM}Examples: release-optimized, debug-minimal, production${NC}"
    echo -n "> "
    read -r new_name
    
    # Validate name
    if [ -z "$new_name" ]; then
        print_error "Configuration name cannot be empty!"
        wait_for_input
        return 1
    fi
    
    # Remove any .conf extension if user added it
    new_name=$(echo "$new_name" | sed 's/\.conf$//')
    
    # Check for invalid characters
    if [[ ! "$new_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Configuration name can only contain letters, numbers, hyphens, and underscores!"
        wait_for_input
        return 1
    fi
    
    local new_config_file="$WT_CONFIG_DIR/${new_name}.conf"
    
    # Check if file already exists
    if [ -f "$new_config_file" ]; then
        print_error "Configuration '$new_name' already exists!"
        wait_for_input
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}Choose base configuration to copy from:${NC}"
    echo ""
    
    # Show available configurations as templates
    local configs=($(find "$WT_CONFIG_DIR" -name "*.conf" -type f | sort))
    local template_options=("Create from scratch (default settings)")
    
    for config in "${configs[@]}"; do
        local basename=$(basename "$config" .conf)
        template_options+=("Copy from: $basename")
    done
    
    local selected_template=0
    
    while true; do
        for i in "${!template_options[@]}"; do
            if [ $i -eq $selected_template ]; then
                echo -e "  ${GREEN}▶${NC} ${BOLD}${template_options[$i]}${NC}"
            else
                echo -e "    ${template_options[$i]}"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ↑/↓ arrows to navigate, Enter to select, 'q' to cancel${NC}"
        
        read -n 1 -s key
        case $key in
            $'\033')  # ESC sequence for arrow keys
                read -n 2 -s rest
                case $rest in
                    '[A')  # Up arrow
                        if [ $selected_template -gt 0 ]; then
                            selected_template=$((selected_template - 1))
                        fi
                        # Clear previous menu
                        for ((j=0; j<${#template_options[@]}+3; j++)); do
                            echo -ne "\033[A\033[K"
                        done
                        ;;
                    '[B')  # Down arrow
                        if [ $selected_template -lt $((${#template_options[@]} - 1)) ]; then
                            selected_template=$((selected_template + 1))
                        fi
                        # Clear previous menu
                        for ((j=0; j<${#template_options[@]}+3; j++)); do
                            echo -ne "\033[A\033[K"
                        done
                        ;;
                esac
                ;;
            '')  # Enter key
                break
                ;;
            'q'|'Q')
                print_status "Configuration creation cancelled."
                wait_for_input
                return 0
                ;;
        esac
    done
    
    # Create the new configuration
    if [ $selected_template -eq 0 ]; then
        # Create from scratch with default settings
        print_status "Creating new configuration with default settings..."
        wt_create_default_config "$new_config_file" "$new_name"
    else
        # Copy from existing configuration
        local source_config="${configs[$((selected_template - 1))]}"
        local source_basename=$(basename "$source_config" .conf)
        print_status "Creating new configuration based on '$source_basename'..."
        
        if cp "$source_config" "$new_config_file"; then
            # Update the header comment in the new file
            sed -i "1s/.*/# Wt Library Build Configuration - $new_name/" "$new_config_file"
            sed -i "2s/.*/# Created from: $source_basename/" "$new_config_file"
        else
            print_error "Failed to copy configuration file!"
            wait_for_input
            return 1
        fi
    fi
    
    if [ -f "$new_config_file" ]; then
        print_success "Configuration '$new_name' created successfully!"
        echo -e "${YELLOW}Configuration file:${NC} ${CYAN}$new_config_file${NC}"
    else
        print_error "Failed to create configuration file!"
    fi
    
    wait_for_input
}

# Create a default configuration file
wt_create_default_config() {
    local config_file="$1"
    local config_name="$2"
    
    cat > "$config_file" << EOF
# Wt Library Build Configuration - $config_name
# Created: $(date)

# Build Configuration
BUILD_TYPE="Release"
INSTALL_PREFIX="/usr/local"
JOBS="auto"
CLEAN_BUILD="true"

# Library Options
SHARED_LIBS="ON"
MULTI_THREADED="ON"

# Database Backends
ENABLE_SQLITE="ON"
ENABLE_POSTGRES="ON"
ENABLE_MYSQL="ON"
ENABLE_FIREBIRD="OFF"
ENABLE_MSSQLSERVER="OFF"

# Security & Graphics
ENABLE_SSL="ON"
ENABLE_HARU="ON"
ENABLE_PANGO="ON"
ENABLE_OPENGL="ON"
ENABLE_SAML="OFF"

# Qt Integration
ENABLE_QT4="OFF"
ENABLE_QT5="ON"
ENABLE_QT6="OFF"

# Libraries & Components
ENABLE_LIBWTDBO="ON"
ENABLE_LIBWTTEST="ON"
ENABLE_UNWIND="ON"

# Installation Options
BUILD_EXAMPLES="ON"
INSTALL_EXAMPLES="ON"
INSTALL_DOCUMENTATION="ON"
INSTALL_RESOURCES="ON"
INSTALL_THEMES="ON"

# Development Options
DEBUG_JS="OFF"

# Advanced Options
ADDITIONAL_CMAKE_ARGS=""
DRY_RUN="false"
EOF
}

# Rename a configuration file and its build folder
wt_rename_configuration() {
    local config_file="$1"
    local config_basename=$(basename "$config_file" .conf)
    local build_dir="$PROJECT_ROOT/libs/wt/build/$config_basename"
    
    show_header
    echo -e "${BOLD}${BLUE}Rename Configuration${NC}"
    echo ""
    echo -e "${YELLOW}Current configuration:${NC} ${CYAN}$config_basename${NC}"
    echo -e "${YELLOW}Configuration file:${NC} ${CYAN}$config_file${NC}"
    
    if [ -d "$build_dir" ]; then
        echo -e "${YELLOW}Build directory:${NC} ${CYAN}$build_dir${NC}"
    else
        echo -e "${YELLOW}Build directory:${NC} ${DIM}Not found${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Enter new name for configuration (without .conf extension):${NC}"
    echo -n "> "
    read -r new_name
    
    # Validate name
    if [ -z "$new_name" ]; then
        print_error "Configuration name cannot be empty!"
        wait_for_input
        return 1
    fi
    
    # Remove any .conf extension if user added it
    new_name=$(echo "$new_name" | sed 's/\.conf$//')
    
    # Check if same name
    if [ "$new_name" = "$config_basename" ]; then
        print_warning "New name is the same as current name. No changes made."
        wait_for_input
        return 0
    fi
    
    # Check for invalid characters
    if [[ ! "$new_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Configuration name can only contain letters, numbers, hyphens, and underscores!"
        wait_for_input
        return 1
    fi
    
    local new_config_file="$WT_CONFIG_DIR/${new_name}.conf"
    local new_build_dir="$PROJECT_ROOT/libs/wt/build/$new_name"
    
    # Check if new name already exists
    if [ -f "$new_config_file" ]; then
        print_error "Configuration '$new_name' already exists!"
        wait_for_input
        return 1
    fi
    
    if [ -d "$new_build_dir" ]; then
        print_error "Build directory '$new_build_dir' already exists!"
        wait_for_input
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}Renaming summary:${NC}"
    echo -e "  ${CYAN}$config_basename${NC} → ${CYAN}$new_name${NC}"
    echo -e "  Config: ${DIM}$config_file${NC} → ${DIM}$new_config_file${NC}"
    if [ -d "$build_dir" ]; then
        echo -e "  Build:  ${DIM}$build_dir${NC} → ${DIM}$new_build_dir${NC}"
    fi
    echo ""
    
    if ! confirm_action "Proceed with renaming?" true; then
        print_status "Renaming cancelled."
        wait_for_input
        return 0
    fi
    
    # Rename the configuration file
    if mv "$config_file" "$new_config_file" 2>/dev/null; then
        print_success "Configuration file renamed"
        
        # Update the header comment in the renamed file
        sed -i "1s/.*/# Wt Library Build Configuration - $new_name/" "$new_config_file"
    else
        print_error "Failed to rename configuration file!"
        wait_for_input
        return 1
    fi
    
    # Rename the build directory if it exists
    if [ -d "$build_dir" ]; then
        print_status "Renaming build directory..."
        if mv "$build_dir" "$new_build_dir" 2>/dev/null; then
            print_success "Build directory renamed"
        else
            print_error "Failed to rename build directory!"
            # Try to restore the config file
            mv "$new_config_file" "$config_file" 2>/dev/null
            wait_for_input
            return 1
        fi
    fi
    
    print_success "Configuration renamed from '$config_basename' to '$new_name'!"
    
    # Update current configuration if it was the one we renamed
    if [ "$config_file" = "$WT_CONFIG_DIR/$WT_CURRENT_CONFIG" ]; then
        print_status "Updated active configuration reference."
        WT_CURRENT_CONFIG="${new_name}.conf"
        wt_load_build_config
    fi
    
    wait_for_input
}
