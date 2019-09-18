set(HEADER_URL "https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/headless/94/artifact/build/build/packages/PharoVM-8.1.0-02626ece-win64-include.zip") 
set(LIBFFI_TARGET "x86_64-unknown-cygwin")

set(LIBFFI_OUTPUT "${CMAKE_SOURCE_DIR}/build/libffi/install/bin/ffi-7.dll")
set(PHARO_PLUGIN_DIR pharo-vm/)

set(TEST_LIBRARY_DLL TestLibrary.dll) 

set(DYLIB_EXT "*.dll")

set(CMAKE_SHARED_LIBRARY_PREFIX "")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".dll")
set(CMAKE_SHARED_MODULE_PREFIX "")
set(CMAKE_SHARED_MODULE_SUFFIX ".dll")    


set(LIBFFI_FILES "${CMAKE_SOURCE_DIR}/build/libffi/install/bin/cygffi-7.dll")