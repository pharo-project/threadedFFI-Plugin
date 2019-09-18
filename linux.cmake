set(HEADER_URL "https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/headless/94/artifact/build/build/packages/PharoVM-8.1.0-02626ec-linux64-include.zip") 
set(LIBFFI_TARGET "x86_64-pc-linux-gnu")

set(LIBFFI_OUTPUT "${CMAKE_SOURCE_DIR}/build/bin/libffi.so" "${CMAKE_SOURCE_DIR}/build/bin/libffi.7.so")
set(PHARO_PLUGIN_DIR "pharo-vm/lib/")

set(TEST_LIBRARY_DLL libTestLibrary.so) 

set(DYLIB_EXT "*.so.*")

set(LIBFFI_FILES "${CMAKE_SOURCE_DIR}/build/libffi/install/lib/${DYLIB_EXT}")