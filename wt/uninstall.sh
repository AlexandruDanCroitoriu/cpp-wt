#!/bin/bash
# Script to uninstall Wt library system-wide
# Usage: ./scripts/libs/wt/uninstall.sh [options]

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common variables and functions
source "$SCRIPT_DIR/../../variables.sh"

# Script-specific variables
LOG_FILE="$OUTPUT_DIR/uninstall_wt.log"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Clear the log file for this run
> "$LOG_FILE"

# Colorized help function (REQUIRED)
show_usage() {
    echo -e "${BOLD}${BLUE}Usage:${NC} $0 [options]"
    echo ""
    echo -e "${BOLD}${GREEN}Description:${NC}"
    echo "  Uninstall Wt library from system-wide installation"
    echo ""
    echo -e "${BOLD}${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}-h, --help${NC}       Show this help message"
    echo -e "  ${CYAN}-f, --force${NC}      Force uninstall without confirmation"
    echo -e "  ${CYAN}-v, --verbose${NC}    Show verbose output"
    echo -e "  ${CYAN}--dry-run${NC}        Show what would be removed without actually removing"
    echo ""
    echo -e "${BOLD}${YELLOW}Examples:${NC}"
    echo -e "  ${GREEN}$0${NC}               # Interactive uninstall with confirmation"
    echo -e "  ${GREEN}$0 --force${NC}       # Force uninstall without confirmation"
    echo -e "  ${GREEN}$0 --dry-run${NC}     # Show what would be removed"
}

# Confirmation dialog
confirm_action() {
    local message="$1"
    local default_yes="${2:-false}"
    
    echo ""
    echo -e "${YELLOW}$message${NC}"
    
    if [ "$default_yes" = true ]; then
        echo -e "${YELLOW}Continue? (Y/n):${NC}"
        read -n 1 -s confirm
        [[ "$confirm" =~ ^[Nn]$ ]] && return 1
    else
        echo -e "${YELLOW}Continue? (y/N):${NC}"
        read -n 1 -s confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || return 1
    fi
    
    echo ""
    return 0
}

# Check if Wt is installed system-wide
wt_check_system_installation() {
    # Check for Wt library files in common system locations
    local common_locations=(
        "/usr/local/lib/libwt.so"
        "/usr/lib/libwt.so"
        "/usr/local/lib/x86_64-linux-gnu/libwt.so"
        "/usr/lib/x86_64-linux-gnu/libwt.so"
        "/usr/local/include/Wt"
        "/usr/include/Wt"
    )
    
    for location in "${common_locations[@]}"; do
        if [ -e "$location" ]; then
            return 0  # Found Wt installation
        fi
    done
    
    # Check with pkg-config
    if pkg-config --exists wt 2>/dev/null; then
        return 0
    fi
    
    # Check with ldconfig
    if ldconfig -p 2>/dev/null | grep -q "libwt"; then
        return 0
    fi
    
    return 1  # No Wt installation found
}

# Get system and local Wt versions for comparison
wt_get_system_version() {
    local version="Unknown"
    
    # Method 1: pkg-config (most reliable)
    if pkg-config --exists wt 2>/dev/null; then
        version=$(pkg-config --modversion wt 2>/dev/null || echo "Unknown")
    else
        # Method 2: Extract from library filename
        for location in "/usr/local/lib" "/usr/lib" "/usr/local/lib/x86_64-linux-gnu" "/usr/lib/x86_64-linux-gnu"; do
            if [ -f "$location/libwt.so" ]; then
                # Look for versioned library files
                local versioned_lib=$(find "$location" -name "libwt.so.*" 2>/dev/null | head -1)
                if [ -n "$versioned_lib" ]; then
                    version=$(basename "$versioned_lib" | sed 's/libwt\.so\.//')
                    break
                fi
            fi
        done
    fi
    
    echo "$version"
}

