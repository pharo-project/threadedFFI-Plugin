set(BASE_URL 	"http://files.pharo.org/vm/pharo-spur64-headless/linux")
set(URL_NAME	"PharoVM-8.4.0-fecd981-linux64")
set(VM_URL 		"${BASE_URL}/${URL_NAME}-bin.zip")
set(HEADER_URL 	"${BASE_URL}/include/${URL_NAME}-include.zip")

set(LIBFFI_TARGET "x86_64-pc-linux-gnu")

set(LIBFFI_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.so" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.7.so")
set(PHARO_PLUGIN_DIR "pharo-vm/lib/")

set(TEST_LIBRARY_DLL libTestLibrary.so) 

set(DYLIB_EXT "*.so*")

set(LIBFFI_FILES "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib/${DYLIB_EXT}")

set(CMAKE_CURRENT_SOURCE_DIR_TO_OUT ${CMAKE_CURRENT_SOURCE_DIR})
