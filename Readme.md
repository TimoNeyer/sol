# sol (state oriented language)

## Welcome to sol (pronounced with a long o)

The principle of this programming language is the usage of states, just like
modeling finite automata. Therefore it has a more functional approach and
utilizes its functionality and determinism. However the use of states makes it
more unike and allows a more precise and secure program, ensuring the program
is only able to do what you tell it to.

## Basics

While defining states is similar to an object oriented language, what is unique
here is the mandatory definition of transitions between them. There may be no
code outside of a state.

To make it more usable, you may also define substates to a given (sub)state.

Inheritance can be used to define multiple similar states (derivatives) from a
base state (composition) without defining their attributes over and over.
To minimize ambiguousness, you are not allowed to write transitions for a state
which is a composition.

Inside a state, it is assumed that the entry function is a loop until a
transition or `exit` is called. The `entry` function is required for each state
and may be derived from a composition state.

### immutability

While a state may change the variables of its scope, it can not reach the of any
other state, other than `global` marked variable of its super state
(if present). Immutable functions may be called at any given point, as well as
transitions.

### Transitions

Transitions are a base concept of sol, as they allow a change of scope and are
required to allow -other things-. They may be defined in the state where the
transition originates from and may include variables.

A limiting faktor of transitions is that it is only valid to change to a state
reachable from the current position. It is not allowed for example to change
from a substate of state $A$ called $A'$ to the state $B$ as it is unreachable
from $A'$. You would need to change to $A$ first and then to $B$.

Transitions may only be defined from within the class where the transition
starts

### Syntax

A state can be defined as follows:

```
state main : start {
    entry {
        print("hello world");
        exit(0);
    }
}

-------------------------------------------------------------------------------
$ hello world
```
The `state` keyword marks the start of a state with the name as the literal
following it. To mark this as being derived from another state, use `:
Compositor`. As described above, it is necessary to define an `entry` function,
we can review the definition of a function now.

```
myFunction(*args){
    // body;
    return 0;
}
```

The return type is inferred by what is actually returned, which has to be
constant at compile time, thus can only be one type and not different depending
on which `return` is taken.

Transisions may be defined like this:
```
state Main : Start {
    entry{
        print("ehlo");
        myTransition();
    }
    => myTransition(Main -> Print){ }
}

state Print {
   entry {
        print("world");
        exit(0);
    }
}

-------------------------------------------------------------------------------
$ ehlo
$ world
```
Using `=>` to mark them as transitions.

In this case `myTransition` has no content, so the context is just changed to
`Print`. However, you may specify arguments in the transition:
```
state Main : Start {
    entry{
        print("ehlo");
        myTransition("world");
    }
    => myTransition(Main -> Print, str world){
        print.variable = world;
    }
}

state Print {
   global str variable;
    entry {
        print(variable);
        exit(0);
    }
}

-------------------------------------------------------------------------------
$ ehlo
$ world
```

As you can see, variables may be defined outside of the `entry` function to
allow setting attributes of a state. If you want to go even further, you may
also define a custom entry function for a given transition:
```
state Main : Start {
    entry{
        print("ehlo");
        myTransition("world");
    }
    => myTransition(Main -> Print, str world){
        print.variable = world;
    }
}

state Print {
    global str variable;
    entry {
        print("world");
        exit(0);
    }
    entry <- Main {
        print(variable);
        exit(0);
    }
}

-------------------------------------------------------------------------------
$ ehlo
$ world
```

Note that you can not choose a custom entry function for a specific transition,
as you may just use multiple state (perhaps inheritance) to suite your needs:
```
state Main : Start {
    entry{
        print("ehlo");
        myTransition("world");
    }
    => myTransition(Main -> Print2, str world){
        print.variable = world;
    }
}

state Print1 {
    entry {
        print("world");
        exit(0);
    }
}
state Print2 {
    global str variable;
    entry {
        print(variable);
        exit(0);
    }
}

-------------------------------------------------------------------------------
$ ehlo
$ world
```

Important to note is that when switching to another state, the current scope is
completely discarded and all variables will be lost. The only way to keep values
is to include them in a transition or switch to a substate and mark the variable
as `global`.
```
state Main : Start {
    int number;
    global str ehlo;
    entry{
        print("ehlo");
        myTransition("world");
    }

    => myTransition(Main -> Print2, str world){
        print.variable = world;
    }

    => myTransition2(Main -> Print1) {}

    state Print1 {
        entry {
            print("world");
//          print("{}", number);  fails because number is not reachable
            print("{}", ehlo);
            exit(0);
        }
    }

    entry <- Print2 {
        print("bye");
        exit(0);
    }
}


state Print2 {
    global str variable;
    entry {
        print(variable);
        Return();
    }
    => Return(Print2 -> Main){}
}

-------------------------------------------------------------------------------
$ ehlo
$ world
$ bye
```
Here the specific entry funcitons are necessary for `Main` as otherwise the
program would loop through the originally defined `entry` function.
