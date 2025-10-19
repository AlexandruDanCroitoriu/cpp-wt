#!/bin/bash
# Wt Examples Module for Interactive Scripts
# This module provides easy access to running Wt example applications

# Get the module directory for proper path resolution
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_SCRIPT_DIR="$(dirname "$MODULE_DIR")"  # Go up to scripts/ directory

# ===================================================================
# Wt Examples Module Configuration
# ===================================================================

# Module-specific configuration
WT_EXAMPLES_BUILD_DIR="$PROJECT_ROOT/libs/wt/build/default"
WT_EXAMPLES_DIR="$WT_EXAMPLES_BUILD_DIR/examples"
WT_EXAMPLES_SOURCE_DIR="$PROJECT_ROOT/libs/wt/examples"
WT_RESOURCES_DIR="$PROJECT_ROOT/libs/wt/resources"
WT_EXAMPLES_PORT_BASE=8080

# ===================================================================
# Complete Example Information Arrays (In CMakeLists.txt Order)
# ===================================================================

# Basic examples (main page) - only include those that have executables
WT_BASIC_EXAMPLES=(
    "authentication"
    "blog"
    "charts"
    "chart3D"
    "codeview"
    "composer"
    "custom-bs-theme"
    "dbo-form"
    "dialog"
    "dragdrop"
    "filedrop"
    "filetreetable"
    "form"
    "gitmodel"
    "hangman"
    "hello"
    "http-client"
    "javascript"
    "leaflet"
    "mandelbrot"
    "mission"
    "onethread"
    "painting"
    "planner"
    "qrlogin"
    "simplechat"
    "style"
    "tableview-dragdrop"
    "te-benchmark"
    "treelist"
    "treeview"
    "treeview-dragdrop"
    "webgl"
    "websockets"
    "widgetgallery"
    "wt-homepage"
)

# Feature examples (second page)
WT_FEATURE_EXAMPLES=(
    "feature/auth1"
    "feature/auth2"
    "feature/broadcast"
    "feature/client-ssl-auth"
    "feature/custom_layout"
    "feature/dbo/tutorial1"
    "feature/dbo/tutorial2"
    "feature/dbo/tutorial3"
    "feature/dbo/tutorial4"
    "feature/dbo/tutorial5"
    "feature/dbo/tutorial6"
    "feature/dbo/tutorial7"
    "feature/dbo/tutorial8"
    "feature/dbo/tutorial9"
    "feature/locale"
    "feature/mediaplayer"
    "feature/miniwebgl"
    "feature/multiple_servers"
    "feature/oauth"
    "feature/oidc"
    "feature/paypal"
    "feature/postall"
    "feature/scrollvisibility"
    "feature/serverpush"
    "feature/socketnotifier"
    "feature/suggestionpopup"
    "feature/template-fun"
    "feature/urlparams"
    "feature/video"
    "feature/widgetset"
)

declare -A WT_EXAMPLE_INFO
WT_EXAMPLE_INFO=(
    ["authentication"]="Comprehensive authentication framework with login/logout and password authentication"
    ["blog"]="Simple blogging application demonstrating MVC architecture and data persistence"
    ["charts"]="Interactive charts and graphs showcase using Wt's charting capabilities"
    ["chart3D"]="3D charting examples showing advanced visualization features"
    ["codeview"]="Source code viewer application with syntax highlighting"
    ["composer"]="Email composition interface with rich text editing capabilities"
    ["custom-bs-theme"]="Bootstrap theme customization demonstration"
    ["dbo-form"]="Database object forms with rich text editing (requires TinyMCE setup)"
    ["dialog"]="Modal dialogs and popup windows demonstration"
    ["dragdrop"]="Drag and drop interactions and file uploads"
    ["filetreetable"]="File system browser with tree table interface"
    ["filedrop"]="File drag-and-drop upload interface"
    ["form"]="Form widgets and validation examples"
    ["gitmodel"]="Git repository browser using Wt's MVC framework"
    ["hangman"]="Classic hangman word game implementation"
    ["hello"]="Simple Hello World application demonstrating basic Wt concepts"
    ["http-client"]="HTTP client functionality and web service consumption"
    ["javascript"]="JavaScript integration and client-server communication"
    ["leaflet"]="Interactive maps using Leaflet.js integration"
    ["mandelbrot"]="Interactive Mandelbrot fractal explorer (requires GD graphics library)"
    ["mission"]="Space mission control dashboard simulation"
    ["onethread"]="Single-threaded server application example"
    ["painting"]="Vector graphics and painting API demonstration"
    ["planner"]="Calendar and event planning application"
    ["qrlogin"]="QR code authentication and login system"
    ["simplechat"]="Real-time chat application with WebSockets"
    ["style"]="Custom widget styling with rounded corners using WRasterImage and painting API"
    ["tableview-dragdrop"]="Table view with drag and drop reordering"
    ["te-benchmark"]="Text editor performance benchmarking"
    ["treelist"]="Tree list widget demonstrations"
    ["treeview"]="Tree view widget with hierarchical data"
    ["treeview-dragdrop"]="Tree view with drag and drop capabilities"
    ["webgl"]="WebGL 3D graphics integration"
    ["websockets"]="WebSocket communication examples"
    ["widgetgallery"]="Comprehensive showcase of all Wt widgets"
    ["wt-homepage"]="Complete Wt project homepage with blog, authentication, and multiple languages"
    # Feature examples
    ["feature/auth1"]="Basic authentication example"
    ["feature/auth2"]="Advanced authentication with database integration"
    ["feature/broadcast"]="Server-side broadcasting to multiple clients"
    ["feature/client-ssl-auth"]="SSL client certificate authentication"
    ["feature/custom_layout"]="Custom layout and template examples"
    ["feature/dbo/tutorial1"]="Wt::Dbo Tutorial 1: Basic mapping and queries"
    ["feature/dbo/tutorial2"]="Wt::Dbo Tutorial 2: One-to-many relations"
    ["feature/dbo/tutorial3"]="Wt::Dbo Tutorial 3: Many-to-many relations"
    ["feature/dbo/tutorial4"]="Wt::Dbo Tutorial 4: Specifying a schema"
    ["feature/dbo/tutorial5"]="Wt::Dbo Tutorial 5: Database schema versioning"
    ["feature/dbo/tutorial6"]="Wt::Dbo Tutorial 6: Joining objects"
    ["feature/dbo/tutorial7"]="Wt::Dbo Tutorial 7: Transactions"
    ["feature/dbo/tutorial8"]="Wt::Dbo Tutorial 8: A simple web application"
    ["feature/dbo/tutorial9"]="Wt::Dbo Tutorial 9: Multi-file Dbo class structure"
    ["feature/locale"]="⚠️  KNOWN ISSUE: Timezone database crashes with GraphicsMagick - try auth1/auth2 or DBO tutorials instead"
    ["feature/mediaplayer"]="Media player widget demonstration"
    ["feature/miniwebgl"]="Minimal WebGL integration example"
    ["feature/multiple_servers"]="Multiple server instance management"
    ["feature/oauth"]="OAuth authentication integration"
    ["feature/oidc"]="OpenID Connect authentication"
    ["feature/paypal"]="PayPal payment integration"
    ["feature/postall"]="HTTP POST handling examples"
    ["feature/scrollvisibility"]="Scroll visibility and lazy loading"
    ["feature/serverpush"]="Server-side push notifications"
    ["feature/socketnotifier"]="Socket notification handling"
    ["feature/suggestionpopup"]="Auto-suggestion popup widgets"
    ["feature/template-fun"]="Template function examples"
    ["feature/urlparams"]="URL parameter handling"
    ["feature/video"]="Video streaming and playback"
    ["feature/widgetset"]="Custom widget set creation"
)

