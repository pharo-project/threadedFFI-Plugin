set(VM_URL 		"https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/idle/17/artifact/build/build/packages/PharoVM-8.3.0-63efa85-linux64-bin.zip")
set(HEADER_URL 	"https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/idle/17/artifact/build/build/packages/PharoVM-8.3.0-63efa85-linux64-include.zip") 
set(LIBFFI_TARGET "x86_64-pc-linux-gnu")

set(LIBFFI_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.so" "${CMAKE_CURRENT_BINARY_DIR}/build/bin/libffi.7.so")
set(PHARO_PLUGIN_DIR "pharo-vm/lib/")

set(TEST_LIBRARY_DLL libTestLibrary.so) 

set(DYLIB_EXT "*.so*")

set(LIBFFI_FILES "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/lib/${DYLIB_EXT}")

set(CMAKE_CURRENT_SOURCE_DIR_TO_OUT ${CMAKE_CURRENT_SOURCE_DIR})
