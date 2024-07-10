using LinearAlgebra
"""
Approximation de la solution du problème 

    min qₖ(s) = s'gₖ + 1/2 s' Hₖ s

        sous les contraintes s = -t gₖ, t > 0, ‖s‖ ≤ Δₖ

# Syntaxe

    s = cauchy(g, H, Δ; kwargs...)

# Entrées

    - g : (Vector{<:Real}) le vecteur gₖ
    - H : (Matrix{<:Real}) la matrice Hₖ
    - Δ : (Real) le scalaire Δₖ
    - kwargs  : les options sous formes d'arguments "keywords", c'est-à-dire des arguments nommés
        • tol_abs  : la tolérence absolue (optionnel, par défaut 1e-10)

# Sorties

    - s : (Vector{<:Real}) la solution du problème

# Exemple d'appel

    g = [0; 0]
    H = [7 0 ; 0 2]
    Δ = 1
    s = cauchy(g, H, Δ)

"""
function cauchy(g::Vector{<:Real}, H::Matrix{<:Real}, Δ::Real; tol_abs::Real = 1e-10)
    delta=Δ
    tmin= 0
    s=zero(g)

    if norm(g)<tol_abs
        s=zero(g)
    else
        frontiere=delta/norm(g)
        a=g'*H*g
        b=-norm(g)^2
        delta=Δ

        if a > 0
            tmin=-b/a
            if tmin<0
                tmin=0

            else
                tmin = min(tmin, frontiere)
            end
        else 
           tmin=frontiere  
        end
    end

    s=-tmin*g

    return s
end
