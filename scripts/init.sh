#!/usr/bin/env bash

VERSION='4.03.0'
DEPS='oasis yojson merlin ounit ocamlfind'

opam switch $VERSION
opam install $DEPS