# Mapping of example names to actual executables (only for examples that have executables)
declare -A WT_EXAMPLE_EXECUTABLES
WT_EXAMPLE_EXECUTABLES=(
    ["authentication"]="authentication/mfa/pin/pin-login.wt"  # Use one of the auth examples
    ["blog"]="blog/blog.wt"
    ["charts"]="charts/charts.wt"
    ["chart3D"]="chart3D/chart3D.wt"
    ["codeview"]="codeview/codingview.wt"
    ["composer"]="composer/composer.wt"
    ["custom-bs-theme"]="custom-bs-theme/custom-bs-theme.wt"
    ["dbo-form"]="dbo-form/dbo-form.wt"
    ["dialog"]="dialog/dialog.wt"
    ["dragdrop"]="dragdrop/dragdrop.wt"
    ["filetreetable"]="filetreetable/filetreetable.wt"
    ["filedrop"]="filedrop/filedrop.wt"
    ["form"]="form/formexample.wt"
    ["gitmodel"]="gitmodel/gitview.wt"
    ["hangman"]="hangman/hangman.wt"
    ["hello"]="hello/hello.wt"
    ["http-client"]="http-client/http-client.wt"
    ["javascript"]="javascript/javascript.wt"
    ["leaflet"]="leaflet/leaflet.wt"
    ["mandelbrot"]="mandelbrot/mandelbrot.wt"
    ["mission"]="mission/impossible.wt"
    ["onethread"]="onethread/hello1thread.wt"
    ["painting"]="painting/paintexample.wt"
    ["planner"]="planner/planner.wt"
    ["qrlogin"]="qrlogin/qrlogin.wt"
    ["simplechat"]="simplechat/simplechat.wt"
    ["style"]="style/styleexample.wt"
    ["tableview-dragdrop"]="tableview-dragdrop/tableview-dragdrop.wt"
    ["te-benchmark"]="te-benchmark/te-benchmark-pg.wt"
    ["treelist"]="treelist/demotreelist.wt"
    ["treeview"]="treeview/treeviewexample.wt"
    ["treeview-dragdrop"]="treeview-dragdrop/treeviewdragdrop.wt"
    ["webgl"]="webgl/webgl.wt"
    ["websockets"]="websockets/websocketdynamic.wt"
    ["widgetgallery"]="widgetgallery/widgetgallery.wt"
    ["wt-homepage"]="wt-homepage/Home.wt"
    # Feature examples
    ["feature/auth1"]="feature/auth1/auth1.wt"
    ["feature/auth2"]="feature/auth2/auth2.wt"
    ["feature/broadcast"]="feature/broadcast/broadcast.wt"
    ["feature/client-ssl-auth"]="feature/client-ssl-auth/client-ssl-auth.wt"
    ["feature/custom_layout"]="feature/custom_layout/custom-layout.wt"
    ["feature/dbo/tutorial1"]="feature/dbo/dbo-tutorial1"
    ["feature/dbo/tutorial2"]="feature/dbo/dbo-tutorial2"
    ["feature/dbo/tutorial3"]="feature/dbo/dbo-tutorial3"
    ["feature/dbo/tutorial4"]="feature/dbo/dbo-tutorial4"
    ["feature/dbo/tutorial5"]="feature/dbo/dbo-tutorial5"
    ["feature/dbo/tutorial6"]="feature/dbo/dbo-tutorial6"
    ["feature/dbo/tutorial7"]="feature/dbo/dbo-tutorial7"
    ["feature/dbo/tutorial8"]="feature/dbo/dbo-tutorial8"
    ["feature/dbo/tutorial9"]="feature/dbo/tutorial9/dbo-tutorial9"
    ["feature/locale"]="feature/locale/locale.wt"
    ["feature/mediaplayer"]="feature/mediaplayer/mediaplayer.wt"
    ["feature/miniwebgl"]="feature/miniwebgl/miniwebgl.wt"
    ["feature/multiple_servers"]="feature/multiple_servers/multiple.wt"
    ["feature/oauth"]="feature/oauth/oauth.wt"
    ["feature/oidc"]="feature/oidc/oidc.wt"
    ["feature/paypal"]="feature/paypal/paypal.wt"
    ["feature/postall"]="feature/postall/postall.wt"
    ["feature/scrollvisibility"]="feature/scrollvisibility/scrollvisibility.wt"
    ["feature/serverpush"]="feature/serverpush/serverpush.wt"
    ["feature/socketnotifier"]="feature/socketnotifier/socketnotifier.wt"
    ["feature/suggestionpopup"]="feature/suggestionpopup/suggestionpopup.wt"
    ["feature/template-fun"]="feature/template-fun/widgetfunction.wt"
    ["feature/urlparams"]="feature/urlparams/urlparams.wt"
    ["feature/video"]="feature/video/video.wt"
    ["feature/widgetset"]="feature/widgetset/hellowidgetset.wt"
)

# Function to get executable path for an example
get_example_executable() {
    local example_name="$1"
    local executable_path="${WT_EXAMPLE_EXECUTABLES[$example_name]}"
    if [ -n "$executable_path" ]; then
        echo "$WT_EXAMPLES_DIR/$executable_path"
    else
        echo "$WT_EXAMPLES_DIR/$example_name/$example_name.wt"
    fi
}

# Function to get source directory for an example
get_example_source_dir() {
    local example_name="$1"
    
    # Special handling for DBO tutorials 1-8 (they're .C files, not directories)
    if [[ "$example_name" == "feature/dbo/tutorial"[1-8] ]]; then
        echo "$WT_EXAMPLES_SOURCE_DIR/feature/dbo"
    else
        echo "$WT_EXAMPLES_SOURCE_DIR/$example_name"
    fi
}

# ===================================================================
# Example Management Functions
# ===================================================================

# Check if a specific example is built
wt_check_example_built() {
    local example_name="$1"
    local example_path=$(get_example_executable "$example_name")
    [ -f "$example_path" ]
}

