# Project Overview

General pourpose WT (Web Toolkit) project for developing web applications in C++. 
It contains my personal CV page and various examples of utilizing Wt to develop web applications.


## Folder Structure

- **`/src`**: Contains the C++ source code organized in folders with numeric prefixes (e.g., `001_`, `002_`, etc.)
- **`/resources`**: Contains the resource files from Wt library (**⚠️ DO NOT EDIT ⚠️**)
- **`/static`**: Contains static files such as CSS, JavaScript, and images used in the web application.
- **`/static/0-stylus`**: Contains xml files, tailwind configuration and js files. Those files are manadged by stylus widgets to create edit and delete xml templates, tailwind configuration and js files.
- **`/build/debug`**: Directory for debug build artifacts.
- **`/build/release`**: Directory for release build artifacts.
- **`CMakeLists.txt`**: CMake build configuration file.



## Libraries and Frameworks

- [Wt (Web Toolkit)](https://www.webtoolkit.eu/wt): A C++ library for developing web applications.
- [CMake](https://cmake.org/): A cross-platform build system generator.
- [Boost](https://www.boost.org/): A set of C++ libraries that provide support for tasks and structures such as linear algebra, pseudorandom number generation, multithreading, image processing, regular expressions, and unit testing. Additonaly this library is required by Wt.
- [Tailwind CSS](https://tailwindcss.com/): A utility-first CSS framework for rapidly building custom user interfaces. Used for styling the web application.
- [SQLite](https://www.sqlite.org/index.html): A C library that provides a lightweight, disk-based database that doesn’t require a separate server process and allows access to the database using a nonstandard variant of the SQL query language. Used by this app in debug mode for data storage.
- [PostgreSQL](https://www.postgresql.org/): An open-source relational database management system emphasizing extensibility and SQL compliance. Used by this app in production mode for data storage.
- [Docker](https://www.docker.com/): A platform for developing, shipping, and running applications in containers. Used to containerize the application for easier deployment.


## UI guidelines

- Application should have a modern and clean design.