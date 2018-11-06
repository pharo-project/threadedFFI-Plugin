OS=$(shell ../scripts/getOS.sh)

all:
	$(MAKE) -f Makefile.$(OS) all ARCHITECTURE=32
	$(MAKE) -f Makefile.$(OS) all ARCHITECTURE=64	

clean:
	$(MAKE) -f Makefile.$(OS) clean ARCHITECTURE=32
	$(MAKE) -f Makefile.$(OS) clean ARCHITECTURE=64	