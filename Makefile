init:
	elm-package install --yes
	npm install elm-test

interactive:
	elm-repl --interpreter=nodejs

reactor:
	elm-reactor

test:
	node_modules/.bin/elm-test src/Tests/Test.elm

compile:
	elm-make src/Main.elm --yes

clean:
	git clean -dfX
