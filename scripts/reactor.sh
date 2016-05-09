#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

sass src/style.scss src/style.css

elm-reactor

popd
