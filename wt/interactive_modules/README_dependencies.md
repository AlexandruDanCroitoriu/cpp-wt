# Dependencies Configuration Module

## Overview
This module provides an interactive interface for manually installing and uninstalling system dependencies required for the Wt library. It replaces the previous automated installation script with a more granular, user-controlled approach.

## Features

### Package Categories
Dependencies are organized into logical categories:
- **Core Build Tools**: Essential compilation tools (gcc, cmake, git, etc.)
- **Wt Required**: Core dependencies for Wt library compilation
- **Database Backends**: Support for MySQL, PostgreSQL, SQLite
- **Graphics & Media**: Image processing and OpenGL libraries
- **Optional Packages**: Additional tools for enhanced functionality

### Interactive Controls

#### Navigation
- **↑/↓ Arrow Keys**: Navigate through categories and packages
- **Enter**: Select category or toggle package installation/uninstallation
- **'b'**: Go back to category selection from package view
- **'q'**: Exit to main menu

#### Package Management
- **'i' Key**: Install the currently selected package
- **'u' Key**: Uninstall the currently selected package
- **Enter**: Toggle installation status (install if not installed, uninstall if installed)

### Status Indicators
- **Green "Installed"**: Package is currently installed
- **Red "Not Installed"**: Package is not installed
- **Category counters**: Shows "X/Y installed" for each category

### Safety Features
- **Confirmation dialogs**: Asks for confirmation before installing/uninstalling
- **Status checking**: Prevents redundant operations
- **Sudo privilege checking**: Validates permissions before showing menu
- **Detailed descriptions**: Shows package purpose and current status

## Usage Flow

1. Start the interactive script: `./scripts/interactive.sh`
2. Select "Libraries" from main menu
3. Select "Install System Dependencies"
4. Choose a category (Core, Wt Required, etc.)
5. Navigate to specific packages and use 'i'/'u' keys or Enter to manage them
6. Confirmation dialog appears for each action
7. Real-time status updates show installation progress

## Implementation Details

### Architecture
- **Module-based design**: Follows project standards with proper initialization
- **Package categorization**: Organized data structure for easy maintenance
- **Status verification**: Real-time checking using `dpkg` commands
- **Error handling**: Graceful failure recovery with user feedback

### Integration
- Seamlessly integrated with existing interactive script framework
- Uses standard project colors and navigation patterns
- Maintains consistency with other modules
- Logs all operations to standard output directory

This provides much more control than the previous all-or-nothing installation approach, allowing users to selectively install only the dependencies they need for their specific use case.
