using LinearAlgebra
"""
Approximation de la solution du problème 

    min qₖ(s) = s'gₖ + 1/2 s' Hₖ s, sous la contrainte ‖s‖ ≤ Δₖ

# Syntaxe

    s = gct(g, H, Δ; kwargs...)

# Entrées

    - g : (Vector{<:Real}) le vecteur gₖ
    - H : (Matrix{<:Real}) la matrice Hₖ
    - Δ : (Real) le scalaire Δₖ
    - kwargs  : les options sous formes d'arguments "keywords", c'est-à-dire des arguments nommés
        • max_iter : le nombre maximal d'iterations (optionnel, par défaut 100)
        • tol_abs  : la tolérence absolue (optionnel, par défaut 1e-10)
        • tol_rel  : la tolérence relative (optionnel, par défaut 1e-8)

# Sorties

    - s : (Vector{<:Real}) une approximation de la solution du problème

# Exemple d'appel

    g = [0; 0]
    H = [7 0 ; 0 2]
    Δ = 1
    s = gct(g, H, Δ)

"""
function gct(g::Vector{<:Real}, H::Matrix{<:Real}, Δ::Real; 
    max_iter::Integer = 100, 
    tol_abs::Real = 1e-10, 
    tol_rel::Real = 1e-8)
    
    n= length(g)
    j=0
    delta=Δ
    gj=g
    pj=-g
    sj = zeros(length(g))
        
    q(b)=g'b+(1/2)*b'*H*b
    
    while j<max_iter && norm(gj)>max(norm(gj)*tol_rel, tol_abs)
        kj=pj'*H*pj
        if kj<=0 
            a=norm(pj)^2
            b=2*sj'*pj
            c=(norm(sj)^2-delta^2)
            sigma1=(-b+sqrt(b^2-4*a*c))/(2*a)
            sigma2=(-b-sqrt(b^2-4*a*c))/(2*a)
            if q(sj+sigma1*pj)>q(sj+sigma2*pj) 
                return(sj+sigma2*pj)
            else
                return(sj+sigma1*pj)
            end
        end
        alphaj=gj'*gj/kj
        if norm(sj+alphaj*pj) > delta
            a=norm(pj)^2
            b=2*sj'*pj
            c=(norm(sj)^2-delta^2)
            return(sj+((-b+sqrt(b^2-4*a*c))/(2*a))*pj)
        end
        sj1=sj+alphaj*pj
        gj1=gj+alphaj*H*pj
        betaj=(gj1'*gj1)/(gj'*gj)
        pj=-gj1+betaj*pj
        j=j+1
        gj=gj1
        sj=sj1
            
            
    end
    
   return sj
end
