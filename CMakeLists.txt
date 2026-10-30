CMakeLists.txt
# Xbox-PS4 Bridge Firmware Build System

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

# Project information
project(xbox-ps4-bridge)
set(VERSION "1.0.0")

# Source files
set(SOURCES
    src/main.c
    src/hid_driver.c
    src/bluetooth_stack.c
    src/input_mapper.c
)

set(INCLUDE_DIRS include)

# Build options
option(BUILD_LIBUSB "Build with libusb support" ON)
option(BUILD_NRF51 "Build for Nordic NRF51" OFF)

# Add subdirectories
add_subdirectory(external)

# Main executable
add_executable(${PROJECT_NAME}_firmware ${SOURCES})
target_include_directories(${PROJECT_NAME}_firmware PRIVATE ${INCLUDE_DIRS})

# Firmware image creation
add_custom_command(TARGET ${PROJECT_NAME}_firmware
    POST_BUILD
    COMMAND ${CMAKE_MAKE_PROGRAM} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/flash_image.py
    DEPENDS ${PROJECT_NAME}_firmware
)

# Unit tests
enable_testing()
add_subdirectory(tests)

install(TARGETS ${PROJECT_NAME}_firmware
    DESTINATION bin
)
