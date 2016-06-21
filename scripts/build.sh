#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

# bash scripts/clean.sh

mkdir -p build
mkdir -p doc-pdf

rm -rf build/*

cd doc
latexmk -pdf --synctex=1 -interaction=nonstopmode -file-line-error master.tex
latexmk -pdf --synctex=1 -interaction=nonstopmode -file-line-error presentation.tex
latexmk -pdf --synctex=1 -interaction=nonstopmode -file-line-error presentation_script.tex
cd ..
cp doc/master.pdf build/phometa-doc.pdf
cp doc/master.pdf doc-pdf/final-report.pdf
cp doc/presentation.pdf doc-pdf/presentation.pdf
cp doc/presentation_script.pdf doc-pdf/presentation_script.pdf

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
