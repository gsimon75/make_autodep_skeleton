# Auto-dependency project skeleton for C++ and make

Though `make` is decades old, it's **still** the most effective build orchestrating tool, as it re-builds precisely
the obsoleted components only, so no matter how much changes you make, only the affected parts will be re-built.

At least, it has the ability to do so, but the actual result always depends on how precisely **we** can define the 'A
depends on B' relationships.

The roughest approach would be that whenever anything changes, we recompile everything. (And exactly that's the policy
used by a surprisingly lot of build orchestrators high on the hype list...)

The most perfect approach would be to track the referred-by relationships between all source symbols (eg.  all variable
names, defines, classes, templates, etc.), and only recompile the (transitively) dependent code parts. (So for example,
if you just rename a local variable, then only that function should be recompiled, and the library that contains it
should be changed, and the final executable relinked.)

The roughest approach requires nothing, the absolute perfection would require integrating the build orchestrator with
the C++ compiler, so this skeleton aims to somewhere in between:

The dependency unit is the **file** (that is, C/C++ source or header), because

* The time of its last modification is cheap to obtain
* C/C++ source files are the units of compilation anyway

So, the file 'A' directly depends on the file 'B' if it includes that.

Fortunately, `g++` has a feature for parsing a source file and producing the list of the files it (transitively)
depends on, so all we need is to maintain these dependency lists (regenerate them if any of the dependent files
changes) and make them usable for `make`.

This way `make` will know the full and exact dependency of each object file, and if any of the dependencies has
changed, will rebuild that object.


## The loop and its solution

The dependency list must be rebuilt if any of the (transitively) included headers changed, but exactly which headers
are we talking about? The included headers are listed ... in the dependency lists.

So the dependency list files depend on their own content. (Yes, the chicken and the egg. You've been expecting that
from the start, haven't you :D ?)

The dependency list files are actually Makefile-syntax dependency rules that are included at the start (except for the
operation `clean`), all of them that exists at the time.

So if/when they already exist, they contain also themselves as dependent, so they track the sources needed for an
object, and if a new 'include' is written anywhere in those files, then that's a change of a prerequisite, so all the
dependents (including the dep list file itself) are re-generated.

If such a dep list doesn't (yet) exists, there still is one rule for them in `Makefile`: they depend on the souce `.cc`
file they describe. So if the dep file doesn't exists, but the `.cc` does, then the dep will be generated automatically.

The trouble would begin if you decided to **rename** a source file, because then `make` would just lose track of
which dep list belongs to which 'new' source file.

Fortunately, if you rename a file (and you still want to use it), you have to modify the list of the prerequisites of
your final target binary (so that it contains the new name), and this prereq list is stored in the `Makefile`
(the `PARTS=...`) list at the top.

So, *everything* will have one additional prerequisite: the `Makefile` itself.

This also means that whenever you change the compilation flags, or the `DEBUG=...` define, or any re-building rule,
the whole project will be re-build, just as it should.

All the generated stuff (dep files, objects) will go to the `gen/` folder, so your work environment won't be littered
by all these below-the-hood things.


## About `make`

`make` is a venerable old beast, an extremely powerful and language-independent tool, but *without knowing its concepts* it is not intuitive at all.

I strongly recommend to get acquainted with it, at least on the overview-level, so here's the [manual](https://www.gnu.org/software/make/manual/).