# Check if graphics dependencies are available for mandelbrot
wt_check_graphics_dependencies() {
    # Check for GD library (essential for mandelbrot)
    if pkg-config --exists gdlib 2>/dev/null || ldconfig -p | grep -q "libgd" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get status indicator for an example
wt_get_example_status() {
    local example_name="$1"
    if [ "$example_name" = "mandelbrot" ] || [ "$example_name" = "style" ]; then
        if wt_check_example_built "$example_name"; then
            echo -e "${DIM}(${GREEN}Ready${DIM})${NC}"
        elif wt_check_graphics_dependencies; then
            echo -e "${DIM}(${YELLOW}Build Required${DIM})${NC}"
        else
            echo -e "${DIM}(${RED}Missing Graphics Deps${DIM})${NC}"
        fi
    else
        if wt_check_example_built "$example_name"; then
            echo -e "${DIM}(${GREEN}Ready${DIM})${NC}"
        else
            echo -e "${DIM}(${YELLOW}Build Required${DIM})${NC}"
        fi
    fi
}

# Setup examples build directory
wt_setup_examples_build() {
    print_status "Setting up examples in default Wt build..."
    
    # Use the default configuration build directory
    local wt_main_build="$PROJECT_ROOT/libs/wt/build/default"
    
    if [ ! -d "$wt_main_build" ]; then
        print_error "Default Wt build directory not found: $wt_main_build"
        print_error "Please build the Wt library first using the default configuration"
        echo ""
        echo -e "${YELLOW}Steps to build Wt library:${NC}"
        echo -e "1. Go back to main menu (press 'q')"
        echo -e "2. Select 'Libraries'"
        echo -e "3. Select 'Wt (Web Toolkit)'"
        echo -e "4. Build Wt with the 'default' configuration"
        echo -e "5. Then return here to build examples"
        return 1
    fi
    
    # Check if Wt library files exist in the default build
    local wt_lib_found=false
    if [ -f "$wt_main_build/src/libwt.so" ] || [ -f "$wt_main_build/src/libwt.a" ]; then
        wt_lib_found=true
    fi
    
    if [ "$wt_lib_found" = false ]; then
        print_error "Wt library not found in default build directory"
        print_error "Please build the Wt library using the default configuration first"
        echo ""
        echo -e "${YELLOW}The build directory exists but no compiled library was found.${NC}"
        echo -e "${YELLOW}Expected: $wt_main_build/src/libwt.so or libwt.a${NC}"
        return 1
    fi
    
    print_success "Found default Wt build: $wt_main_build"
    
    cd "$wt_main_build" || {
        print_error "Failed to change to default build directory"
        return 1
    }
    
    # Check if examples are enabled in current build
    local examples_enabled=$(grep "BUILD_EXAMPLES:BOOL=ON" CMakeCache.txt || true)
    
    if [ -z "$examples_enabled" ]; then
        print_status "Enabling examples in existing build..."
        
        # Reconfigure with examples enabled
        if ! cmake -DBUILD_EXAMPLES=ON .; then
            print_error "Failed to reconfigure build with examples enabled"
            return 1
        fi
        
        print_success "Examples enabled in build configuration"
    else
        print_status "Examples are already enabled in build"
    fi
    
    # Check if examples directory exists
    if [ ! -d "examples" ]; then
        print_status "Building examples directory structure..."
        
        # Build just the examples directory structure (doesn't build binaries yet)
        if ! make examples 2>/dev/null; then
            print_status "Examples target not available, this is normal - examples will build individually"
        fi
    fi
    
    return 0
}

# Clean examples build directory
wt_clean_examples_build() {
    show_header
    echo -e "${BOLD}${BLUE}Clean Examples in Default Build${NC}"
    echo ""
    
    local wt_build_dir="$PROJECT_ROOT/libs/wt/build/default"
    
    if [ -d "$wt_build_dir" ]; then
        echo -e "${YELLOW}This will remove built examples from the default Wt build directory:${NC}"
        echo -e "${CYAN}$wt_build_dir/examples/${NC}"
        echo ""
        echo -e "${YELLOW}The main Wt library will remain intact.${NC}"
        echo -e "${YELLOW}Examples will be rebuilt individually when needed.${NC}"
        echo ""
        
        if confirm_action "Remove built examples from the default build directory?" false; then
            print_status "Cleaning examples from default build..."
            
            # Remove examples directory if it exists
            if [ -d "$wt_build_dir/examples" ]; then
                rm -rf "$wt_build_dir/examples"
                print_success "Examples directory cleaned"
            else
                print_status "No examples directory found to clean"
            fi
            
            # Reset BUILD_EXAMPLES in CMakeCache.txt to OFF
            cd "$wt_build_dir" || {
                print_error "Failed to change to build directory"
                wait_for_input
                return 1
            }
            
            if [ -f "CMakeCache.txt" ]; then
                print_status "Disabling examples in build configuration..."
                cmake -DBUILD_EXAMPLES=OFF . >/dev/null 2>&1 || true
                print_success "Examples disabled in build configuration"
            fi
            
            echo ""
            print_success "Examples cleaned from default build"
            print_status "Next time you build an example, it will automatically re-enable examples"
        else
            print_status "Clean cancelled"
        fi
    else
        print_status "Default build directory doesn't exist, nothing to clean"
        echo -e "${CYAN}Directory: $wt_build_dir${NC}"
    fi
    
    wait_for_input
}

# Build a specific Wt example
wt_build_single_example() {
    local example_name="$1"
    
    if [ -z "$example_name" ]; then
        print_error "Example name is required"
        return 1
    fi
    
    print_status "Building example: $example_name"
    echo ""
    
    # Setup examples build directory if needed
    if ! wt_setup_examples_build; then
        return 1
    fi
    
    cd "$WT_EXAMPLES_BUILD_DIR" || {
        print_error "Failed to change to examples build directory"
        return 1
    }
    
    # Determine the correct make target
    local target_name="$example_name"
    
    # Most Wt examples use the pattern name.wt as the target
    # Check if we have a specific executable path defined
    local executable_path="${WT_EXAMPLE_EXECUTABLES[$example_name]}"
    if [ -n "$executable_path" ]; then
        # Extract the target name from the path (e.g., "blog/blog.wt" -> "blog.wt")
        target_name=$(basename "$executable_path")
    else
        # Default pattern: example_name.wt
        target_name="$example_name.wt"
    fi
    
    print_status "Building target: $target_name"
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}🔨 Build Output for $example_name:${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo ""
    
    # Create log file (sanitize example name for filename)
    local sanitized_name=$(echo "$example_name" | sed 's|/|_|g')
    local LOG_FILE="$OUTPUT_DIR/build_example_${sanitized_name}.log"
    
    # Build the specific example target
    if make -j$(nproc) "$target_name" 2>&1 | tee "$LOG_FILE"; then
        echo ""
        echo -e "${CYAN}Build log saved to: $LOG_FILE${NC}"
        print_success "Example '$example_name' built successfully!"
        return 0
    else
        echo ""
        print_error "Failed to build example: $example_name"
        print_error "Build log saved to: $LOG_FILE"
        return 1
    fi
}

# Get available port for example
wt_get_available_port() {
    local base_port=$1
    local port=$base_port
    
    # Use ss if available, otherwise use netstat, fallback to basic check
    if command -v ss >/dev/null 2>&1; then
        while ss -tuln 2>/dev/null | grep -q ":$port "; do
            ((port++))
        done
    elif command -v netstat >/dev/null 2>&1; then
        while netstat -tuln 2>/dev/null | grep -q ":$port "; do
            ((port++))
        done
    else
        # Simple incremental approach if no network tools available
        while [ $port -lt $((base_port + 100)) ]; do
            if ! (echo >/dev/tcp/localhost/$port) 2>/dev/null; then
                break
            fi
            ((port++))
        done
    fi
    
    echo $port
}

# Download and setup TinyMCE for dbo-form example
wt_setup_tinymce() {
    local tinymce_dir="$WT_RESOURCES_DIR/tinymce"
    
    print_status "Downloading and setting up TinyMCE..."
    
    # Create resources directory if it doesn't exist
    mkdir -p "$WT_RESOURCES_DIR"
    
    # Download TinyMCE
    local temp_dir=$(mktemp -d)
    local tinymce_version="6.8.3"
    local download_url="https://download.tiny.cloud/tinymce/community/tinymce_${tinymce_version}.zip"
    
    print_status "Downloading TinyMCE ${tinymce_version}..."
    if command -v wget >/dev/null 2>&1; then
        wget -q "$download_url" -O "$temp_dir/tinymce.zip" || {
            print_error "Failed to download TinyMCE"
            rm -rf "$temp_dir"
            return 1
        }
    elif command -v curl >/dev/null 2>&1; then
        curl -sL "$download_url" -o "$temp_dir/tinymce.zip" || {
            print_error "Failed to download TinyMCE"
            rm -rf "$temp_dir"
            return 1
        }
    else
        print_error "Neither wget nor curl found. Please install one of them to download TinyMCE automatically."
        rm -rf "$temp_dir"
        return 1
    fi
    
    print_status "Extracting TinyMCE..."
    cd "$temp_dir" || return 1
    
    if command -v unzip >/dev/null 2>&1; then
        unzip -q tinymce.zip || {
            print_error "Failed to extract TinyMCE"
            rm -rf "$temp_dir"
            return 1
        }
    else
        print_error "unzip not found. Please install unzip to extract TinyMCE automatically."
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Move TinyMCE to the resources directory
    if [ -d "tinymce/js/tinymce" ]; then
        # Remove existing tinymce directory if it exists
        if [ -d "$tinymce_dir" ]; then
            rm -rf "$tinymce_dir"
        fi
        
        mv "tinymce/js/tinymce" "$tinymce_dir" || {
            print_error "Failed to move TinyMCE to resources directory"
            rm -rf "$temp_dir"
            return 1
        }
        
        print_success "TinyMCE successfully installed to $tinymce_dir"
    else
        print_error "TinyMCE structure not as expected"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    return 0
}

# Run a specific example
wt_run_example() {
    local example_name="$1"
    local example_path=$(get_example_executable "$example_name")
    
    # Check if example exists, if not try to build it
    if [ ! -f "$example_path" ]; then
        print_status "Example not built: $example_name - building automatically..."
        
        if ! wt_build_single_example "$example_name"; then
            print_error "Failed to build example: $example_name"
            return 1
        fi
        
        # Check again after building
        if [ ! -f "$example_path" ]; then
            print_error "Example executable still not found after build: $example_path"
            print_warning "The example might have a different target name or build dependencies"
            return 1
        fi
        
        print_success "Example built successfully!"
    fi
    
    # Get available port
    local port=$(wt_get_available_port $WT_EXAMPLES_PORT_BASE)
    
    # Determine source and resources directories
    local example_source_dir=$(get_example_source_dir "$example_name")
    
    # Verify directories exist
    if [ ! -d "$example_source_dir" ]; then
        print_error "Example source directory not found: $example_source_dir"
        return 1
    fi
    
    if [ ! -d "$WT_RESOURCES_DIR" ]; then
        print_error "Wt resources directory not found: $WT_RESOURCES_DIR"
        return 1
    fi
    
    # Special setup for wt-homepage example
    if [ "$example_name" = "wt-homepage" ]; then
        print_status "Setting up wt-homepage example dependencies..."
        
        # Check and copy blog.xml from blog example if missing
        if [ ! -f "$example_source_dir/blog.xml" ]; then
            local blog_xml_source="$WT_EXAMPLES_SOURCE_DIR/blog/blog.xml"
            if [ -f "$blog_xml_source" ]; then
                print_status "Copying blog.xml from blog example..."
                cp "$blog_xml_source" "$example_source_dir/"
            else
                print_warning "blog.xml not found in blog example directory"
            fi
        fi
        
        # Check and copy CSS files from blog example if missing
        if [ ! -d "$example_source_dir/css/blog" ]; then
            local blog_css_source="$WT_EXAMPLES_SOURCE_DIR/blog/css"
            if [ -d "$blog_css_source" ]; then
                print_status "Copying blog CSS files..."
                mkdir -p "$example_source_dir/css/blog"
                cp -r "$blog_css_source/"* "$example_source_dir/css/blog/"
            else
                print_warning "Blog CSS directory not found in blog example"
            fi
        fi
        
        # Initialize database if it doesn't exist
        if [ ! -f "$example_source_dir/blog.db" ]; then
            print_status "Initializing blog database..."
            # Create empty database file
            touch "$example_source_dir/blog.db"
        fi
    fi
    
    # Special setup for custom-bs-theme example
    if [ "$example_name" = "custom-bs-theme" ]; then
        print_status "Setting up custom-bs-theme example..."
        
        # Verify the docroot directory exists
        if [ ! -d "$example_source_dir/docroot" ]; then
            print_error "Custom Bootstrap theme docroot directory not found: $example_source_dir/docroot"
            return 1
        fi
        
        # Verify CSS files exist
        if [ ! -f "$example_source_dir/docroot/css/theme.css" ]; then
            print_warning "Custom theme CSS not found. You may need to build the theme:"
            print_warning "  cd $example_source_dir/theme && npm install && npm run build"
        fi
    fi
    
    # Special setup for dbo-form example (requires TinyMCE)
    if [ "$example_name" = "dbo-form" ]; then
        print_status "Setting up dbo-form example..."
        
        # Verify approot directory exists with required files
        if [ ! -d "$example_source_dir/approot" ]; then
            print_error "dbo-form approot directory not found: $example_source_dir/approot"
            return 1
        fi
        
        if [ ! -f "$example_source_dir/approot/templates.xml" ]; then
            print_error "dbo-form templates.xml not found in approot directory"
            return 1
        fi
        
        if [ ! -f "$example_source_dir/approot/strings.xml" ]; then
            print_error "dbo-form strings.xml not found in approot directory"
            return 1
        fi
        
        print_success "Found required template and string files in approot/"
        
        # Check if TinyMCE is available in resources
        if [ ! -d "$WT_RESOURCES_DIR/tinymce" ]; then
            print_warning "TinyMCE not found in resources directory"
            print_status "The dbo-form example requires TinyMCE for rich text editing."
            print_status "Attempting to automatically download and install TinyMCE..."
            
            if wt_setup_tinymce; then
                print_success "TinyMCE installation completed successfully!"
            else
                print_warning "TinyMCE installation failed. Continuing without TinyMCE - rich text editor will not work properly"
                print_info "You can install it manually:"
                echo -e "${YELLOW}Manual installation steps:${NC}"
                echo -e "1. Download from: ${CYAN}https://www.tiny.cloud/get-tiny/self-hosted/${NC}"
                echo -e "2. Extract to: ${CYAN}$WT_RESOURCES_DIR/tinymce/${NC}"
                echo ""
            fi
        else
            print_success "TinyMCE found in resources directory"
        fi
    fi
    
    # Special setup for mandelbrot example (requires graphics dependencies)
    if [ "$example_name" = "mandelbrot" ]; then
        print_status "Setting up mandelbrot example..."
        
        if ! wt_check_example_built "$example_name"; then
            if ! wt_check_graphics_dependencies; then
                print_error "Mandelbrot example requires GD graphics library"
                print_error "Please install graphics dependencies first:"
                echo ""
                echo -e "${YELLOW}Install command:${NC}"
                echo -e "${GREEN}$MODULE_SCRIPT_DIR/dependencies/install_ubuntu.sh${NC}"
                echo ""
                echo -e "${YELLOW}Or install manually:${NC}"
                echo -e "${GREEN}sudo apt install libgd-dev${NC}"
                echo ""
                echo -e "${YELLOW}Then rebuild Wt:${NC}"
                echo -e "${GREEN}cd $PROJECT_ROOT/libs/wt/build && make${NC}"
                return 1
            fi
        fi
        
        print_success "Graphics dependencies verified for mandelbrot example"
    fi
    
    # Special setup for style example (requires graphics dependencies)
    if [ "$example_name" = "style" ]; then
        print_status "Setting up style example..."
        
        if ! wt_check_example_built "$example_name"; then
            if ! wt_check_graphics_dependencies; then
                print_error "Style example requires WRasterImage (graphics library)"
                print_error "Please install graphics dependencies first:"
                echo ""
                echo -e "${YELLOW}Install command:${NC}"
                echo -e "${GREEN}$MODULE_SCRIPT_DIR/dependencies/install_ubuntu.sh${NC}"
                echo ""
                echo -e "${YELLOW}Or install manually:${NC}"
                echo -e "${GREEN}sudo apt install libgd-dev${NC}"
                echo ""
                echo -e "${YELLOW}Then rebuild Wt:${NC}"
                echo -e "${GREEN}cd $PROJECT_ROOT/libs/wt/build && make${NC}"
                return 1
            fi
        fi
        
        print_success "Graphics dependencies verified for style example"
    fi
    
    # Special setup for te-benchmark example (requires PostgreSQL database)
    if [ "$example_name" = "te-benchmark" ]; then
        print_status "Setting up te-benchmark example..."
        
        # Check if PostgreSQL is running
        if ! command -v psql >/dev/null 2>&1; then
            print_error "te-benchmark example requires PostgreSQL"
            print_error "This example is designed for database performance benchmarking"
            echo ""
            echo -e "${YELLOW}Required setup:${NC}"
            echo -e "1. Install PostgreSQL: ${GREEN}sudo apt install postgresql postgresql-contrib${NC}"
            echo -e "2. Start PostgreSQL: ${GREEN}sudo systemctl start postgresql${NC}"
            echo -e "3. Create database and user:"
            echo -e "   ${GREEN}sudo -u postgres createdb hello_world${NC}"
            echo -e "   ${GREEN}sudo -u postgres createuser -s benchmarkdbuser${NC}"
            echo -e "   ${GREEN}sudo -u postgres psql -c \"ALTER USER benchmarkdbuser PASSWORD 'benchmarkdbpass';\"${NC}"
            echo ""
            echo -e "${BLUE}Alternative:${NC} Try other examples that don't require database setup"
            return 1
        fi
        
        # Check if PostgreSQL is running
        if ! systemctl is-active --quiet postgresql 2>/dev/null && ! pgrep postgres >/dev/null 2>&1; then
            print_error "PostgreSQL is not running"
            echo -e "${YELLOW}Start PostgreSQL:${NC} ${GREEN}sudo systemctl start postgresql${NC}"
            return 1
        fi
        
        # Check if database exists
        if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw hello_world 2>/dev/null; then
            print_warning "Database 'hello_world' not found"
            print_status "Setting up PostgreSQL database for te-benchmark automatically..."
            
            if sudo -u postgres createdb hello_world && \
               sudo -u postgres createuser -s benchmarkdbuser 2>/dev/null; \
               sudo -u postgres psql -c "ALTER USER benchmarkdbuser PASSWORD 'benchmarkdbpass';" >/dev/null; then
                print_success "Database setup completed successfully!"
            else
                print_error "Failed to setup database. Please set it up manually:"
                echo -e "${YELLOW}Manual setup commands:${NC}"
                echo -e "${GREEN}sudo -u postgres createdb hello_world${NC}"
                echo -e "${GREEN}sudo -u postgres createuser -s benchmarkdbuser${NC}"
                echo -e "${GREEN}sudo -u postgres psql -c \"ALTER USER benchmarkdbuser PASSWORD 'benchmarkdbpass';\"${NC}"
                return 1
            fi
        fi
        
        print_success "PostgreSQL database verified for te-benchmark example"
    fi
    
    print_status "Preparing to start $example_name example..."
    echo -e "${CYAN}Executable: $example_path${NC}"
    echo -e "${CYAN}Source Dir: $example_source_dir${NC}"
    echo -e "${CYAN}Document Root: $docroot_arg${NC}"
    echo -e "${CYAN}Application Root: $approot_arg${NC}"
    echo -e "${CYAN}Resources: $WT_RESOURCES_DIR${NC}"
    if [ -n "$config_file" ]; then
        echo -e "${CYAN}Config File: $config_file${NC}"
    fi
    echo -e "${CYAN}Port: $port${NC}"
    echo -e "${CYAN}URL: http://localhost:$port${NC}"
    echo ""
    
    echo -e "${YELLOW}📝 How to use this example:${NC}"
    echo -e "   1. Server will start automatically"
    echo -e "   2. Wait for the 'started server' message in the output below"
    echo -e "   3. Open your browser and navigate to: ${BOLD}http://localhost:$port${NC}"
    echo -e "   4. Press Ctrl+C in this terminal to stop the server"
    echo ""
    echo -e "${BLUE}💡 Tip: Keep this terminal open while using the web application${NC}"
    echo ""
    
    # Show example-specific information
    echo -e "${GREEN}About this example:${NC}"
    echo -e "${WT_EXAMPLE_INFO[$example_name]}"
    echo ""
    
    # Show warnings for problematic examples
    if [[ "$example_name" == "feature/locale" || "$example_name" == "locale" ]]; then
        echo -e "${RED}⚠️  Warning: This example has known stability issues${NC}"
        echo -e "${YELLOW}   May crash due to timezone database + GraphicsMagick conflict${NC}"
        echo -e "${YELLOW}   Consider trying: authentication, charts, hello, or DBO tutorials instead${NC}"
        echo ""
    elif [[ "$example_name" == "webgl" ]]; then
        echo -e "${RED}⚠️  Warning: This example crashes when creating WImage widgets${NC}"
        echo -e "${YELLOW}   GraphicsMagick integration issue - try other examples instead${NC}"
        echo ""
    fi
    
    print_status "Starting server automatically..."
    echo ""
    
    # Change to example source directory (this is crucial for Wt examples)
    cd "$example_source_dir" || {
        print_error "Failed to change to example source directory: $example_source_dir"
        return 1
    }
    
    # Run the example
    
    # Check for examples that crash due to WImage/GraphicsMagick issues
    if [[ "$example_name" == "webgl" ]]; then
        echo -e "${YELLOW}⚠️  Known Wt+GraphicsMagick Integration Bug${NC}"
        echo -e "${YELLOW}================================================================${NC}"
        echo -e "${YELLOW}📋 Known Issue: This example crashes when creating WImage widgets${NC}"
        echo -e "${YELLOW}    due to GraphicsMagick segmentation faults during PNG processing.${NC}"
        echo ""
        echo -e "${BLUE}� Technical Details:${NC}"
        echo "   • WebGL example calls: WImage(\"nowebgl.png\")"
        echo "   • This triggers Wt's GraphicsMagick integration"
        echo "   • GraphicsMagick segfaults during programmatic image processing"
        echo "   • Other examples work fine as they don't create WImage widgets"
        echo ""
        echo -e "${BLUE}🔧 Workarounds:${NC}"
        echo "   1. Use examples without WImage widgets (charts, hello, etc.)"
        echo "   2. Rebuild Wt with different image processing backend"
        echo "   3. Fix GraphicsMagick library configuration"
        echo ""
        echo -e "${GREEN}⚡ Attempting to start anyway...${NC}"
        echo -e "${YELLOW}================================================================${NC}"
        echo ""
    elif [[ "$example_name" == "painting" ]]; then
        echo -e "${YELLOW}⚠️  Graphics-Intensive Example${NC}"
        echo -e "${YELLOW}================================================================${NC}"
        echo -e "${YELLOW}📋 This example may have graphics-related issues${NC}"
        echo -e "${GREEN}⚡ Attempting to start...${NC}"
        echo -e "${YELLOW}================================================================${NC}"
        echo ""
    fi
    
    echo -e "${GREEN}================================================================${NC}"
    echo -e "${GREEN}🚀 Starting $example_name Server${NC}"
    echo -e "${GREEN}================================================================${NC}"
    echo -e "${GREEN}🌐 Browser URL: ${BOLD}http://localhost:$port${NC}"
    echo -e "${GREEN}📁 Working Dir: $example_source_dir${NC}"
    echo -e "${GREEN}📁 Resources: $WT_RESOURCES_DIR${NC}"
    echo -e "${GREEN}================================================================${NC}"
    echo ""
    echo -e "${BLUE}📋 Server Output:${NC}"
    echo ""
    
    # Run with proper Wt example arguments
    local docroot_arg="."
    local approot_arg="."
    local config_file=""
    
    # Special configuration for specific examples
    if [ "$example_name" = "custom-bs-theme" ]; then
        docroot_arg="docroot"
        approot_arg="."
    elif [ "$example_name" = "dbo-form" ]; then
        # dbo-form has templates and strings in approot/ subdirectory
        approot_arg="approot"
        if [ -f "$example_source_dir/approot/wt_config.xml" ]; then
            config_file="--config=approot/wt_config.xml"
        fi
    elif [ "$example_name" = "webgl" ]; then
        # Ensure webgl can find nowebgl.png and other assets in source directory
        docroot_arg="$example_source_dir"
        approot_arg="."
    elif [ "$example_name" = "widgetgallery" ]; then
        # widgetgallery has templates and config in approot/, CSS and media in docroot/
        docroot_arg="docroot"
        approot_arg="approot"
        if [ -f "$example_source_dir/approot/wt_config.xml" ]; then
            config_file="--config=approot/wt_config.xml"
        fi
    elif [ "$example_name" = "leaflet" ]; then
        # leaflet has config in approot/ subdirectory
        approot_arg="approot"
        if [ -f "$example_source_dir/approot/wt_config.xml" ]; then
            config_file="--config=approot/wt_config.xml"
        fi
    elif [ "$example_name" = "wt-homepage" ]; then
        # Check for wt-home.xml config file
        if [ -f "$example_source_dir/wt-home.xml" ]; then
            config_file="--config=wt-home.xml"
        fi
    elif [ "$example_name" = "blog" ]; then
        # Check for blog.xml config file
        if [ -f "$example_source_dir/blog.xml" ]; then
            config_file="--config=blog.xml"
        fi
    elif [ "$example_name" = "te-benchmark" ]; then
        # Check for wt_config.xml
        if [ -f "$example_source_dir/wt_config.xml" ]; then
            config_file="--config=wt_config.xml"
        fi
    elif [ "$example_name" = "feature/auth1" ]; then
        # auth1 requires specific config as per README: Additional arguments: -c wt_config.xml
        if [ -f "$example_source_dir/wt_config.xml" ]; then
            config_file="--config=wt_config.xml"
        fi
    elif [ "$example_name" = "feature/auth2" ]; then
        # Check if auth2 also has a config file
        if [ -f "$example_source_dir/wt_config.xml" ]; then
            config_file="--config=wt_config.xml"
        fi
    fi
    
    # Build the command with optional config
    local cmd_args=(
        "--docroot=$docroot_arg"
        "--approot=$approot_arg"
        "--http-port=$port"
        "--http-address=0.0.0.0"
        "--resources-dir=$WT_RESOURCES_DIR"
    )
    
    if [ -n "$config_file" ]; then
        cmd_args+=("$config_file")
    fi
    
    "$example_path" "${cmd_args[@]}"
    local exit_code=$?
    
    echo ""
    echo -e "${BLUE}================================================================${NC}"
    
    if [ $exit_code -eq 0 ]; then
        print_success "Example '$example_name' finished successfully"
    else
        print_error "Example '$example_name' exited with code: $exit_code"
        echo ""
        # Special handling for specific examples
        if [[ "$example_name" == "webgl" ]]; then
            echo -e "${RED}❌ WebGL example crashed (WImage + GraphicsMagick issue)${NC}"
            echo -e "${BLUE}💡 Root Cause: WImage widget creation triggers GraphicsMagick segfault${NC}"
            echo -e "   The example was working until it tried to create WImage(\"nowebgl.png\")"
            echo ""
            echo -e "${YELLOW}🔧 Solutions:${NC}"
            echo -e "   • This is a Wt + GraphicsMagick integration bug"
            echo -e "   • Other examples work fine (charts, hello, etc.)"
            echo -e "   • Try rebuilding Wt with different image backend"
            echo -e "   • The server startup was successful - issue is WImage processing"
        elif [[ "$example_name" == "feature/locale" || "$example_name" == "locale" ]]; then
            echo -e "${RED}❌ Locale example crashed (Date/timezone + GraphicsMagick issue)${NC}"
            echo -e "${BLUE}💡 Root Cause: Timezone database loading fails with GraphicsMagick signal handling${NC}"
            echo -e "   The crash occurs in tz.cpp when loading timezone headers"
            echo ""
            echo -e "${YELLOW}🔧 Solutions:${NC}"
            echo -e "   • This is a Wt date library + GraphicsMagick integration conflict"
            echo -e "   • Other examples work fine (charts, hello, authentication, etc.)"
            echo -e "   • Try rebuilding Wt without GraphicsMagick for timezone examples"
            echo -e "   • The server started but crashed during timezone database initialization"
        elif [[ "$example_name" == "painting" ]]; then
            echo -e "${RED}❌ Graphics example crashed (likely GraphicsMagick segfault)${NC}"
            echo -e "${BLUE}💡 This example may have graphics processing issues.${NC}"
            echo -e "   Try using charts or other non-graphics examples instead."
        else
            echo -e "${RED}❌ Example failed to start or crashed${NC}"
        fi
        echo ""
        echo -e "${YELLOW}Common issues and solutions:${NC}"
        echo -e "  • Port $port might be in use - try again (will auto-select next port)"
        echo -e "  • Firewall might be blocking the connection"
        echo -e "  • Try accessing http://127.0.0.1:$port instead"
        echo -e "  • Check if Wt resources directory exists: $WT_RESOURCES_DIR"
        if [ "$example_name" = "custom-bs-theme" ]; then
            echo -e "  • For custom-bs-theme: Check if CSS files exist in docroot/css/"
            echo -e "  • If theme.css is missing, build it with: cd theme && npm install && npm run build"
        elif [ "$example_name" = "dbo-form" ]; then
            echo -e "  • For dbo-form: Ensure TinyMCE is installed in $WT_RESOURCES_DIR/tinymce/"
            echo -e "  • Download from: https://www.tiny.cloud/get-tiny/self-hosted/"
            echo -e "  • Extract tinymce.min.js to $WT_RESOURCES_DIR/tinymce/"
        fi
    fi
    
    echo -e "${BLUE}================================================================${NC}"
    echo ""
    echo -e "${DIM}Press any key to return to examples menu...${NC}"
    read -n 1 -s
    
    return $exit_code
}

# ===================================================================
# Interactive Menu Functions  
# ===================================================================

# Show examples main menu with two pages (optimized for no flicker)
wt_examples_main_menu() {
    local current_page="basic"  # "basic" or "feature"
    local selected=0
    local need_full_redraw=true
    
    while true; do
        if [ "$need_full_redraw" = true ]; then
            show_header
            echo -e "${BOLD}${BLUE}Wt Examples Manager${NC}"
            echo ""
            need_full_redraw=false
        fi
        
        # Calculate menu items
        local menu_items=()
        if [ "$current_page" = "basic" ]; then
            # Add basic examples to menu
            for example in "${WT_BASIC_EXAMPLES[@]}"; do
                local status=$(wt_get_example_status "$example")
                menu_items+=("Run $example Example $status")
            done
            # Add utility options only
            menu_items+=("ℹ️  View Example Information")
            menu_items+=("🧹 Clean Examples Build Directory")
        else  # feature page
            # Add feature examples to menu
            for example in "${WT_FEATURE_EXAMPLES[@]}"; do
                local display_name=$(echo "$example" | sed 's|feature/||')
                local status=$(wt_get_example_status "$example")
                menu_items+=("Run $display_name Example $status")
            done
            # Add utility options only
            menu_items+=("ℹ️  View Example Information")
            menu_items+=("🧹 Clean Examples Build Directory")
        fi
        
        # Move cursor to position after header
        printf '\033[4;1H'  # Move to line 4, column 1
        
        # Clear from cursor to end of screen
        printf '\033[J'
        
        # Display page title
        if [ "$current_page" = "basic" ]; then
            echo -e "${MAGENTA}Basic Examples:${NC}"
        else
            echo -e "${MAGENTA}Feature Examples:${NC}"
        fi
        echo ""
        
        # Display menu items
        for i in "${!menu_items[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "${BOLD}${GREEN}→ ${menu_items[$i]}${NC}"
            else
                echo -e "  ${menu_items[$i]}"
            fi
        done
        
        echo ""
        echo -e "${DIM}Use ↑/↓ arrows to navigate, ←/→ to switch pages, Enter to select, 'q' to go back${NC}"
        if [ "$current_page" = "basic" ]; then
            echo -e "${DIM}Showing ${#WT_BASIC_EXAMPLES[@]} basic examples (→ for Feature Examples)${NC}"
        else
            echo -e "${DIM}Showing ${#WT_FEATURE_EXAMPLES[@]} feature examples (← for Basic Examples)${NC}"
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
                        if [ $selected -lt $((${#menu_items[@]} - 1)) ]; then
                            selected=$((selected + 1))
                        fi
                        ;;
                    '[C')  # Right arrow - switch to Feature Examples
                        if [ "$current_page" = "basic" ]; then
                            current_page="feature"
                            selected=0
                            need_full_redraw=true
                        fi
                        ;;
                    '[D')  # Left arrow - switch to Basic Examples
                        if [ "$current_page" = "feature" ]; then
                            current_page="basic"
                            selected=0
                            need_full_redraw=true
                        fi
                        ;;
                esac
                ;;
            '')  # Enter key
                wt_handle_examples_selection "$current_page" "$selected"
                ;;
            'q'|'Q')
                return 0
                ;;
        esac
    done
}

# Handle menu selection
wt_handle_examples_selection() {
    local current_page="$1"
    local selected="$2"
    
    if [ "$current_page" = "basic" ]; then
        local num_examples=${#WT_BASIC_EXAMPLES[@]}
        
        if [ $selected -lt $num_examples ]; then
            # Run specific basic example
            local example_name="${WT_BASIC_EXAMPLES[$selected]}"
            wt_run_specific_example "$example_name"
            return 0
        fi
        
        # Handle utility options
        local nav_index=$((selected - num_examples))
        case $nav_index in
            0)  # View Example Information
                wt_examples_show_info "$current_page"
                return 0
                ;;
            1)  # Clean Examples Build Directory
                wt_clean_examples_build
                need_full_redraw=true
                ;;
        esac
        
    else  # feature page
        local num_examples=${#WT_FEATURE_EXAMPLES[@]}
        
        if [ $selected -lt $num_examples ]; then
            # Run specific feature example
            local example_name="${WT_FEATURE_EXAMPLES[$selected]}"
            wt_run_specific_example "$example_name"
            return 0
        fi
        
        # Handle utility options
        local nav_index=$((selected - num_examples))
        case $nav_index in
            0)  # View Example Information
                wt_examples_show_info "$current_page"
                return 0
                ;;
            1)  # Clean Examples Build Directory
                wt_clean_examples_build
                need_full_redraw=true
                ;;
        esac
    fi
}

