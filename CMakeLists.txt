cmake_minimum_required(VERSION 3.10)

include(macros.cmake)
include(ExternalProject)
include(CheckTypeSize)

if ((CMAKE_HOST_UNIX) AND (${CMAKE_HOST_SYSTEM_NAME} MATCHES "CYGWIN*"))
  message(STATUS "Building on CYGWIN CMAKE: Adapting paths")
  set(CYGWIN 1)
  set(WIN 1)

  # specify the cross compiler
  set(CMAKE_TOOLCHAIN_PREFIX x86_64-w64-mingw32)

  SET(CMAKE_C_COMPILER   ${CMAKE_TOOLCHAIN_PREFIX}-gcc)
  SET(CMAKE_CXX_COMPILER ${CMAKE_TOOLCHAIN_PREFIX}-g++)
  SET(CMAKE_RC_COMPILER ${CMAKE_TOOLCHAIN_PREFIX}-windres)
  SET(CMAKE_SYSTEM_PROCESSOR x86_64)
endif()

project(PThreadedFFI)

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(OSX 1)
endif()

if(WIN)
    include(win.cmake)
elseif(OSX)
    include(osx.cmake)
else()
    include(linux.cmake)
endif()

set(VERSION_MAJOR 1)
set(VERSION_MINOR 3)
set(VERSION_PATCH 0)

check_type_size("void*" SIZEOF_VOID_P)

get_commit_hash(GIT_COMMIT_HASH)
get_git_describe(GIT_DESCRIBE)
get_git_date(GIT_COMMIT_DATE)

set(EXECUTABLE_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/build/bin")
set(LIBRARY_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/build/bin")

#
# Creates a custom target to downloand VM headers
#
make_directory("build/vmIncludes")
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/vmIncludes/include/pharovm/pharo.h" 
  COMMAND wget ${HEADER_URL}
  COMMAND unzip PharoVM-*-include.zip
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/vmIncludes"
  COMMENT "Downloading Pharo VM Headers")

add_custom_target(vmIncludes
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/build/vmIncludes/include/pharovm/pharo.h"
  COMMENT "Obtaining Pharo VM Headers")

#
# LibFFI
#

ExternalProject_Add(build_libFFI
    PREFIX "${CMAKE_CURRENT_BINARY_DIR}/build/libffi"
    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/src"
    STAMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/stamp"
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/src"

    UPDATE_COMMAND ""

    GIT_REPOSITORY "https://github.com/libffi/libffi.git"
    GIT_TAG "v3.3"
    CONFIGURE_COMMAND "./autogen.sh" COMMAND ./configure "--target=${LIBFFI_TARGET}" "--disable-docs" "--prefix=${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install" "CC=${CMAKE_C_COMPILER}" "CXX=${CMAKE_C_COMPILER}"
)

if(OSX)
    add_custom_command(
      OUTPUT  ${LIBFFI_OUTPUT}
      DEPENDS build_libFFI
      COMMAND install_name_tool -id "@executable_path/Plugins/libffi.7.dylib" "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib/libffi.7.dylib"
      COMMAND install_name_tool -id "@executable_path/Plugins/libffi.dylib" "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib/libffi.dylib"
      COMMAND cp "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib/${DYLIB_EXT}" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/bin"
      COMMENT "Changing RPath of Libffi")
else()
    add_custom_command(
      OUTPUT  ${LIBFFI_OUTPUT}
      DEPENDS build_libFFI
      COMMAND cp "${LIBFFI_FILES}" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/bin"
      COMMENT "Copying of Libffi")
endif()

link_directories("${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib")

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
    plugin/src/primitiveCalls.c
    
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

if(WIN)
    target_link_libraries(${PLUGIN_NAME} "pthread") 
endif(WIN)

add_dependencies(${PLUGIN_NAME} vmIncludes libFFI)

link_directories(BEFORE "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib")

target_compile_options(${PLUGIN_NAME} PUBLIC "-g")

target_include_directories(${PLUGIN_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/plugin/includes" )
target_include_directories(${PLUGIN_NAME} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/build/vmIncludes/include")
target_include_directories(${PLUGIN_NAME} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/include/" )

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
add_dependencies(${TEST_LIBRARY} ${PLUGIN_NAME} vmIncludes libFFI)
target_compile_options(${TEST_LIBRARY} PUBLIC "-g")

target_include_directories(${TEST_LIBRARY} PRIVATE "${CMAKE_SOURCE_DIR}/testLibrary/includes" )

# 
# Preparing tests
# 

make_directory("${CMAKE_CURRENT_BINARY_DIR}/build/test")

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/test/Pharo.image"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/build/bin/${DYLIB_EXT}" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/${TEST_LIBRARY_DLL}"
  
    COMMAND wget -O - "get.pharo.org/64/90+vmHeadlessLatest" | bash
	COMMAND rm -rf "${CMAKE_CURRENT_BINARY_DIR}/build/test/pharo-vm/*"
	COMMAND wget "${VM_URL}"
	COMMAND unzip "PharoVM-*-bin.zip" -d "${CMAKE_CURRENT_BINARY_DIR}/build/test/pharo-vm/"
    COMMAND cp "${CMAKE_CURRENT_BINARY_DIR}/build/bin/${DYLIB_EXT}" ${PHARO_PLUGIN_DIR}
    COMMAND cp "${CMAKE_CURRENT_BINARY_DIR}/build/bin/${TEST_LIBRARY_DLL}" .
    COMMAND ./pharo Pharo.image metacello install "tonel://${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}/src" BaselineOfThreadedFFI
    
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/test"
    COMMENT "Creating Test Image")

add_custom_target("prepare-tests"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/build/test/Pharo.image"
    COMMENT "Preparing Tests")


#
# Adding tests
#

enable_testing()

add_test(
    NAME "UnifiedFFI-Tests"
    COMMAND ./pharo Pharo.image test --junit-xml-output --fail-on-failure "UnifiedFFI-Tests"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/test")

add_test(
    NAME "ThreadedFFI-UFFI-Tests"
    COMMAND ./pharo Pharo.image test --junit-xml-output --fail-on-failure "ThreadedFFI-UFFI-Tests"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/test")

#
# Packaging Setup 
#
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/build/dist")

install(
      DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/bin/"
      USE_SOURCE_PERMISSIONS
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
set(CPACK_PACKAGE_FILE_NAME "PThreadedFFI-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${FULL_PLATFORM_NAME}")
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/build/packages")
set(CPACK_PACKAGE_CHECKSUM "SHA1")
set(CPACK_GENERATOR "ZIP")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
   
include (CPack)
