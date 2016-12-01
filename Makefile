CONFIGUREFLAGS += --enable-tests

default: test

VERSION = 4.03.0
DEPS = oasis yojson merlin ounit ocamlfind

# Requires opam to have been installed.
init:
	opam switch $(VERSION)
	opam install $(DEPS)

ARCH := $(shell uname -p)
PLAT := $(shell uname | tr [:upper:] [:lower:])
GITREF := $(shell git describe --tags)
RELBASE := $(shell mktemp -d /tmp/sundial-XXXXXXXX)
RELNAME := sundial-$(GITREF)-$(ARCH)-$(PLAT)
RELDIR := $(RELBASE)/$(RELNAME)

BINREL_FILES := README.md LICENSE AUTHORS
BINREL_DIST := $(RELNAME).tar.gz

release: clean test
	echo ''
	git diff-index --quiet HEAD -- || echo 'Working tree is dirty.' && false
	mkdir -p $(RELDIR)
	cp $(BINREL_FILES) $(RELDIR)/
	cp Main.native $(RELDIR)/sundial
	cd $(RELBASE) && tar cf $(BINREL_DIST) $(RELNAME)/
	cp $(RELBASE)/$(BINREL_DIST) .
	rm -rf $(RELBASE)

SRCREL_DIST := $(RELNAME)-src.tar.gz

release-src: test clean release-clean
	echo ''
	git diff-index --quiet HEAD -- || echo 'Tree is dirty.' && false
	mkdir -p $(RELDIR)
	cp -R * $(RELDIR)/
	cd $(RELBASE) && tar cf $(SRCREL_DIST) $(RELNAME)/
	cp $(RELBASE)/$(SRCREL_DIST) .
	rm -rf $(RELBASE)

release-clean:
	rm -f BINREL_DIST
	rm -f SRCREL_DIST

.PHONY: default init release release-src release-clean oasis-setup

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
