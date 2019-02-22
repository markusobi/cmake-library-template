cmake_minimum_required(VERSION 3.10)

project(foo
    VERSION 1.0
    LANGUAGES CXX
)

#  --------- targets and dependencies ---------

set(PACKAGE_NAME foo)
set(LIBRARY_NAME bar)

# add the library target with the given source files
add_library(${LIBRARY_NAME} "")

# benefit of adding a header as source: it will listed in the IDE
target_sources(${LIBRARY_NAME}
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/src/bar/bar.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/utils/utils.h
)

target_include_directories(${LIBRARY_NAME}
    PRIVATE
        # the headers, that are only needed to compile our target and shall not be visible to anyone else
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC
        # the include directory must be available while building and at a new location after installing
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# in order to use this project via add_subdirectory, we need to create an alias
add_library(${PACKAGE_NAME}::${LIBRARY_NAME} ALIAS ${LIBRARY_NAME})

# optional: set the required C++ standard for compiling this target
# target_compile_features(${LIBRARY_NAME} PRIVATE cxx_std_11)

# auto export all function/class symbols when compiled as shared windows library
set_target_properties(${LIBRARY_NAME} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)



#  --------- install binaries and headers ---------

include(GNUInstallDirs)

# install the executables and files needed for linking (.so, .a, .lib, .dll)
install(
    TARGETS ${LIBRARY_NAME} #if you have more targets to export, put them here
    EXPORT ${PACKAGE_NAME}-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# install the public header files
install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

#  --------- install cmake package ---------

# a user defined variable for the directory where we want to install all the .cmake files
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE_NAME})

# generate *-targets.cmake and *-targets-${DCMAKE_BUILD_TYPE}.cmake for exported targets
install(
    EXPORT ${PACKAGE_NAME}-targets
    FILE ${PACKAGE_NAME}-targets.cmake
    NAMESPACE ${PACKAGE_NAME}::
    DESTINATION ${INSTALL_CONFIGDIR}
)

include(CMakePackageConfigHelpers)

# generate the *-config-version.cmake
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

# generate the *-config.cmake from the *-config.cmake.in template
configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/cmake/${PACKAGE_NAME}-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

# install the *-config.cmake and *-config-version.cmake
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)
