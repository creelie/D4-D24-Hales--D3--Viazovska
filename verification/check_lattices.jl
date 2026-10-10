# Exact checks of the E8 and Leech lattices of sphere-packing/, read from data/,
# in Rational{BigInt} and 256-bit BigFloat arithmetic, with no packages.
#   E8:    lattice = span(rows of data/e8.txt) / 2,        separation sqrt 2
#   Leech: lattice = span(rows of data/leech.txt) / sqrt 8, separation 2
# Checks: integral even Gram matrix, determinant 1, and the density
# vol(B(separation/2)) / covolume against pi^4/384 and pi^12/12!.
# Usage: julia check_lattices.jl
setprecision(BigFloat, 256)
const HERE = @__DIR__
fails = 0
function check(name, ok)
    global fails
    println(ok ? "[PASS] " : "[FAIL] ", name)
    ok || (fails += 1)
end
readrows(f) = [parse.(BigInt, split(l)) for l in readlines(joinpath(HERE, "data", f)) if !isempty(strip(l))]

function exactdet(A::Matrix{Rational{BigInt}})
    A = copy(A); n = size(A, 1); d = one(Rational{BigInt})
    for i in 1:n
        p = findfirst(r -> A[r, i] != 0, i:n)
        p === nothing && return zero(d)
        p += i - 1
        if p != i
            A[[i, p], :] = A[[p, i], :]; d = -d
        end
        d *= A[i, i]
        for r in i+1:n
            f = A[r, i] / A[i, i]
            A[r, :] .-= f .* A[i, :]
        end
    end
    d
end

# n is even here, so Gamma(n/2 + 1) = (n/2)!
ballvol(n, r) = (iseven(n) || error("odd n")) && BigFloat(pi)^(n ÷ 2) * r^n / factorial(big(n ÷ 2))

for (name, file, scale, sep, value, label) in (
        ("E8", "e8.txt", 4, sqrt(BigFloat(2)), BigFloat(pi)^4 / 384, "pi^4/384"),
        ("Leech", "leech.txt", 8, BigFloat(2), BigFloat(pi)^12 / factorial(big(12)), "pi^12/12!"))
    R = readrows(file); n = length(R)
    G = [sum(R[i] .* R[j]) // scale for i in 1:n, j in 1:n]
    check("$name: Gram matrix integral", all(denominator.(G) .== 1))
    check("$name: Gram diagonal even", all(iseven(numerator(G[i, i])) for i in 1:n))
    d = exactdet(Matrix{Rational{BigInt}}(G))
    check("$name: det(Gram) = 1", d == 1)
    dens = ballvol(n, sep / 2) / sqrt(BigFloat(d))
    check("$name: density = $label to 70 digits", abs(dens - value) < BigFloat(10)^-70)
end
println(fails == 0 ? "\nall checks passed" : "\n$fails checks FAILED")
exit(fails == 0 ? 0 : 1)
