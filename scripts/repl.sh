#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

elm-repl

popd
