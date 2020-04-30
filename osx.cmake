set(BASE_URL 	"http://files.pharo.org/vm/pharo-spur64-headless/mac")
set(URL_NAME	"PharoVM-8.4.0-fecd981-mac64")
set(VM_URL 		"${BASE_URL}/${URL_NAME}-bin.zip")
set(HEADER_URL 	"${BASE_URL}/include/${URL_NAME}-include.zip")

set(LIBFFI_TARGET "x86_64-apple-darwin")

set(LIBFFI_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.dylib" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.7.dylib")
set(PHARO_PLUGIN_DIR pharo-vm/Pharo.app/Contents/MacOS/Plugins/)

set(TEST_LIBRARY_DLL libTestLibrary.dylib) 

set(DYLIB_EXT "*.dylib")

set(CMAKE_CURRENT_SOURCE_DIR_TO_OUT ${CMAKE_CURRENT_SOURCE_DIR})
