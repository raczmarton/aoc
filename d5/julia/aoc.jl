

inp = read("input", String)
rules, updates = split(inp, "\n\n")
orderings = Set{NTuple{2,Int}}()
for rule in eachsplit(rules, '\n')
    a, b = eachsplit(rule, '|')
    push!(orderings, (parse(Int, a), parse(Int, b)))
end

sorter = (x, y) -> (x, y) in orderings

function first()
    score = 0
    for update in eachsplit(updates, '\n', keepempty=false)
        v = parse.(Int, split(update, ','))
        if issorted(v, lt=sorter)
            score += v[length(v)÷2+1]
        end
    end

    score
end

function second()
    score = 0
    for update in eachsplit(updates, '\n', keepempty=false)
        v = parse.(Int, split(update, ','))
        if issorted(v, lt=sorter)
            continue
        end
        sort!(v; lt=sorter)
        score += v[length(v)÷2+1]
    end

    score
end

println(first())
println(second())
