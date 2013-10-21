const infix_ops = [:+, :-, :*, :/, :^]
const op_priority = {:+ => 1, :- => 1, :* => 2, :/ => 2, :^ => 3}

isinfix(ex::Expr) = ex.head == :call && ex.args[1] in infix_ops
isinfix(other) = false

function deparse(ex::Expr)
    if ex.head != :call
        return string(ex)
    end
    op = ex.args[1]
    args = ex.args[2:end]
    if !(op in infix_ops)
        return string(op, "(", join(map(deparse, args), ", "), ")")
    end
    if length(args) == 1
        return string(op, deparse(args[1]))
    end
    str = {}
    for subexpr in args
        if isinfix(subexpr) && op_priority[subexpr.args[1]] <= op_priority[op]
            push!(str, string("(", deparse(subexpr), ")"))
        else
            push!(str, deparse(subexpr))
        end
    end
    return join(str, string(" ", string(op), " "))
end

deparse(other) = string(other)
