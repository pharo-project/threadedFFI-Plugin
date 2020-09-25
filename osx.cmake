set(BASE_URL 	"http://files.pharo.org/vm/pharo-spur64-headless/mac")
set(URL_NAME	"PharoVM-8.5.0-3cf4aab2-mac64")
set(VM_URL 		"${BASE_URL}/${URL_NAME}-bin.zip")
set(HEADER_URL 	"${BASE_URL}/include/${URL_NAME}-include.zip")

set(LIBFFI_TARGET "x86_64-apple-darwin")

set(LIBFFI_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.dylib" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.7.dylib")
set(PHARO_PLUGIN_DIR pharo-vm/Pharo.app/Contents/MacOS/Plugins/)

set(TEST_LIBRARY_DLL libTestLibrary.dylib) 

set(DYLIB_EXT "*.dylib")

set(CMAKE_CURRENT_SOURCE_DIR_TO_OUT ${CMAKE_CURRENT_SOURCE_DIR})

execute_process(
    COMMAND xcrun --show-sdk-path
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE OSX_SDK_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE)


set(LIBFFI_ADDITIONAL "CPATH=${OSX_SDK_PATH}/usr/include")