# Show current installation information
show_installation_info() {
    echo -e "${BOLD}${BLUE}Current Installation:${NC}"
    
    # Show system version if installed
    if wt_check_system_installation; then
        local system_version=$(wt_get_system_version)
        echo -e "• System version: ${GREEN}$system_version${NC}"
        
        # Show local build version if available
        if [ -f "$PROJECT_ROOT/libs/wt/build/CMakeCache.txt" ]; then
            local local_version=$(grep "VERSION_SERIES\|VERSION_MAJOR\|VERSION_MINOR" "$PROJECT_ROOT/libs/wt/build/CMakeCache.txt" 2>/dev/null | head -3 | cut -d'=' -f2 | tr '\n' '.' | sed 's/\.$//')
            if [ -n "$local_version" ] && [ "$local_version" != "" ]; then
                echo -e "• Local build version: ${CYAN}$local_version${NC}"
            fi
        fi
    else
        echo -e "• ${RED}No system installation detected${NC}"
        return 1
    fi
    
    echo ""
    return 0
}

# Manual uninstall function with enhanced logging
wt_manual_uninstall() {
    local dry_run="$1"
    local verbose="$2"
    
    if [ "$dry_run" = true ]; then
        print_status "DRY RUN: Showing what would be removed..."
    else
        print_status "Performing manual uninstall..."
    fi
    
    local total_removed=0
    
    # Common installation prefixes
    local prefixes=("/usr/local" "/usr")
    
    for prefix in "${prefixes[@]}"; do
        if [ "$verbose" = true ]; then
            print_status "Checking $prefix for Wt files..."
        fi
        
        # Remove libraries with detailed output
        if [ "$verbose" = true ]; then
            print_status "Looking for Wt libraries in $prefix/lib..."
        fi
        
        if sudo find "$prefix/lib" -name "libwt*" -type f 2>/dev/null | head -1 >/dev/null; then
            local lib_files=$(sudo find "$prefix/lib" -name "libwt*" -type f 2>/dev/null)
            echo "$lib_files" | while IFS= read -r file; do
                if [ -f "$file" ]; then
                    if [ "$dry_run" = true ]; then
                        echo -e "${YELLOW}[DRY RUN]${NC} Would remove: $file"
                    else
                        print_status "Removing: $file"
                        sudo rm -f "$file" 2>/dev/null || print_warning "Failed to remove: $file"
                    fi
                fi
            done
            ((total_removed++))
        fi
        
        # Also check for architecture-specific lib directories
        local arch_lib_dirs=(
            "$prefix/lib/x86_64-linux-gnu"
            "$prefix/lib64"
        )
        
        for lib_dir in "${arch_lib_dirs[@]}"; do
            if [ -d "$lib_dir" ]; then
                if [ "$verbose" = true ]; then
                    print_status "Looking for Wt libraries in $lib_dir..."
                fi
                if sudo find "$lib_dir" -name "libwt*" -type f 2>/dev/null | head -1 >/dev/null; then
                    local arch_lib_files=$(sudo find "$lib_dir" -name "libwt*" -type f 2>/dev/null)
                    echo "$arch_lib_files" | while IFS= read -r file; do
                        if [ -f "$file" ]; then
                            if [ "$dry_run" = true ]; then
                                echo -e "${YELLOW}[DRY RUN]${NC} Would remove: $file"
                            else
                                print_status "Removing: $file"
                                sudo rm -f "$file" 2>/dev/null || print_warning "Failed to remove: $file"
                            fi
                        fi
                    done
                    ((total_removed++))
                fi
            fi
        done
        
        # Remove headers
        if [ -d "$prefix/include/Wt" ]; then
            if [ "$dry_run" = true ]; then
                echo -e "${YELLOW}[DRY RUN]${NC} Would remove Wt headers from $prefix/include/Wt"
            else
                print_status "Removing Wt headers from $prefix/include/Wt..."
                if sudo rm -rf "$prefix/include/Wt" 2>/dev/null; then
                    print_success "Removed Wt headers"
                    ((total_removed++))
                else
                    print_warning "Failed to remove Wt headers"
                fi
            fi
        fi
        
        # Remove shared Wt resources
        if [ -d "$prefix/share/Wt" ]; then
            if [ "$dry_run" = true ]; then
                echo -e "${YELLOW}[DRY RUN]${NC} Would remove Wt shared resources from $prefix/share/Wt"
            else
                print_status "Removing Wt shared resources from $prefix/share/Wt..."
                if sudo rm -rf "$prefix/share/Wt" 2>/dev/null; then
                    print_success "Removed Wt shared resources"
                    ((total_removed++))
                else
                    print_warning "Failed to remove Wt shared resources"
                fi
            fi
        fi
        
        # Remove CMake files
        local cmake_dirs=(
            "$prefix/lib/cmake/wt"
            "$prefix/lib/cmake/Wt"
            "$prefix/share/cmake/wt"
            "$prefix/share/cmake/Wt"
        )
        
        for cmake_dir in "${cmake_dirs[@]}"; do
            if [ -d "$cmake_dir" ]; then
                if [ "$dry_run" = true ]; then
                    echo -e "${YELLOW}[DRY RUN]${NC} Would remove Wt CMake files from $cmake_dir"
                else
                    print_status "Removing Wt CMake files from $cmake_dir..."
                    if sudo rm -rf "$cmake_dir" 2>/dev/null; then
                        print_success "Removed CMake files from $cmake_dir"
                        ((total_removed++))
                    else
                        print_warning "Failed to remove CMake files from $cmake_dir"
                    fi
                fi
            fi
        done
        
        # Remove pkg-config files
        local pkgconfig_dirs=(
            "$prefix/lib/pkgconfig"
            "$prefix/share/pkgconfig"
            "$prefix/lib/x86_64-linux-gnu/pkgconfig"
            "$prefix/lib64/pkgconfig"
        )
        
        for pkgdir in "${pkgconfig_dirs[@]}"; do
            if [ -d "$pkgdir" ]; then
                if find "$pkgdir" -name "wt*.pc" 2>/dev/null | head -1 >/dev/null; then
                    if [ "$dry_run" = true ]; then
                        echo -e "${YELLOW}[DRY RUN]${NC} Would remove Wt pkg-config files from $pkgdir"
                    else
                        print_status "Removing Wt pkg-config files from $pkgdir..."
                        local pc_files=$(find "$pkgdir" -name "wt*.pc" 2>/dev/null)
                        echo "$pc_files" | while IFS= read -r file; do
                            if [ -f "$file" ]; then
                                print_status "Removing: $file"
                                sudo rm -f "$file" 2>/dev/null || print_warning "Failed to remove: $file"
                            fi
                        done
                        ((total_removed++))
                    fi
                fi
            fi
        done
        
        # Remove symbolic links
        if [ "$verbose" = true ]; then
            print_status "Looking for Wt symbolic links in $prefix/lib..."
        fi
        if sudo find "$prefix/lib" -name "libwt*.so" -type l 2>/dev/null | head -1 >/dev/null; then
            local link_files=$(sudo find "$prefix/lib" -name "libwt*.so" -type l 2>/dev/null)
            echo "$link_files" | while IFS= read -r file; do
                if [ -L "$file" ]; then
                    if [ "$dry_run" = true ]; then
                        echo -e "${YELLOW}[DRY RUN]${NC} Would remove symlink: $file"
                    else
                        print_status "Removing symlink: $file"
                        sudo rm -f "$file" 2>/dev/null || print_warning "Failed to remove: $file"
                    fi
                fi
            done
            ((total_removed++))
        fi
    done
    
    if [ "$dry_run" = false ]; then
        # Update library cache
        print_status "Updating library cache..."
        if sudo ldconfig 2>/dev/null; then
            print_success "Library cache updated"
        else
            print_warning "Failed to update library cache"
        fi
    fi
    
    # Show summary
    echo ""
    if [ "$dry_run" = true ]; then
        print_status "DRY RUN Summary:"
        if [ $total_removed -gt 0 ]; then
            print_status "Would remove Wt installation components"
        else
            print_status "No Wt files found to remove"
        fi
    else
        print_status "Uninstall Summary:"
        if [ $total_removed -gt 0 ]; then
            print_success "Removed Wt installation components"
        else
            print_warning "No Wt files found to remove"
        fi
    fi
    
    # Final verification
    if [ "$dry_run" = false ]; then
        print_status "Verifying uninstallation..."
        if wt_check_system_installation; then
            print_warning "Some Wt files may still remain. Check the following locations manually:"
            echo -e "  • ${CYAN}/usr/local/lib/${NC} and ${CYAN}/usr/lib/${NC} for libwt* files"
            echo -e "  • ${CYAN}/usr/local/include/Wt/${NC} directory"
            echo -e "  • ${CYAN}/usr/local/share/Wt/${NC} directory"
            echo -e "  • ${CYAN}/usr/local/lib/cmake/wt/${NC} directory"
            echo -e "  • pkg-config files in ${CYAN}/usr/local/lib/pkgconfig/${NC}"
            echo ""
            echo -e "${YELLOW}Manual cleanup commands:${NC}"
            echo -e "  ${GREEN}sudo find /usr/local /usr -name '*wt*' -type f 2>/dev/null${NC}"
            echo -e "  ${GREEN}sudo rm -rf /usr/local/include/Wt${NC}"
            echo -e "  ${GREEN}sudo rm -rf /usr/local/share/Wt${NC}"
            echo -e "  ${GREEN}sudo rm -rf /usr/local/lib/cmake/wt${NC}"
            echo -e "  ${GREEN}sudo find /usr/local/lib /usr/lib -name 'libwt*' -delete${NC}"
        else
            print_success "Wt library uninstalled successfully! No system installation detected."
        fi
    fi
    
    # Clean up library path configuration
    if [ "$dry_run" = false ]; then
        cleanup_library_paths "$dry_run"
    fi
}

