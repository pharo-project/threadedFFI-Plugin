SOURCES=$(notdir $(shell find . -iname '*.c'))
HEADERS=$(notdir $(shell find . -iname '*.h'))
OBJS=$(SOURCES:.c=.o)

all: build/testLibrary.dylib

build/testLibrary.dylib: build $(addprefix build/,$(OBJS))
	clang -dynamiclib -arch i386 -arch x86_64 build/*.o -o build/testLibrary.dylib

build: 
	mkdir -p build

build/%.o: %.c $(HEADERS)
	clang -arch i386 -arch x86_64 -c $< -o $@

clean: 
	rm -rf build
	
