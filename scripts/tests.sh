#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

bash scripts/gen-tests.sh

node tests.js

rm raw-tests.js elm-io.sh tests.js

popd
