set(HEADER_URL "https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/idle/9/artifact/build/build/packages/PharoVM-8.3.0-ed72d63-mac64-include.zip") 
set(LIBFFI_TARGET "x86_64-apple-darwin")

set(LIBFFI_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.dylib" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.7.dylib")
set(PHARO_PLUGIN_DIR pharo-vm/Pharo.app/Contents/MacOS/Plugins/)

set(TEST_LIBRARY_DLL libTestLibrary.dylib) 

set(DYLIB_EXT "*.dylib")

set(CMAKE_CURRENT_SOURCE_DIR_TO_OUT ${CMAKE_CURRENT_SOURCE_DIR})
