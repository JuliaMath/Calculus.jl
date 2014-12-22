const op_precedence = Dict(:+ => 1, :- => 1, :* => 2, :/ => 2, :^ => 3)

function deparse(ex::Expr, outer_precedence=0)
    if ex.head != :call
        return "$ex"
    end
    op = ex.args[1]
    args = ex.args[2:end]
    precedence = get(op_precedence, op, 0)
    if precedence == 0
        arg_list = join([deparse(arg) for arg in args], ", ")
        return "$op($arg_list)"
    end
    if length(args) == 1
        arg = deparse(args[1])
        return "$op$arg"
    end
    result = join([deparse(arg, precedence) for arg in args], " $op ")
    if precedence <= outer_precedence
        return "($result)"
    end
    return result
end

deparse(other, outer_precedence=0) = string(other)
