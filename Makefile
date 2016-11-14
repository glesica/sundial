CONFIGUREFLAGS += --enable-tests

default: test

ARCH = $(shell uname -p)
PLAT = $(shell uname | tr [:upper:] [:lower:])
GITREF = $(shell ./scripts/branch.sh)
RELNAME = sundial-$(GITREF)-$(ARCH)-$(PLAT)
RELDIR = _release/$(RELNAME)

release: clean test
	mkdir -p $(RELDIR)
	cp README.md LICENSE $(RELDIR)/
	cp Main.native $(RELDIR)/sundial
	cd _release && tar cf $(RELNAME).tar.gz $(RELNAME)/
	rm -rf $(RELDIR)

release-clean:
	rm -rf _release

# OASIS_START
# DO NOT EDIT (digest: a3c674b4239234cbbe53afe090018954)

SETUP = ocaml setup.ml

build: setup.data
	$(SETUP) -build $(BUILDFLAGS)

doc: setup.data build
	$(SETUP) -doc $(DOCFLAGS)

test: setup.data build
	$(SETUP) -test $(TESTFLAGS)

all:
	$(SETUP) -all $(ALLFLAGS)

install: setup.data
	$(SETUP) -install $(INSTALLFLAGS)

uninstall: setup.data
	$(SETUP) -uninstall $(UNINSTALLFLAGS)

reinstall: setup.data
	$(SETUP) -reinstall $(REINSTALLFLAGS)

clean:
	$(SETUP) -clean $(CLEANFLAGS)

distclean:
	$(SETUP) -distclean $(DISTCLEANFLAGS)

setup.data:
	$(SETUP) -configure $(CONFIGUREFLAGS)

configure:
	$(SETUP) -configure $(CONFIGUREFLAGS)

.PHONY: build doc test all install uninstall reinstall clean distclean configure

# OASIS_STOP
