1) Create the top-level directory

    mkdir my-project
    cd my-project

2) Create top-level project file

    touch dune-project
    cat "(lang dune 2.5)" >> dune-project
    cat "(name my_project)" >> dune-project

3) Create directories to hold the source code

    mkdir lib
    touch lib/my_lib.ml
    touch lib/dune
    echo "(library (name my_lib))" >> lib/dune

    mkdir bin
    touch bin/main.ml
    touch bin/dune
    echo "(executable (name main) (modes byte exe) (libraries my_lib))" >> bin/dune


4) Use the libraries by upper-case, e.g. `My_lib.foo`

5) Build

    dune build bin/main.exe

        or

    dune build bin/main.bc

6) Run

    ./_build/default/bin/main.exe

        or

    ./_build/default/bin/main.bc

7) Debug

    dune utop <dir>

   Allows you to run `utop` with the code in `<dir>` being built and loaded

        or

    ocamldebug _build/default/bin/main.bc

   With which I've had more success in actually getting a debugging session going

8) Breakpoints

   Set breakpoints in `ocamldebug` as follows:

     break @ Dune__exe__Main 8