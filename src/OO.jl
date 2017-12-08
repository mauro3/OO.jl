module OO
export @OO, @method, @classmethod

"""Fallback which looks first at proper-fields, otherwise tries to call
single argument function.

```
@OO Array
[1,2].length # -> 2
```

Ref: https://github.com/JuliaLang/julia/pull/24960#issuecomment-349921490
"""
@generated function _getproperty(s, v::Val{V}) where {V}
    if V in fieldnames(s)
        :(getfield(s, $(QuoteNode(V))))
    else
        # try calling a method
        :($V(s))
    end
end
# The definition at sysimg.jl:8 is "no" good. Sadly this seg-faults Julia,
# putting a spanner into the plan for OO to rule the world:
# Base.getproperty(self, p::Symbol) = _getproperty(self, Val(p))

macro OO(arg)
    if isa(arg,Symbol)
        # redirect getproperty to _getproperty
        return :( Base.getproperty(self::$arg, p::Symbol) = _getproperty(self, Val(p)) )
    elseif arg.head==:struct
        typ = arg.args[2]
    elseif arg.head==:abstract
        typ = arg.args[1]
    else
        error()
    end
    if !isa(typ,Symbol) && typ.head==:<:
        typ = typ.args[1]
    end
    quote
        $(esc(arg))
        # redirect getproperty to _getproperty
        Base.getproperty(self::$(esc(typ)), p::Symbol) = _getproperty(self, Val(p))
    end
end

macro method(meth)
    head, body = meth.args
    @assert length(head.args)>1 "Need an explicit self argument, eg. Dog.bite(self,other)"
    anon_args = length(head.args)==2 ? [] : head.args[3:end]
    typ, field = head.args[1].args
    esc(quote
        $OO._getproperty(self::$typ, ::Val{$field}) = ($(anon_args...),) -> $body
    end)
end

macro classmethod(meth)
    head, body = meth.args
    anon_args = length(head.args)==1 ? [] : head.args[2:end]
    typ, field = head.args[1].args
    esc(quote
        $OO._getproperty(::$typ, ::Val{$field}) = ($(anon_args...),) -> $body
    end)

end


end # module
