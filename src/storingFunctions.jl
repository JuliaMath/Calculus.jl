export StoredFunction


global storedFunctions = Dict()

type StoredFunction
    args
    code
end

macro define(functionName, args, code)
    storedFunctions[functionName] = StoredFunction(args,code)
    :(global $functionName = $args -> $code)
end


function testStoredFunction(functionName::Expr)
    print(storedFunctions)
    return haskey(storedFunctions, functionName)
end


## function differentiate(ex::Expr,wrt)
##     print("hello")
##     print(haskey(storedFunctions, ex))
##     if haskey(storedFunctions, ex)
##         print("differentiating a user-defined function")
##         differentiate(storedFunctions[ex].code, wrt)
##     end
##     if ex.head != :call
##         error("Unrecognized expression $ex")
##     end
##     simplify(differentiate(SymbolParameter(ex.args[1]), ex.args[2:end], wrt))
## end
