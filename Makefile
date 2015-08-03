interactive:
	elm-repl --interpreter=nodejs

reactor:
	elm-reactor

compile:
	elm-make src/Main.elm

clean:
	rm -rf elm-stuff/ && rm elm.js