# Clean up system library path configuration for Wt
cleanup_library_paths() {
    local dry_run="$1"
    
    print_status "Cleaning up system library path configuration..."
    
    local lib_config_file="/etc/ld.so.conf.d/wt-local.conf"
    
    # Remove the library configuration file if it exists
    if [ -f "$lib_config_file" ]; then
        if [ "$dry_run" = true ]; then
            echo -e "${YELLOW}[DRY RUN]${NC} Would remove: $lib_config_file"
        else
            print_status "Removing library configuration: $lib_config_file"
            if [ "$EUID" -ne 0 ]; then
                if sudo rm -f "$lib_config_file"; then
                    print_success "Removed library configuration file"
                else
                    print_warning "Failed to remove library configuration file"
                fi
            else
                if rm -f "$lib_config_file"; then
                    print_success "Removed library configuration file"
                else
                    print_warning "Failed to remove library configuration file"
                fi
            fi
        fi
    else
        print_status "No library configuration file found to remove"
    fi
    
    # Update the system library cache only if we're not doing a dry run
    if [ "$dry_run" = false ]; then
        print_status "Updating system library cache..."
        if [ "$EUID" -ne 0 ]; then
            if sudo ldconfig; then
                print_success "System library cache updated"
            else
                print_warning "Failed to update library cache"
            fi
        else
            if ldconfig; then
                print_success "System library cache updated"
            else
                print_warning "Failed to update library cache"
            fi
        fi
        
        # Verify that Wt libraries are no longer findable
        if ! ldconfig -p | grep -q "libwt"; then
            print_success "Wt libraries removed from system library cache"
        else
            print_warning "Some Wt libraries may still be in system library cache"
            echo ""
            print_status "Remaining Wt libraries:"
            ldconfig -p | grep "libwt" | while read -r line; do
                echo -e "  ${YELLOW}$line${NC}"
            done
            echo ""
        fi
    else
        echo -e "${YELLOW}[DRY RUN]${NC} Would update system library cache with ldconfig"
    fi
}

