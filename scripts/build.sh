#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

# bash scripts/clean.sh

mkdir -p build

rm -rf build/*

if [ ! -e doc/master.pdf ]
then
cd doc
latexmk -pdf --synctex=1 -interaction=nonstopmode -file-line-error master.tex
cd ..
fi
cp doc/master.pdf build/phometa-doc.pdf

sass src/style.scss build/style.css
cp src/naive.js build/naive.js
cp src/repository.json build/repository.json
cp src/phometa-server.py build/phometa-server.py
cp logo.png build/logo.png

elm-make src/Main.elm --yes --output build/phometa.html

cd build
tar -zcvf phometa.tar.gz *
cd ..

popd
