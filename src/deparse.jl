function deparse(ex::Expr)
    if ex.head != :call
        return string(ex)
    else
        if contains([:+, :-, :*, :/, :^], ex.args[1])
            if length(ex.args) == 2
                return strcat(ex.args[1], deparse(ex.args[2]))
            else
                return join(map(x -> deparse(x), ex.args[2:end]), strcat(" ", string(ex.args[1]), " "))
            end
        else
            return strcat(ex.args[1], "(", join(map(x -> deparse(x), ex.args[2:end]), ", "), ")")
        end
    end
end
deparse(other::Any) = string(other)