# Main uninstall function
wt_execute_uninstall() {
    local force_mode="$1"
    local dry_run="$2"
    local verbose="$3"
    
    echo -e "${BOLD}${BLUE}Uninstall Wt Library System-wide${NC}"
    echo ""
    
    # Check if Wt is actually installed
    if ! wt_check_system_installation; then
        print_warning "No system-wide Wt installation detected."
        echo -e "${YELLOW}Nothing to uninstall.${NC}"
        return 0
    fi
    
    # Show current installation info
    show_installation_info
    
    if [ "$dry_run" = false ]; then
        echo -e "${YELLOW}⚠ Warning: This will remove Wt from your system${NC}"
        echo -e "${YELLOW}Files that will be removed:${NC}"
        echo -e "  • Libraries from /usr/local/lib/ and /usr/lib/"
        echo -e "  • Headers from /usr/local/include/Wt/"
        echo -e "  • Shared resources from /usr/local/share/Wt/"
        echo -e "  • CMake files from /usr/local/lib/cmake/wt/"
        echo -e "  • pkg-config files"
        echo ""
        echo -e "${YELLOW}Note: This may affect other applications that depend on Wt${NC}"
        echo ""
        
        if [ "$force_mode" = false ]; then
            if ! confirm_action "Are you sure you want to uninstall Wt system-wide?" false; then
                print_status "Uninstallation cancelled."
                return 0
            fi
        fi
    fi
    
    print_status "Starting Wt uninstallation..."
    
    # Try to use make uninstall if available
    if [ "$dry_run" = false ] && [ -f "$PROJECT_ROOT/libs/wt/build/Makefile" ]; then
        print_status "Checking for 'make uninstall' target..."
        cd "$PROJECT_ROOT/libs/wt/build" || {
            print_error "Failed to change to build directory"
            return 1
        }
        
        # Check if uninstall target exists first
        if make -n uninstall >/dev/null 2>&1; then
            print_status "Found uninstall target, executing..."
            if sudo make uninstall 2>&1 | tee -a "$LOG_FILE"; then
                print_success "Wt library uninstalled successfully using 'make uninstall'"
                
                # Verify uninstallation worked
                if wt_check_system_installation; then
                    print_warning "Some files may remain. Performing additional cleanup..."
                    wt_manual_uninstall "$dry_run" "$verbose"
                else
                    print_success "Uninstallation completed successfully!"
                fi
            else
                print_error "'make uninstall' failed. Attempting manual removal..."
                wt_manual_uninstall "$dry_run" "$verbose"
            fi
        else
            print_warning "No 'uninstall' target found in Makefile. Performing manual removal..."
            wt_manual_uninstall "$dry_run" "$verbose"
        fi
    else
        if [ "$dry_run" = false ]; then
            print_warning "Build directory not found. Performing manual removal..."
        fi
        wt_manual_uninstall "$dry_run" "$verbose"
    fi
    
    echo ""
    if [ "$dry_run" = false ]; then
        print_success "Uninstall process completed!"
        echo -e "${CYAN}Log file: $LOG_FILE${NC}"
    else
        print_success "Dry run completed!"
    fi
}

# Main execution function
main() {
    local force_mode=false
    local dry_run=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -f|--force)
                force_mode=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Initialize logging
    print_status "Starting Wt uninstall script..."
    print_status "Log file: $LOG_FILE"
    
    # Execute uninstall
    wt_execute_uninstall "$force_mode" "$dry_run" "$verbose"
}

# Run main function with all arguments
main "$@"
