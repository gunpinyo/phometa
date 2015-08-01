# phometa
Phometa is an application that can build formal system based on visualization.

**NOTE: This project is just start and I am still designing the architectue.**
**Please do not use this until this note is disappear.**

## My elm coding convention

### name convention
- use **lower_case_with_underscores** for defined functions and constants
- but still use **mixedCase** for packages functions and constants
- use **CamelCase** for modules, types and type aliases
- use full word(s) to name an identifier, except
  - `r` for record
      (since it use so frequent and will be followed by a long identifier)
  - `*_str` means thing that has type string
  - `*_func` means function that has been created dynamically

### indentation
- 2 spaces for each indention
- 79 characters per line


### (union) types, and type aliases
- put `=` in new line
- for type aliases, if it is very short and fit on one line, so do it
- for (union) types, put the entire name for each constructor

e.g.

```
type MyType
  = MyTypeNum Int
  | MyTypeStr Str

type alias AliasType
  = { my_type : MyType
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
    (but after module declaraion)
- it will be divided in to 3 block
  - from core package
  - from community packages
  - defined modules
- each block will be separate by one line
- for core package block and community packages block,
    import decorations will be ordered alphabetically
- for defined modules, import decorations will be ordered by dependency

e.g.

```
import Signal exposing (Address)

import Flex exposing (row, column, flexDiv, fullbleed)
import Html exposing (Html, button, text)
import Html.Events exposing (onClick)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
```
note on example of defined modules
  in this case `Model.InputAction` and `Model.Model` are not depend on
  each other we have freedom to put anything first, but I decide to put
  `Model.InputAction` first because input_action is normal come before when
  both of them are arguments in a function

### module and package
- don't use plural as module or package name
