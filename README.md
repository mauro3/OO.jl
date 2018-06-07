# OO

Satirical take on the new `getproperty` method of Julia 0.7.
**Please, do not use it!**

Refs:
- [#1974](https://github.com/JuliaLang/julia/issues/1974)
- [#24960](https://github.com/JuliaLang/julia/pull/24960)


```julia
using OO

# OO-ify Array
# Aside: it is not possible to automatically do this for all types as
# redefining Base.getproperty(self, p::Symbol) seg-faults Julia.
@OO Array
[1,2].length # ->2
[1,2].sum # ->3

@OO abstract type Animal end
_getproperty(self::Animal, ::Val{:eat}) = food -> println("$self eats $food")
@method Animal.eat(self, food) = println("$self eats $food")
@classmethod Animal.notsurewhat(arg) = println("This is a class-method saying: $arg")

@OO struct Dog <: Animal
    name
    breed
    color
    sound
end
Base.show(io::IO, d::Dog) = println(io, "Dog $(d.name)")
@method Dog.bark(self) = println("$(self.sound)")
@method Dog.bite(self, other) = println("Dog $(self.name) bites $other")

maclary = Dog("Hairy Maclary", "Terrier", "Black", "Yep yep yep yep")
maclary.bark() # Yep yep yep yep
maclary.bite("me") # Dog Hairy Maclary bites me
maclary.eat("dog food") # Dog Hairy Maclary eats dog food
maclary.notsurewhat("Hi MacLary") # This is a class-method saying: Hi MacLary
```
