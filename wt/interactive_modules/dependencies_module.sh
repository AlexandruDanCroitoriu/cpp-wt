#!/bin/bash
# Dependencies Management Module for Interactive Script
# Provides manual installation/uninstallation of system dependencies

# Module-specific variables
DEPS_MODULE_LOADED=false

# Initialize the module
dependencies_module_init() {
    if [ "$DEPS_MODULE_LOADED" = true ]; then
        return 0
    fi
    
    DEPS_MODULE_LOADED=true
    print_status "Dependencies management module initialized"
}

# Package categories and their dependencies
declare -A PACKAGE_CATEGORIES
declare -A PACKAGE_DESCRIPTIONS

# Initialize package data
init_package_data() {
    # Core build tools
    PACKAGE_CATEGORIES["core"]="build-essential cmake git pkg-config"
    PACKAGE_DESCRIPTIONS["build-essential"]="Essential build tools (gcc, g++, make, etc.)"
    PACKAGE_DESCRIPTIONS["cmake"]="Cross-platform build system generator"
    PACKAGE_DESCRIPTIONS["git"]="Version control system"
    PACKAGE_DESCRIPTIONS["pkg-config"]="Package configuration tool"
    
    # Wt required dependencies
    PACKAGE_CATEGORIES["wt_required"]="libboost-all-dev libssl-dev zlib1g-dev libfcgi-dev"
    PACKAGE_DESCRIPTIONS["libboost-all-dev"]="Boost C++ libraries (all development packages)"
    PACKAGE_DESCRIPTIONS["libssl-dev"]="OpenSSL cryptographic library development files"
    PACKAGE_DESCRIPTIONS["zlib1g-dev"]="Compression library development files"
    PACKAGE_DESCRIPTIONS["libfcgi-dev"]="FastCGI development library"
    
    # Database backend packages
    PACKAGE_CATEGORIES["database"]="libmysqlclient-dev libpq-dev libsqlite3-dev"
    PACKAGE_DESCRIPTIONS["libmysqlclient-dev"]="MySQL client library development files"
    PACKAGE_DESCRIPTIONS["libpq-dev"]="PostgreSQL client library development files"
    PACKAGE_DESCRIPTIONS["libsqlite3-dev"]="SQLite 3 development files"
    
    # Graphics and media packages
    PACKAGE_CATEGORIES["graphics"]="libgd-dev libgraphicsmagick1-dev libpango1.0-dev libpng-dev libjpeg-dev libglew-dev libgl1-mesa-dev libglu1-mesa-dev"
    PACKAGE_DESCRIPTIONS["libgd-dev"]="GD graphics library development files"
    PACKAGE_DESCRIPTIONS["libgraphicsmagick1-dev"]="GraphicsMagick image processing development files"
    PACKAGE_DESCRIPTIONS["libpango1.0-dev"]="Pango text rendering development files"
    PACKAGE_DESCRIPTIONS["libpng-dev"]="PNG library development files"
    PACKAGE_DESCRIPTIONS["libjpeg-dev"]="JPEG library development files"
    PACKAGE_DESCRIPTIONS["libglew-dev"]="OpenGL Extension Wrangler development files"
    PACKAGE_DESCRIPTIONS["libgl1-mesa-dev"]="Mesa OpenGL development files"
    PACKAGE_DESCRIPTIONS["libglu1-mesa-dev"]="Mesa OpenGL utility development files"
    
    # Optional packages
    PACKAGE_CATEGORIES["optional"]="libhpdf-dev libfirebird-dev qtbase5-dev qt6-base-dev libunwind-dev doxygen graphviz"
    PACKAGE_DESCRIPTIONS["libhpdf-dev"]="PDF generation library development files"
    PACKAGE_DESCRIPTIONS["libfirebird-dev"]="Firebird database development files"
    PACKAGE_DESCRIPTIONS["qtbase5-dev"]="Qt 5 base development files"
    PACKAGE_DESCRIPTIONS["qt6-base-dev"]="Qt 6 base development files"
    PACKAGE_DESCRIPTIONS["libunwind-dev"]="Stack unwinding library development files"
    PACKAGE_DESCRIPTIONS["doxygen"]="Documentation generation tool"
    PACKAGE_DESCRIPTIONS["graphviz"]="Graph visualization software"
}

