# OpenTDM CMake build script
# Based on Vortex project build system

cmake_minimum_required(VERSION 3.5)
project(OpenTDM C)

# Force 32-bit compilation on Windows
if (WIN32)
    set(CMAKE_GENERATOR_PLATFORM Win32)
endif()

# Source files (matching Makefile OBJS)
set(OPENTDM_SOURCES
    g_chase.c
    g_cmds.c
    g_combat.c
    g_func.c
    g_items.c
    g_main.c
    g_misc.c
    g_net.c
    g_phys.c
    g_save.c
    g_spawn.c
    g_svcmds.c
    g_target.c
    g_tdm_client.c
    g_tdm_cmds.c
    g_tdm_core.c
    g_tdm_curl.c
    g_tdm_macros.c
    g_tdm_stats.c
    g_tdm_vote.c
    g_tdm_votemenu.c
    g_trigger.c
    g_utils.c
    g_weapon.c
    mt19937.c
    p_client.c
    p_hud.c
    p_menu.c
    p_view.c
    p_weapon.c
    q_shared.c
)

# Platform-specific sources
if (WIN32)
    list(APPEND OPENTDM_SOURCES sys_win32.c)
else()
    list(APPEND OPENTDM_SOURCES sys_linux.c)
endif()

# Conditionally add curl support
option(OPENTDM_USE_CURL "Enable libcurl support for web configs" OFF)

# Output name
if (WIN32)
    set(CC_LIB_NAME gamex86)
elseif(UNIX)
    execute_process(COMMAND uname -m COMMAND sed s/i.86/i386/ COMMAND tr -d \n OUTPUT_VARIABLE ARCH)
    set(CC_LIB_NAME game${ARCH})
endif()

# Build as shared library (DLL)
add_library(${CC_LIB_NAME} SHARED ${OPENTDM_SOURCES})

# Add definitions
target_compile_definitions(${CC_LIB_NAME} PRIVATE
    C_ONLY
    OPENTDM_VERSION="dev"
    OPENTDM_REVISION=0
)

if (NOT OPENTDM_USE_CURL)
    # Don't define HAVE_CURL, so g_tdm_curl.c stubs are used
else()
    target_compile_definitions(${CC_LIB_NAME} PRIVATE HAVE_CURL CURL_STATICLIB)
    if (WIN32)
        target_include_directories(${CC_LIB_NAME} PRIVATE deps/win32/include)
    endif()
endif()

# Include current directory
target_include_directories(${CC_LIB_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Platform-specific settings
if (WIN32)
    target_link_libraries(${CC_LIB_NAME} ws2_32)
elseif(UNIX)
    target_link_libraries(${CC_LIB_NAME} m)
endif()

# Compiler-specific flags
if (MSVC)
    target_compile_options(${CC_LIB_NAME} PRIVATE /W3 /wd4996 /wd4244 /wd4267)
    target_compile_definitions(${CC_LIB_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /O2 /Oi /Ot /GL")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /LTCG /OPT:REF /OPT:ICF")
elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
    target_compile_options(${CC_LIB_NAME} PRIVATE -Wall -fPIC -fvisibility=hidden -fcommon -fno-strict-aliasing)
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O2")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0 -g3")
endif()

# Remove "lib" prefix on Unix
if (UNIX)
    set_target_properties(${CC_LIB_NAME} PROPERTIES PREFIX "")
endif()
