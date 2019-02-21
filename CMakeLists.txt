cmake_minimum_required(VERSION 3.10)

project(foo VERSION 1.0 LANGUAGES CXX)

#  --------- targets and dependencies ---------

SET(${PROJECT_NAME}_SRC
    # put all your source files here
    src/${PROJECT_NAME}.cpp
)

# add the library target with the given source files
add_library(${PROJECT_NAME} ${${PROJECT_NAME}_SRC})

# in order to use this project via add_subdirectory, we need to create an alias
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE
        # the headers, that are only needed to compile our target and shall not be visible to anyone else
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC
        # the include directory when building this library
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        # the include directory that we want to distribute on install
        $<INSTALL_INTERFACE:include>
)

# set the required C++ standard for compiling this target
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_11)

#  --------- install and export ---------

# install the files needed for linking (.so, .a, .lib, .dll)

include(GNUInstallDirs)

install(
    TARGETS ${PROJECT_NAME} #if you have more targets to export, put them here
    EXPORT ${PROJECT_NAME}-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# install the public header files
install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# a custom variable for the directory where we want to install all the .cmake files
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# generate *-targets.cmake and *-targets-${DCMAKE_BUILD_TYPE}.cmake for exported targets
install(
    EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${INSTALL_CONFIGDIR}
)

include(CMakePackageConfigHelpers)

# generate the *-config-version.cmake
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

# generate the *-config.cmake from the *-config.cmake.in template
configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/cmake/${PROJECT_NAME}-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

# install the *-config.cmake and *-config-version.cmake
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)
