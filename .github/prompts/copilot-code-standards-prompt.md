# Copilot Agent Code Standards Analysis Prompt

## Task
Analyze all files in the specified folder and ensure they adhere to the coding standards defined in this C++ Wt (Web Toolkit) project. Make necessary changes to bring the code into compliance with the established conventions.

## Folder to Analyze
**Target Folder:** `[SPECIFY_FOLDER_PATH_HERE]`

## Coding Standards to Enforce

### For Source Code Files (src/**)

#### Naming Conventions
- **Public API classes**: PascalCase with `W` prefix (e.g., `WApplication`, `WWidget`, `WString`)
- **Internal classes**: PascalCase without prefix (e.g., `MetaHeader`, `ScriptLibrary`)
- **Enums**: PascalCase (e.g., `MetaHeaderType`, `LayoutDirection`)
- **Public methods**: camelCase (e.g., `setTitle()`, `enableAjax()`, `internalPath()`)
- **Getters**: Direct name without "get" prefix (e.g., `title()`, `locale()`)
- **Setters**: "set" prefix (e.g., `setTitle()`, `setLocale()`)
- **Boolean queries**: "is" or "has" prefix (e.g., `isExposed()`, `hasSessionIdInUrl()`)
- **Member variables**: camelCase with trailing underscore (e.g., `session_`, `titleChanged_`, `enableAjax_`)
- **Local variables**: camelCase (e.g., `result`, `version`, `thisVersion`)
- **Constants**: ALL_CAPS with underscores (e.g., `RESOURCES_URL`)
- **Parameters**: camelCase (e.g., `javascript`, `internalPath`, `aType`)

#### Code Structure
- **No `using namespace` directives in headers**
- Use `std::unique_ptr` for ownership
- Use `std::shared_ptr` for shared ownership
- Use `std::weak_ptr` to break circular references
- Raw pointers for non-owning references
- Methods that don't modify state marked `const`
- Use `const` references for parameters when appropriate
- Use `Wt::log("info/error/warning/debug")` for logging

#### Tailwind CSS Classes for Theming
**Light mode:**
- Background: `bg-gray-50` or `bg-white`
- Text: `text-gray-900`
- Border: `border-gray-200`
- Cards: `bg-white`
- Subtle areas: `bg-gray-100`
- Hover: `hover:bg-gray-150`

**Dark mode:**
- Background: `bg-gray-900` or `bg-gray-800`
- Text: `text-gray-100`
- Border: `border-gray-700`
- Cards: `bg-gray-800`
- Subtle areas: `bg-gray-700`
- Hover: `hover:bg-gray-700`

### For Script Files (scripts/**)

#### Required Template Structure
Every script must begin with:
```bash
#!/usr/bin/env bash
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

#### Variable Naming for Nested Scripts
- For `scripts/libs/wt/`: Use `WT_SCRIPT_DIR`, output to `scripts/output/libs/wt/`
- For `scripts/app/`: Use `APP_SCRIPT_DIR`, output to `scripts/output/app/`
- For root scripts: Use `SCRIPT_DIR`, output to `scripts/output/`

#### Logging Standards
- Root scripts: Log to `scripts/output/script.log`
- App scripts: Log to `scripts/output/app/script.log`
- Library scripts: Log to `scripts/output/libs/wt/script.log`

## Analysis Instructions

1. **Examine each file** in the specified folder and its subdirectories
2. **Identify violations** of the coding standards listed above
3. **Create a comprehensive report** of all issues found, organized by:
   - File path
   - Type of violation (naming, structure, style, etc.)
   - Current code vs. expected standard
   - Severity (critical, moderate, minor)
4. **Implement fixes** for all identified violations
5. **Verify compliance** after changes are made
6. **Provide a summary** of all changes made

## Special Considerations

- **Preserve functionality** - ensure all changes maintain existing behavior
- **Follow Wt library conventions** - respect the Web Toolkit's patterns and idioms
- **Maintain backward compatibility** - don't break existing APIs unless necessary
- **Test critical changes** - verify that important functionality still works
- **Document significant changes** - explain any major refactoring decisions

## Output Format

Provide:
1. **Analysis Summary**: Overview of files examined and issues found
2. **Detailed Report**: File-by-file breakdown of violations and fixes
3. **Changes Made**: List of all modifications with explanations
4. **Compliance Status**: Final assessment of adherence to standards
5. **Recommendations**: Suggestions for maintaining standards going forward

---

**Important:** Before starting analysis, verify that you have access to context7 MCP for Wt library documentation and usage examples. This will ensure proper understanding of Wt conventions and best practices.