#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

mkdir -p build

cp src/style.css build/style.css

elm-make src/Main.elm --yes --output build/phometa.html

popd
