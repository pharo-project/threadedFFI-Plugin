cmake_minimum_required(VERSION 2.8.4)

include(ExternalProject)

macro(get_commit_hash VARNAME)
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(get_git_describe VARNAME)
    execute_process(
        COMMAND git describe --always
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(get_git_date VARNAME)
    execute_process(
        COMMAND git log -1 --format=%ai
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

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
  COMMAND wget https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/headless/79/artifact/build/packages/PharoVM-8.1.0-5427b3f-mac64-include.zip
  COMMAND unzip PharoVM-*-include.zip
  WORKING_DIRECTORY "build/vmIncludes"
  COMMENT "Downloading Pharo VM Headers")

add_custom_target("vmIncludes"
  DEPENDS build/vmIncludes/include/interp.h
  COMMENT "Obtaining Pharo VM Headers")

#
# LibFFI
#

ExternalProject_Add(libFFI
    PREFIX "build/libffi"
    SOURCE_DIR "build/libffi/src"
    STAMP_DIR "build/libffi/stamp"
    BINARY_DIR "build/libffi/src"

    GIT_REPOSITORY "https://github.com/libffi/libffi.git"
    GIT_TAG "v3.3-rc0"
    CONFIGURE_COMMAND "./autogen.sh" COMMAND ./configure "--target=x86_64-apple-darwin" "--prefix=${CMAKE_SOURCE_DIR}/build/libffi/install"
)

link_directories("${CMAKE_SOURCE_DIR}/build/libffi/install/lib")

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

add_library(${PLUGIN_NAME} SHARED ${PLUGIN_SOURCES})
target_link_libraries(${PLUGIN_NAME} "ffi")

add_dependencies(${PLUGIN_NAME} vmIncludes libFFI)

target_include_directories(${PLUGIN_NAME} PRIVATE "plugin/includes" )
target_include_directories(${PLUGIN_NAME} PRIVATE "build/vmIncludes/include")

#
# Definition of the Test Library
#

set(TEST_LIBRARY testLibrary)

# Plugin sources
set(TEST_LIBRARY_SOURCES
    testLibrary/src/basic_types.c
    testLibrary/src/callback_types.c
    testLibrary/src/callbacks.c
    testLibrary/src/callout.c
    testLibrary/src/registerCallback.c
    testLibrary/src/structures.c
)

add_library(${TEST_LIBRARY} SHARED ${TEST_LIBRARY_SOURCES})
target_include_directories(${TEST_LIBRARY} PRIVATE "testLibrary/includes" )