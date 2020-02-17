# ThreadedFFI-Plugin

A Threaded FFI plugin for Pharo. It extends the Cog VM with non blocking queue based FFI.
This plugin has two main parts: a VM plugin written in C, and a Pharo library to access it.

## Installation

If you're running a headless VM, you very probably have the threaded FFI plugin with it.

### Installing the Pharo library

You can then load this project importing it through Iceberg, or by executing the following metacello expression:

```smalltalk
Metacello new
		baseline: 'ThreadedFFI';
		repository: 'github://pharo-project/threadedFFI-Plugin';
		onConflictUseLoaded;
		load.
```

If you're missing the plugin, update your headless VM or compile one from sources.

### Compiling the plugin from sources

```bash
cmake .
make install
make test
make package
```
The build results can be found in `build/packages/*`

### Running the tests

Running the tests requires an external library with defined functions and types.
To obtain the test library, you need to compile it from sources.
Then copy it close to your image or your VM.
