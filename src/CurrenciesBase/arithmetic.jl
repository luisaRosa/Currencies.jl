#= Monetary arithmetic functions =#

# numeric operations
Base.zero{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(0)
Base.zero{T<:Monetary}(::Type{T}) = zero(filltype(T))

# NB: one returns multiplicative identity, which does not have units
Base.one{T,U,V}(::Type{Monetary{T,U,V}}) = one(U)

# mathematical number-like operations
Base.abs{T<:Monetary}(m::T) = T(abs(m.val))

# a note on this one: a sign does NOT include the unit
# quantity = sign * magnitude * unit
Base.sign(m::Monetary) = sign(m.val)

# on types
Base.zero{T<:AbstractMonetary}(::T) = zero(T)
Base.one{T<:AbstractMonetary}(::T) = one(T)

# comparisons
=={T<:Monetary}(m::T, n::T) = m.val == n.val
=={T}(m::Monetary{T}, n::Monetary{T}) = (m - n).val == 0
m::Monetary == n::Monetary = m.val == n.val == 0
Base.isless{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = isless(m.val, n.val)

# unary plus/minus
+ m::AbstractMonetary = m
-{T<:Monetary}(m::T) = T(-m.val)

# arithmetic operations on two monetary values
+{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = Monetary{T,U,V}(m.val + n.val)
-{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = Monetary{T,U,V}(m.val - n.val)
/{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = float(m.val) / float(n.val)

# arithmetic operations on monetary and dimensionless values
*{T<:Monetary}(m::T, i::Real) = T(m.val * i)
*{T<:Monetary}(i::Real, m::T) = T(i * m.val)
m::Monetary / f::Real = m * inv(f)

# Note that quotient is an integer, but remainder is a monetary value.

const DIVS = ((:div, :rem, :divrem),
              (:fld, :mod, :fldmod),
              (:fld1, :mod1, :fldmod1))

for (dv, rm, dvrm) in DIVS
    @eval function Base.$(dvrm){T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V})
        quotient, remainder = $(dvrm)(m.val, n.val)
        quotient, Monetary{T,U,V}(remainder)
    end
    @eval Base.$(dv){T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
        $(dv)(m.val, n.val)
    @eval Base.$(rm){T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
        Monetary{T,U,V}($(rm)(m.val, n.val))
end