# Run a specific example with interface and auto-build
wt_run_specific_example() {
    local example_name="$1"
    
    show_header
    echo -e "${BOLD}${BLUE}$example_name Example${NC}"
    echo ""
    
    if ! wt_check_example_built "$example_name"; then
        print_status "Example '$example_name' is not built - building automatically..."
        echo ""
        
        if ! wt_build_single_example "$example_name"; then
            print_error "Failed to build $example_name example"
            wait_for_input
            return 1
        fi
        
        # Check again after build
        if ! wt_check_example_built "$example_name"; then
            print_error "Example '$example_name' still not found after build"
            wait_for_input
            return 1
        fi
        
        print_success "Example built successfully!"
        echo ""
    fi
    
    print_status "Starting $example_name example..."
    wt_run_example "$example_name"
}
# Show example information
wt_examples_show_info() {
    local current_page="${1:-basic}"
    local page_num=1
    local items_per_page=5
    local selected=0
    
    # Determine which examples to show based on page
    local examples_to_show=()
    if [ "$current_page" = "basic" ]; then
        examples_to_show=("${WT_BASIC_EXAMPLES[@]}")
    else
        examples_to_show=("${WT_FEATURE_EXAMPLES[@]}")
    fi
    
    local total_pages=$(( (${#examples_to_show[@]} + items_per_page - 1) / items_per_page ))
    
    while true; do
        show_header
        if [ "$current_page" = "basic" ]; then
            echo -e "${BOLD}${BLUE}Basic Example Information (Page $page_num of $total_pages)${NC}"
        else
            echo -e "${BOLD}${BLUE}Feature Example Information (Page $page_num of $total_pages)${NC}"
        fi
        echo ""
        
        # Calculate start and end indices for current page
        local start_idx=$(( (page_num - 1) * items_per_page ))
        local end_idx=$(( start_idx + items_per_page - 1 ))
        if [ $end_idx -ge ${#examples_to_show[@]} ]; then
            end_idx=$(( ${#examples_to_show[@]} - 1 ))
        fi
        
        # Display examples for current page
        for i in $(seq $start_idx $end_idx); do
            local example="${examples_to_show[$i]}"
            local example_path=$(get_example_executable "$example")
            local display_name="$example"
            
            if [[ "$example" == feature/* ]]; then
                display_name=$(echo "$example" | sed 's|feature/||')
            fi
            
            echo -e "${YELLOW}${BOLD}${display_name^} Example${NC}"
            echo -e "   ${WT_EXAMPLE_INFO[$example]}"
            echo -e "   ${CYAN}Path: $example_path${NC}"
            
            if wt_check_example_built "$example"; then
                echo -e "   ${GREEN}Status: Built and Ready${NC}"
            else
                echo -e "   ${RED}Status: Not built${NC}"
            fi
            echo ""
        done
        
        echo -e "${BLUE}================================================================${NC}"
        echo -e "${YELLOW}Navigation:${NC}"
        
        if [ $page_num -gt 1 ]; then
            echo -e "  ${CYAN}p${NC} - Previous page"
        fi
        if [ $page_num -lt $total_pages ]; then
            echo -e "  ${CYAN}n${NC} - Next page"
        fi
        echo -e "  ${CYAN}q${NC} - Go back"
        echo ""
        echo -e "${YELLOW}Note:${NC} Examples run on ports starting from $WT_EXAMPLES_PORT_BASE"
        if [ "$current_page" = "basic" ]; then
            echo -e "${YELLOW}Total Basic Examples:${NC} ${#WT_BASIC_EXAMPLES[@]} • ${YELLOW}Page:${NC} $page_num/$total_pages"
        else
            echo -e "${YELLOW}Total Feature Examples:${NC} ${#WT_FEATURE_EXAMPLES[@]} • ${YELLOW}Page:${NC} $page_num/$total_pages"
        fi
        echo ""
        
        read -n 1 -s key
        case $key in
            'p'|'P')
                if [ $page_num -gt 1 ]; then
                    page_num=$((page_num - 1))
                fi
                ;;
            'n'|'N')
                if [ $page_num -lt $total_pages ]; then
                    page_num=$((page_num + 1))
                fi
                ;;
            'q'|'Q'|$'\033')
                return 0
                ;;
        esac
    done
}

# ===================================================================
# Module Initialization
# ===================================================================

# Initialize the examples module
wt_examples_init() {
    print_status "Initializing Wt Examples Module..."
    
    # Verify examples directory exists
    if [ ! -d "$WT_EXAMPLES_DIR" ]; then
        print_warning "Examples directory not found: $WT_EXAMPLES_DIR"
        print_warning "Wt may not be built yet or examples may be disabled"
    fi
    
    # Verify source directory exists
    if [ ! -d "$WT_EXAMPLES_SOURCE_DIR" ]; then
        print_warning "Examples source directory not found: $WT_EXAMPLES_SOURCE_DIR"
    fi
    
    # Verify resources directory exists
    if [ ! -d "$WT_RESOURCES_DIR" ]; then
        print_warning "Wt resources directory not found: $WT_RESOURCES_DIR"
    fi
    
    print_success "Wt Examples Module initialized"
    print_status "Found ${#WT_BASIC_EXAMPLES[@]} basic examples and ${#WT_FEATURE_EXAMPLES[@]} feature examples"
}

# Main entry point for the examples module
wt_examples_menu() {
    wt_examples_init
    wt_examples_main_menu
}
