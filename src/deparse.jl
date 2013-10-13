function deparse(ex::Expr)
    if ex.head != :call
        return string(ex)
    else
        if ex.args[1] in [:+, :-, :*, :/, :^]
            if length(ex.args) == 2
                return string(ex.args[1], deparse(ex.args[2]))
            else
                return join(map(x -> deparse(x), ex.args[2:end]),
                            string(" ", string(ex.args[1]), " "))
            end
        else
            return string(ex.args[1],
                          "(",
                          join(map(x -> deparse(x), ex.args[2:end]), ", "),
                          ")")
        end
    end
end
deparse(other::Any) = string(other)

# TODO: Examine string contents of inputs, insert parentheses if added:
# + (CONTAINS * OR /)
# - (CONTAINS * OR /)
