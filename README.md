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
    echo "(library (name my_lib) (modules file1 file2 file3) (libaries lablgtk3))" >> lib/dune

    mkdir bin
    touch bin/main.ml
    touch bin/dune
    echo "(executable (name main) (modes byte exe) (libraries my_lib))" >> bin/dune

4) Install external libraries dependences, like

    opam install lablgtk3

   For notes on lablgtk2/3, see:
     * https://ocaml.org/learn/tutorials/introduction_to_gtk.html
     * http://lablgtk.forge.ocamlcore.org/refdoc3/index.html

5) Use the libraries by upper-case, e.g. `My_lib.foo`

6) Build

    dune build bin/main.exe

        or

    dune build bin/main.bc

7) Run

    ./_build/default/bin/main.exe

        or

    ./_build/default/bin/main.bc

8) Debug

    dune utop <dir>

   Allows you to run `utop` with the code in `<dir>` being built and loaded

        or

    ocamldebug _build/default/bin/main.bc

   With which I've had more success in actually getting a debugging session going

9) Breakpoints

   Set breakpoints in `ocamldebug` as follows:

     break @ Dune__exe__Main 8

# Acknowledgements
Images from https://github.com/pardahlman/minesweeper and https://grid-paint.com/images/details/5965934191706112
Springboard point from https://ocaml.org/learn/tutorials/introduction_to_gtk.html