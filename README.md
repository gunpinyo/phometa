# phometa
Phometa is a web application
that can build formal systems based on visualisation.

This is individual project of Gun Pinyo
Supervisor: Dr. Krysia Broda
Second Marker: Prof. Alessio R. Lomuscio
MEng Computing (4YFT)
Imperial College London

For full report of this project, please compile master.tex in `doc/` directory.
**TODO: once the project complete, redirect this to pdf file.**

## Usage

Phometa can be installed by execute the following command
```
mkdir phometa
cd phometa
wget https://github.com/gunpinyo/phometa/raw/master/build/phometa.tar.gz
tar -zxvf phometa.tar.gz
```

Then, start phometa server by execute ``` ./phometa-server.py 8080 ``` where
`8080` is port number, you can change this to another port number if you like.
Please note that python is required for this server.

Then, open your favourite web-browser and enter
``` http://localhost:8080/phometa.html ```

Now, you can use phometa.

To exit the server, just press `Ctrl-C`  on the terminal that run server

## System Requirement for development
- nodejs (>= 0.10.25)
- npm (>= 1.4.21)
- elm 0.16
- sass

## My elm additional coding convention

### naming convention
- use **lower_case_with_underscores** for defined functions and constants,
  these will be different from standard elm convention which even better
  so we can distinguish functions from packages and defined function easily
- use **CamelCase** for modules, types, and type aliases

### indentation
- 2 spaces for each indention
- 79 characters per line

### (union) types, and type aliases
- for (union) types, put `=` at the end of that line
- for (union) types, put the entire name as prefix for each constructor
- for type aliases, put `=` in new line
- for type aliases, if it is very short and fit on one line, so do it

e.g.

```
type MyType
  = MyTypeNum Int
  | MyTypeStr Str

type alias AliasType =
  { my_type : MyType
  , age : Int
  }

type alias TypeName = String
```

### functions and constants
- put `=` at the same line but value in one line
- the same as type aliases, if it is very short and fit in one line, do it
- alway define functions and constants signatures for clarification

e.g.

```
my_min : Int -> Int -> Int
my_min a b =
  if a < b then
    a
  else
    b

main : Signal Html
main = start app
```

### import declaraion
- put all import decoration before any types or functions
    (but after module declaration)
- it will be divided in to 3 block
  - from core package
  - from community packages
  - defined modules
- each block will be separate by one line
- for core package block and community packages block,
    import decorations will be ordered alphabetically
- for defined modules, import decorations will be ordered by dependency
  - a general guideline of order between each package is
    - `Naive`
    - `Tools`
    - `Models`
    - `Updates`
    - `Views`
    - `Tests`

e.g.

```
import Signal exposing (Address)

import Html exposing (Html, button, text)

import Models.RepoModel exposing (Package)
import Models.Model exposing (Model)
```

in this case `Models.Model` depends on `Model.RepoModel` so it must come after,
but if there are modules which are not depend to each other, we are free to
any on them first
