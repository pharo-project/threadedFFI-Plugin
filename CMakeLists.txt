cmake_minimum_required(VERSION 2.8.4)

include(macros.cmake)
include(ExternalProject)

if(WIN)
  # specify the cross compiler
  set(CMAKE_TOOLCHAIN_PREFIX x86_64-w64-mingw32)

  SET(CMAKE_C_COMPILER   ${CMAKE_TOOLCHAIN_PREFIX}-clang)
  SET(CMAKE_CXX_COMPILER ${CMAKE_TOOLCHAIN_PREFIX}-clang++)
  SET(CMAKE_RC_COMPILER ${CMAKE_TOOLCHAIN_PREFIX}-windres)
  SET(CMAKE_SYSTEM_PROCESSOR x86_64)
endif()

project(PThreadedFFI)

if(WIN)
    include(win.cmake)
elseif(OSX)
    include(osx.cmake)
else()
    include(linux.cmake)
endif()

set(VERSION_MAJOR 1)
set(VERSION_MINOR 0)
set(VERSION_PATCH 0)

get_commit_hash(GIT_COMMIT_HASH)
get_git_describe(GIT_DESCRIBE)
get_git_date(GIT_COMMIT_DATE)

set(EXECUTABLE_OUTPUT_PATH "build/bin")
set(LIBRARY_OUTPUT_PATH "build/bin")

#
# Creates a custom target to downloand VM headers
#
make_directory("build/vmIncludes")
add_custom_command(
  OUTPUT build/vmIncludes/include/interp.h 
  COMMAND wget ${HEADER_URL}
  COMMAND unzip PharoVM-*-include.zip
  WORKING_DIRECTORY "build/vmIncludes"
  COMMENT "Downloading Pharo VM Headers")

add_custom_target("vmIncludes"
  DEPENDS build/vmIncludes/include/interp.h
  COMMENT "Obtaining Pharo VM Headers")

#
# LibFFI
#

ExternalProject_Add(build_libFFI
    PREFIX "build/libffi"
    SOURCE_DIR "build/libffi/src"
    STAMP_DIR "build/libffi/stamp"
    BINARY_DIR "build/libffi/src"

    UPDATE_COMMAND ""

    GIT_REPOSITORY "https://github.com/libffi/libffi.git"
    GIT_TAG "v3.3-rc0"
    CONFIGURE_COMMAND "./autogen.sh" COMMAND ./configure "--target=${LIBFFI_TARGET}" "--prefix=${CMAKE_SOURCE_DIR}/build/libffi/install"
)

if(OSX)
    add_custom_command(
      OUTPUT "${LIBFFI_OUTPUT}"
      DEPENDS build_libFFI
      COMMAND cp "${CMAKE_SOURCE_DIR}/build/libffi/install/lib/*" "${CMAKE_SOURCE_DIR}/build/bin/"
      COMMAND install_name_tool -id "@executable_path/Plugins/libffi.7.dylib" libffi.7.dylib
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/bin"
      COMMENT "Changing RPath of Libffi")
else()
    add_custom_command(
      OUTPUT "${LIBFFI_OUTPUT}"
      DEPENDS build_libFFI
      COMMAND cp "${CMAKE_SOURCE_DIR}/build/libffi/install/lib/*" "${CMAKE_SOURCE_DIR}/build/bin/"
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/bin"
      COMMENT "Changing RPath of Libffi")
endif()

link_directories("${CMAKE_SOURCE_DIR}/build/libffi/install/lib")

add_custom_target(libFFI DEPENDS "${LIBFFI_OUTPUT}")

#
# Definition of the Plugin
#
set(PLUGIN_NAME PThreadedPlugin)

