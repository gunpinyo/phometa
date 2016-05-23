#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

bash scripts/clean.sh

mkdir -p build

rm -rf build/*

sass src/style.scss build/style.css
cp src/naive.js build/naive.js
cp src/repository.json build/repository.json
cp src/phometa-server.py build/phometa-server.py

elm-make src/Main.elm --yes --output build/phometa.html

cd build
tar -zcvf phometa.tar.gz *
cd ..

popd
