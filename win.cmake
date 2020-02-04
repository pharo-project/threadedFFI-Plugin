set(HEADER_URL "https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/idle/17/artifact/build/build/packages/PharoVM-8.3.0-63efa857-win64-include.zip") 
set(LIBFFI_TARGET "x86_64-unknown-cygwin")

set(LIBFFI_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/bin/ffi-7.dll")
set(PHARO_PLUGIN_DIR pharo-vm/)

set(TEST_LIBRARY_DLL TestLibrary.dll) 

set(DYLIB_EXT "*.dll")

set(CMAKE_SHARED_LIBRARY_PREFIX "")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".dll")
set(CMAKE_SHARED_MODULE_PREFIX "")
set(CMAKE_SHARED_MODULE_SUFFIX ".dll")    


set(LIBFFI_FILES "${CMAKE_CURRENT_BINARY_DIR}/build/libffi/install/bin/cygffi-7.dll")

# transform the path into a windows path with unix backslashes C:/bla/blu
# this is the path required to send as argument to libraries outside of the control of cygwin (like pharo itself)
execute_process(
	COMMAND cygpath ${CMAKE_CURRENT_SOURCE_DIR} --mixed
	OUTPUT_VARIABLE CMAKE_CURRENT_SOURCE_DIR_TO_OUT
	OUTPUT_STRIP_TRAILING_WHITESPACE)