# Plugin sources
set(PLUGIN_SOURCES
    plugin/src/functionDefinitionPrimitives.c
    plugin/src/primitiveUtils.c
    plugin/src/PThreadedPlugin.c
    plugin/src/types.c
    plugin/src/typesPrimitives.c
    plugin/src/utils.c
    
    plugin/src/callbacks/callbackPrimitives.c
    plugin/src/callbacks/callbacks.c

    plugin/src/queue/threadSafeQueue.c
    
    plugin/src/sameThread/sameThread.c

    plugin/src/semaphores/pharoSemaphore.c
    plugin/src/semaphores/platformSemaphore.c
    plugin/src/semaphores/semaphore.c

    plugin/src/worker/worker.c
    plugin/src/worker/workerPrimitives.c
    plugin/src/worker/workerTask.c
)

addLibraryWithRPATH(${PLUGIN_NAME} SHARED ${PLUGIN_SOURCES})
target_link_libraries(${PLUGIN_NAME} "ffi")

add_dependencies(${PLUGIN_NAME} vmIncludes libFFI)

target_include_directories(${PLUGIN_NAME} PRIVATE "plugin/includes" )
target_include_directories(${PLUGIN_NAME} PRIVATE "build/vmIncludes/include")
target_include_directories(${PLUGIN_NAME} PRIVATE "build/libffi/install/include/" )

#
# Definition of the Test Library
#

set(TEST_LIBRARY TestLibrary)

# Plugin sources
set(TEST_LIBRARY_SOURCES
    testLibrary/src/basic_types.c
    testLibrary/src/callback_types.c
    testLibrary/src/callbacks.c
    testLibrary/src/callout.c
    testLibrary/src/registerCallback.c
    testLibrary/src/structures.c
)

addLibraryWithRPATH(${TEST_LIBRARY} SHARED ${TEST_LIBRARY_SOURCES})
target_include_directories(${TEST_LIBRARY} PRIVATE "testLibrary/includes" )

# 
# Preparing tests
# 

make_directory("${CMAKE_SOURCE_DIR}/build/test")

add_custom_command(
    OUTPUT "${CMAKE_SOURCE_DIR}/build/test/Pharo.image"
    DEPENDS ${TEST_LIBRARY} ${PLUGIN_NAME}
  
  
    COMMAND wget -O - "get.pharo.org/64/80+vmHeadlessLatest" | bash
    COMMAND cp "${CMAKE_SOURCE_DIR}/build/bin/*" ${PHARO_PLUGIN_DIR}
    COMMAND ./pharo Pharo.image metacello install "tonel://../../src" BaselineOfThreadedFFI
    
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/test"
    COMMENT "Creating Test Image")

add_custom_target("prepare-tests" ALL
    DEPENDS "${CMAKE_SOURCE_DIR}/build/test/Pharo.image"
    COMMENT "Preparing Tests")


#
# Adding tests
#

enable_testing()

add_test(
    NAME "UnifiedFFI-Tests"
    COMMAND ./pharo Pharo.image test --junit-xml-output --fail-on-failure "UnifiedFFI-Tests"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/test")

add_test(
    NAME "ThreadedFFI-UFFI-Tests"
    COMMAND ./pharo Pharo.image test --junit-xml-output --fail-on-failure "ThreadedFFI-UFFI-Tests"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/test")

#
# Packaging Setup 
#
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/build/dist")

install(
      DIRECTORY "${CMAKE_SOURCE_DIR}/build/bin/"
      DESTINATION "./"
      USE_SOURCE_PERMISSIONS FILES_MATCHING PATTERN *)

make_directory("build/packages")

get_full_platform_name(FULL_PLATFORM_NAME)

set(CPACK_PACKAGE_DESCRIPTION "Pharo Threaded FFI for ${FULL_PLATFORM_NAME}")
set(CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${VERSION_PATCH}")
set(CPACK_PACKAGE_VENDOR "Pharo")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://pharo.org")
set(CPACK_PACKAGE_FILE_NAME "PThreadedFFI-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${GIT_COMMIT_HASH}-${FULL_PLATFORM_NAME}")
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_SOURCE_DIR}/build/packages")
set(CPACK_PACKAGE_CHECKSUM "SHA1")
set(CPACK_GENERATOR "ZIP")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
   
include (CPack)