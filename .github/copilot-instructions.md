# Project Overview

General pourpose WT (Web Toolkit) project for developing web applications in C++. 
It contains my personal CV page and various examples of utilizing Wt to develop web applications.


## Folder Structure

- **`/src`**: Contains the C++ source code organized in folders with numeric prefixes (e.g., `001_`, `002_`, etc.)
- **`/resources`**: Contains the resource files from Wt library (**⚠️ DO NOT EDIT ⚠️**)
- **`/static`**: Contains static files such as CSS, JavaScript, and images used in the web application.


## Libraries and Frameworks

- [Wt (Web Toolkit)](https://www.webtoolkit.eu/wt): A C++ library for developing web applications.
- [CMake](https://cmake.org/): A cross-platform build system generator.
- [Boost](https://www.boost.org/): A set of C++ libraries that provide support for tasks and structures such as linear algebra, pseudorandom number generation, multithreading, image processing, regular expressions, and unit testing. Additonaly this library is required by Wt.
- [Tailwind CSS](https://tailwindcss.com/): A utility-first CSS framework for rapidly building custom user interfaces. Used for styling the web application.
- [SQLite](https://www.sqlite.org/index.html): A C library that provides a lightweight, disk-based database that doesn’t require a separate server process and allows access to the database using a nonstandard variant of the SQL query language. Used by this app in debug mode for data storage.
- [PostgreSQL](https://www.postgresql.org/): An open-source relational database management system emphasizing extensibility and SQL compliance. Used by this app in production mode for data storage.
- [Docker](https://www.docker.com/): A platform for developing, shipping, and running applications in containers. Used to containerize the application for easier deployment.


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
- Use `LOG_ERROR`, `LOG_WARN`, `LOG_INFO`, `LOG_DEBUG` macros
- Define logger: `LOGGER("ClassName")`


## UI guidelines

- Application should have a modern and clean design.