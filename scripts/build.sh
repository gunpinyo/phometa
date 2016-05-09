#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

mkdir -p build

rm -rf build/*

sass src/style.scss build/style.css
cp src/naive.js build/naive.js

elm-make src/Main.elm --yes --output build/phometa.html

popd
