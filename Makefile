interactive:
	elm-repl --interpreter=nodejs

run-program:
	elm-reactor

clean:
	rm -rf elm-stuff/ && rm elm.js
