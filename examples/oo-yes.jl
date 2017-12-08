using OO

# OO-ify Array
# note that this is not possible to do by default for all types as
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
maclary.bark()
maclary.bite("me")
maclary.eat("dog food")
maclary.notsurewhat("Hi MacLary")