# Check if a package is installed
check_package_installed() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# Get installation status of a package
get_package_status() {
    local package="$1"
    
    if check_package_installed "$package"; then
        echo -e "${GREEN}Installed${NC}"
        return 0
    else
        echo -e "${RED}Not Installed${NC}"
        return 1
    fi
}

# Install a single package
install_single_package() {
    local package="$1"
    
    if check_package_installed "$package"; then
        print_warning "$package is already installed"
        return 0
    fi
    
    print_status "Installing $package..."
    
    if sudo apt install -y "$package" 2>/dev/null; then
        print_success "Successfully installed $package"
        return 0
    else
        print_error "Failed to install $package"
        return 1
    fi
}

# Uninstall a single package
uninstall_single_package() {
    local package="$1"
    
    if ! check_package_installed "$package"; then
        print_warning "$package is not installed"
        return 0
    fi
    
    print_status "Uninstalling $package..."
    
    if sudo apt remove -y "$package" 2>/dev/null; then
        print_success "Successfully uninstalled $package"
        return 0
    else
        print_error "Failed to uninstall $package"
        return 1
    fi
}

# Show dependency management menu
show_dependencies_menu() {
    local categories=("core" "wt_required" "database" "graphics" "optional")
    local category_names=("Core Build Tools" "Wt Required" "Database Backends" "Graphics & Media" "Optional Packages")
    local selected_category=0
    local selected_package=0
    local in_category=false
    
    # Initialize package data
    init_package_data
    
    while true; do
        if [ "$in_category" = false ]; then
            # Show category selection
            show_header
            echo -e "${BOLD}${BLUE}System Dependencies Configuration${NC}"
            echo ""
            echo -e "${MAGENTA}Select a category:${NC}"
            echo ""
            
            for i in "${!categories[@]}"; do
                local category="${categories[$i]}"
                local category_name="${category_names[$i]}"
                local packages=(${PACKAGE_CATEGORIES[$category]})
                local installed_count=0
                
                # Count installed packages in this category
                for package in "${packages[@]}"; do
                    if check_package_installed "$package"; then
                        installed_count=$((installed_count + 1))
                    fi
                done
                
                local status_text="${installed_count}/${#packages[@]} installed"
                
                if [ $i -eq $selected_category ]; then
                    echo -e "${BOLD}${GREEN}→ $category_name${NC} ${DIM}($status_text)${NC}"
                else
                    echo -e "  $category_name ${DIM}($status_text)${NC}"
                fi
            done
            
            echo ""
            echo -e "${DIM}Use ↑/↓ to navigate, Enter to select category, 'q' to go back${NC}"
            
        else
            # Show package selection within category
            local category="${categories[$selected_category]}"
            local category_name="${category_names[$selected_category]}"
            local packages=(${PACKAGE_CATEGORIES[$category]})
            
            show_header
            echo -e "${BOLD}${BLUE}System Dependencies Configuration${NC}"
            echo ""
            echo -e "${MAGENTA}Category: $category_name${NC}"
            echo ""
            
            for i in "${!packages[@]}"; do
                local package="${packages[$i]}"
                local description="${PACKAGE_DESCRIPTIONS[$package]}"
                local status=$(get_package_status "$package")
                
                if [ $i -eq $selected_package ]; then
                    # Calculate padding for description alignment
                    local package_status_text="→ $package - $status"
                    local package_status_length=$(echo "$package_status_text" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
                    local terminal_width=$(tput cols 2>/dev/null || echo 80)
                    local description_start=$((terminal_width - ${#description} - 2))
                    local padding_needed=$((description_start - package_status_length))
                    
                    if [ $padding_needed -gt 0 ]; then
                        printf "${BOLD}${GREEN}→ %s${NC} - %s%*s${DIM}%s${NC}\n" "$package" "$status" "$padding_needed" "" "$description"
                    else
                        # If description is too long, truncate it
                        local max_desc_length=$((terminal_width - package_status_length - 5))
                        if [ $max_desc_length -gt 10 ]; then
                            local truncated_desc="${description:0:$max_desc_length}..."
                            echo -e "${BOLD}${GREEN}→ $package${NC} - $status ${DIM}$truncated_desc${NC}"
                        else
                            echo -e "${BOLD}${GREEN}→ $package${NC} - $status"
                        fi
                    fi
                else
                    echo -e "  $package - $status"
                fi
            done
            
            echo ""
            echo -e "${DIM}Use ↑/↓ to navigate, 'i' to install, 'u' to uninstall, Enter to toggle, 'b' to go back to categories, 'q' to exit${NC}"
        fi
        
        # Handle input
        read -n 1 -s key
        case $key in
            $'\033')  # ESC sequence for arrow keys
                read -n 2 -s rest
                case $rest in
                    '[A')  # Up arrow
                        if [ "$in_category" = false ]; then
                            if [ $selected_category -gt 0 ]; then
                                selected_category=$((selected_category - 1))
                            fi
                        else
                            local category="${categories[$selected_category]}"
                            local packages=(${PACKAGE_CATEGORIES[$category]})
                            if [ $selected_package -gt 0 ]; then
                                selected_package=$((selected_package - 1))
                            fi
                        fi
                        ;;
                    '[B')  # Down arrow
                        if [ "$in_category" = false ]; then
                            if [ $selected_category -lt $((${#categories[@]} - 1)) ]; then
                                selected_category=$((selected_category + 1))
                            fi
                        else
                            local category="${categories[$selected_category]}"
                            local packages=(${PACKAGE_CATEGORIES[$category]})
                            if [ $selected_package -lt $((${#packages[@]} - 1)) ]; then
                                selected_package=$((selected_package + 1))
                            fi
                        fi
                        ;;
                esac
                ;;
            '')  # Enter key
                if [ "$in_category" = false ]; then
                    # Enter category
                    in_category=true
                    selected_package=0
                else
                    # Toggle package installation
                    local category="${categories[$selected_category]}"
                    local packages=(${PACKAGE_CATEGORIES[$category]})
                    local package="${packages[$selected_package]}"
                    
                    if check_package_installed "$package"; then
                        handle_package_action "$package" "uninstall"
                    else
                        handle_package_action "$package" "install"
                    fi
                fi
                ;;
            'i'|'I')  # Install package
                if [ "$in_category" = true ]; then
                    local category="${categories[$selected_category]}"
                    local packages=(${PACKAGE_CATEGORIES[$category]})
                    local package="${packages[$selected_package]}"
                    handle_package_action "$package" "install"
                fi
                ;;
            'u'|'U')  # Uninstall package
                if [ "$in_category" = true ]; then
                    local category="${categories[$selected_category]}"
                    local packages=(${PACKAGE_CATEGORIES[$category]})
                    local package="${packages[$selected_package]}"
                    handle_package_action "$package" "uninstall"
                fi
                ;;
            'b'|'B')  # Back to categories
                if [ "$in_category" = true ]; then
                    in_category=false
                    selected_package=0
                fi
                ;;
            'q'|'Q')  # Quit
                return 0
                ;;
        esac
    done
}

# Handle package installation/uninstallation with confirmation
handle_package_action() {
    local package="$1"
    local action="$2"
    
    show_header
    echo -e "${BOLD}${BLUE}Package Action Confirmation${NC}"
    echo ""
    echo -e "${YELLOW}Package:${NC} $package"
    echo -e "${YELLOW}Description:${NC} ${PACKAGE_DESCRIPTIONS[$package]}"
    echo -e "${YELLOW}Action:${NC} $action"
    echo ""
    
    local current_status
    if check_package_installed "$package"; then
        current_status="${GREEN}Currently Installed${NC}"
    else
        current_status="${RED}Currently Not Installed${NC}"
    fi
    echo -e "${YELLOW}Current Status:${NC} $current_status"
    echo ""
    
    if [ "$action" = "install" ] && check_package_installed "$package"; then
        print_warning "Package is already installed"
        wait_for_input
        return 0
    fi
    
    if [ "$action" = "uninstall" ] && ! check_package_installed "$package"; then
        print_warning "Package is not installed"
        wait_for_input
        return 0
    fi
    
    if confirm_action "Proceed with $action of $package?" true; then
        case "$action" in
            "install")
                install_single_package "$package"
                ;;
            "uninstall")
                uninstall_single_package "$package"
                ;;
        esac
    else
        print_status "Action cancelled"
    fi
    
    wait_for_input
}

# Check sudo privileges
check_sudo_privileges() {
    if [ "$EUID" -eq 0 ]; then
        return 0  # Running as root
    fi
    
    if ! sudo -n true 2>/dev/null; then
        print_status "This operation requires sudo privileges."
        print_status "Please enter your password when prompted."
        sudo -v || {
            print_error "Cannot obtain sudo privileges. Exiting."
            return 1
        }
    fi
    
    return 0
}

# Show dependencies status overview for the main status page
dependencies_show_status_overview() {
    # Initialize package data
    init_package_data
    
    local categories=("core" "wt_required" "database" "graphics" "optional")
    local category_names=("Core Build Tools" "Wt Required" "Database Backends" "Graphics & Media" "Optional Packages")
    
    for i in "${!categories[@]}"; do
        local category="${categories[$i]}"
        local category_name="${category_names[$i]}"
        local packages=(${PACKAGE_CATEGORIES[$category]})
        local installed_count=0
        local total_count=${#packages[@]}
        
        # Count installed packages in this category
        for package in "${packages[@]}"; do
            if check_package_installed "$package"; then
                installed_count=$((installed_count + 1))
            fi
        done
        
        # Show category status with color coding
        local status_color=""
        local status_icon=""
        if [ $installed_count -eq $total_count ]; then
            status_color="${GREEN}"
            status_icon="✓"
        elif [ $installed_count -gt 0 ]; then
            status_color="${YELLOW}"
            status_icon="◐"
        else
            status_color="${RED}"
            status_icon="✗"
        fi
        
        echo -e "  ${status_color}${status_icon}${NC} $category_name: ${status_color}$installed_count${NC}/$total_count installed"
        
        # Show missing critical packages for core and wt_required categories
        if [ "$category" = "core" ] || [ "$category" = "wt_required" ]; then
            local missing_packages=()
            for package in "${packages[@]}"; do
                if ! check_package_installed "$package"; then
                    missing_packages+=("$package")
                fi
            done
            
            if [ ${#missing_packages[@]} -gt 0 ]; then
                echo -e "    ${DIM}Missing: ${missing_packages[*]}${NC}"
            fi
        fi
    done
    
    # Show overall summary
    local total_packages=0
    local total_installed=0
    
    for category in "${categories[@]}"; do
        local packages=(${PACKAGE_CATEGORIES[$category]})
        total_packages=$((total_packages + ${#packages[@]}))
        
        for package in "${packages[@]}"; do
            if check_package_installed "$package"; then
                total_installed=$((total_installed + 1))
            fi
        done
    done
    
    echo ""
    echo -e "  ${BLUE}ℹ${NC} Overall: ${CYAN}$total_installed${NC}/$total_packages dependencies installed"
    
    # Show recommendation based on missing critical dependencies
    local core_packages=(${PACKAGE_CATEGORIES["core"]})
    local wt_required_packages=(${PACKAGE_CATEGORIES["wt_required"]})
    local missing_critical=()
    
    for package in "${core_packages[@]}" "${wt_required_packages[@]}"; do
        if ! check_package_installed "$package"; then
            missing_critical+=("$package")
        fi
    done
    
    if [ ${#missing_critical[@]} -gt 0 ]; then
        echo -e "  ${YELLOW}!${NC} ${#missing_critical[@]} critical dependencies missing - Use 'Install System Dependencies' to configure"
    else
        echo -e "  ${GREEN}✓${NC} All critical dependencies are installed"
    fi
}

# Module entry point
dependencies_handle_selection() {
    # Check sudo privileges before showing menu
    if ! check_sudo_privileges; then
        show_error_page "Sudo privileges required" "Please run with appropriate permissions"
        return 1
    fi
    
    show_dependencies_menu
}
