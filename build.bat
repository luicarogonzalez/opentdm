@echo off
echo OpenTDM Quake 2 Mod Build Script
echo ==================================

REM Check for cmake presence
where cmake >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: CMake not found in PATH.
    echo Please install CMake or add it to your PATH.
    exit /b 1
)

REM Parse command line arguments
set BUILD_TYPE=%1
set BUILD_BOTH=0

REM Check if we want to build both configurations
if /i "%1"=="both" (
    set BUILD_BOTH=1
    echo Building both Debug and Release configurations...
) else (
    REM Default to Release if not specified
    if "%BUILD_TYPE%"=="" set BUILD_TYPE=Release
    echo Build Type: %BUILD_TYPE%
)

REM Create build directory if it doesn't exist
if not exist build mkdir build

REM Run CMake to configure the project
echo Configuring project with CMake...
cmake -S . -B build -G "Visual Studio 17 2022" -A Win32 -D CMAKE_GENERATOR_INSTANCE="C:/Program Files/Microsoft Visual Studio/2022/Enterprise"
if %ERRORLEVEL% NEQ 0 (
    echo Error: CMake configuration failed.
    exit /b 1
)

REM Build the project(s)
if %BUILD_BOTH%==1 (
    REM Build Debug configuration
    echo Building Debug configuration...
    cmake --build build --config Debug
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Debug build failed.
        exit /b 1
    )

    REM Build Release configuration
    echo Building Release configuration...
    cmake --build build --config Release
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Release build failed.
        exit /b 1
    )

    echo ==============================
    echo Both configurations built successfully!
) else (
    echo Building %BUILD_TYPE% configuration...
    cmake --build build --config %BUILD_TYPE%
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Build failed.
        exit /b 1
    )

    echo ==============================
    echo Build successful!
)
