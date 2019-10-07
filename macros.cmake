if ((CMAKE_HOST_UNIX) AND (${CMAKE_HOST_SYSTEM_NAME} MATCHES "CYGWIN*"))
  set(CYGWIN 1)
  set(WIN 1)

  # specify the cross compiler
  set(CMAKE_TOOLCHAIN_PREFIX x86_64-w64-mingw32)

  SET(CMAKE_C_COMPILER   ${CMAKE_TOOLCHAIN_PREFIX}-clang)
  SET(CMAKE_CXX_COMPILER ${CMAKE_TOOLCHAIN_PREFIX}-clang++)
  SET(CMAKE_RC_COMPILER ${CMAKE_TOOLCHAIN_PREFIX}-windres)
  SET(CMAKE_SYSTEM_PROCESSOR x86_64)
endif()

macro(addLibraryWithRPATH NAME)
    SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set(CMAKE_INSTALL_RPATH "@executable_path/Plugins")

    add_library(${NAME} SHARED ${ARGN})
    set_target_properties(${NAME} PROPERTIES MACOSX_RPATH ON)
    set_target_properties(${NAME} PROPERTIES INSTALL_NAME_DIR "@executable_path/Plugins")
endmacro()

macro(get_version VARNAME)
    get_git_describe(TMP_GIT_DESCRIBE)
    string(SUBSTRING ${TMP_GIT_DESCRIBE} 1 -1 ${VARNAME})
endmacro()

macro(get_commit_hash VARNAME)
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(get_git_describe VARNAME)
    execute_process(
        COMMAND git describe --always --tags
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

macro(get_platform_name VARNAME)
    if(WIN)
        set(${VARNAME} "win")
    else()    
        if(OSX)
            set(${VARNAME} "osx")
        else()
            set(${VARNAME} "linux")
        endif()
    endif()
endmacro()

macro(get_full_platform_name VARNAME)
    
    if(SIZEOF_VOID_P EQUAL 8)
        set(ARCH 64)
    else()    
        set(ARCH 32)
    endif()

    if(WIN)
        set(${VARNAME} "win${ARCH}")
    else()    
        if(OSX)
            set(${VARNAME} "osx${ARCH}")
        else()
            set(${VARNAME} "linux${ARCH}")
        endif()
    endif()
endmacro()
