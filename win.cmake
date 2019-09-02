set(HEADER_URL "https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/headless/83/artifact/build/packages/PharoVM-8.1.0-59aa2c8-win64-include.zip") 
set(LIBFFI_TARGET "x86_64-unknown-cygwin")

set(LIBFFI_OUTPUT "${CMAKE_SOURCE_DIR}/build/bin/libffi.dylib" "${CMAKE_SOURCE_DIR}/build/bin/libffi.7.dylib")
set(PHARO_PLUGIN_DIR pharo-vm/Pharo.app/Contents/MacOS/Plugins/)

set(DYLIB_EXT "*.dll")