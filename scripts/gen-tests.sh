#!/usr/bin/env bash

pushd $(git rev-parse --show-toplevel)

elm-make tests/Tests/Main.elm --yes --output raw-tests.js

wget https://raw.githubusercontent.com/laszlopandy/elm-console/master/elm-io.sh

bash elm-io.sh raw-tests.js tests.js

popd
