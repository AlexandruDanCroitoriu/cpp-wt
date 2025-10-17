---
applyTo: "src/**"
---

## Coding Standards

### Naming Conventions

#### Classes and Types
- **Public API classes**: PascalCase with `W` prefix (e.g., `WApplication`, `WWidget`, `WString`)
- **Internal classes**: PascalCase without prefix (e.g., `MetaHeader`, `ScriptLibrary`)
- **Enums**: PascalCase (e.g., `MetaHeaderType`, `LayoutDirection`)

#### Functions and Methods
- **Public methods**: camelCase (e.g., `setTitle()`, `enableAjax()`, `internalPath()`)
- **Getters**: Direct name without "get" prefix (e.g., `title()`, `locale()`)
- **Setters**: "set" prefix (e.g., `setTitle()`, `setLocale()`)
- **Boolean queries**: "is" or "has" prefix (e.g., `isExposed()`, `hasSessionIdInUrl()`)

#### Variables
- **Member variables**: camelCase with trailing underscore (e.g., `session_`, `titleChanged_`, `enableAjax_`)
- **Local variables**: camelCase (e.g., `result`, `version`, `thisVersion`)
- **Constants**: ALL_CAPS with underscores (e.g., `RESOURCES_URL`)

#### Parameters
- camelCase (e.g., `javascript`, `internalPath`, `aType`)
- Constructor parameters may use "a" prefix to distinguish from members (e.g., `aType`, `aName`, `aContent`)

### Code Structure

#### Namespace
- No `using namespace` directives in headers

#### Memory Management
- Use `std::unique_ptr` for ownership
- Use `std::shared_ptr` for shared ownership
- Use `std::weak_ptr` to break circular references
- Raw pointers for non-owning references

#### Const Correctness
- Methods that don't modify state marked `const`
- Use `const` references for parameters when appropriate

#### Logging
- Use `Wt::log("info/error/warning/debug")` for logging


## Important Note

**⚠️ IMPORTANT: Before working with this project, please check context7 for documentation and usage examples of all libraries used in this project. Context7 provides essential context on how to properly use Wt, Boost, CMake, and other dependencies.**

**If context7 MCP is not active, please start the MCP server to access the comprehensive library documentation and coding examples.**