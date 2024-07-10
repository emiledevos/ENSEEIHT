using LinearAlgebra
include("../src/newton.jl")
include("../src/Regions_De_Confiance.jl")
"""

Approximation d'une solution au problème 

    min f(x), x ∈ Rⁿ, sous la c c(x) = 0,

par l'algorithme du lagrangien augmenté.

# Syntaxe

    x_sol, f_sol, flag, nb_iters, μs, λs = lagrangien_augmente(f, gradf, hessf, c, gradc, hessc, x0; kwargs...)

# Entrées

    - f      : (Function) la ftion à minimiser
    - gradf  : (Function) le gradient de f
    - hessf  : (Function) la hessienne de f
    - c      : (Function) la c à valeur dans R
    - gradc  : (Function) le gradient de c
    - hessc  : (Function) la hessienne de c
    - x0     : (Vector{<:Real}) itéré initial
    - kwargs : les options sous formes d'arguments "keywords"
        • max_iter  : (Integer) le nombre maximal d'iterations (optionnel, par défaut 1000)
        • tol_abs   : (Real) la tolérence absolue (optionnel, par défaut 1e-10)
        • tol_rel   : (Real) la tolérence relative (optionnel, par défaut 1e-8)
        • λ0        : (Real) le multiplicateur de lagrange associé à c initial (optionnel, par défaut 2)
        • μ0        : (Real) le facteur initial de pénalité de la c (optionnel, par défaut 10)
        • τ         : (Real) le facteur d'accroissement de μ (optionnel, par défaut 2)
        • algo_noc  : (String) l'algorithme sans c à utiliser (optionnel, par défaut "rc-gct")
            * "newton"    : pour l'algorithme de Newton
            * "rc-cauchy" : pour les régions de confiance avec pas de Cauchy
            * "rc-gct"    : pour les régions de confiance avec gradient conjugué tronqué

# Sorties

    - x_sol    : (Vector{<:Real}) une approximation de la solution du problème
    - f_sol    : (Real) f(x_sol)
    - flag     : (Integer) indique le critère sur lequel le programme s'est arrêté
        • 0 : convergence
        • 1 : nombre maximal d'itération dépassé
    - nb_iters : (Integer) le nombre d'itérations faites par le programme
    - μs       : (Vector{<:Real}) tableau des valeurs prises par μk au cours de l'exécution
    - λs       : (Vector{<:Real}) tableau des valeurs prises par λk au cours de l'exécution

# Exemple d'appel

    f(x)=100*(x[2]-x[1]^2)^2+(1-x[1])^2
    gradf(x)=[-400*x[1]*(x[2]-x[1]^2)-2*(1-x[1]) ; 200*(x[2]-x[1]^2)]
    hessf(x)=[-400*(x[2]-3*x[1]^2)+2  -400*x[1];-400*x[1]  200]
    c(x) =  x[1]^2 + x[2]^2 - 1.5
    gradc(x) = 2*x
    hessc(x) = [2 0; 0 2]
    x0 = [1; 0]
    x_sol, _ = lagrangien_augmente(f, gradf, hessf, c, gradc, hessc, x0, algo_noc="rc-gct")

"""
function Lagrangien_Augmente(f::Function, gradf::Function, hessf::Function, 
        c::Function, gradc::Function, hessc::Function, x0::Vector{<:Real}; 
        max_iter::Integer=1000, tol_abs::Real=1e-10, tol_rel::Real=1e-8,
        λ0::Real=2, μ0::Real=10, τ::Real=2, algo_noc::String="rc-gct")

    #
    x_sol = x0
    f_sol = f(x_sol)
    flag  = -1
    nb_iters = 0
    ms = [μ0] # vous pouvez faire μs = vcat(μs, μk) pour concaténer les valeurs
    ls = [λ0]
    mk=μ0
    lk=λ0
    xk=x0
    beta=0.9
    eta = 0.1258925
    alpha=0.1
    ek=1/mk
    etak=eta/(mk^alpha)
    tau=τ
    c0 = norm(gradf(x0)) <= tol_abs
    c3 = false
    
    
    while !(c0 | c3)
        nb_iters=nb_iters+1
        
        La(x)=f(x) +lk'*c(x)+(mk/2)*norm(c(x))^2
        gradL(x)=gradf(x)+lk'*gradc(x)+mk*(gradc(x))*c(x)
        hessL(x)=hessf(x)+lk'*hessc(x) + mk*(gradc(x)*(gradc(x)')) + mk*hessc(x)*c(x)
        
        if algo_noc =="rc-gct"
             xk1, _, _, _, _ = regions_de_confiance(La, gradL, hessL, x_sol, tol_abs = ek, algo_pas="gct")
        elseif algo_noc =="rc-cauchy"
             xk1, _, _, _, _=regions_de_confiance(La, gradL, hessL, x_sol,tol_abs = ek, algo_pas="cauchy")
        elseif algo_noc =="newton"
            xk1, _, _, _, _=newton(La, gradL, hessL, x_sol, tol_abs = ek)
        else
            error("algo non valide")
        end
        
        gradLNA(x,lambda)=gradf(x)+lambda'*gradc(x)
        
        c0 = (norm(gradLNA(xk1, lk)) <= max(tol_rel*norm(gradLNA(x0,λ0)),tol_abs)) && norm(c(xk1)) <= max(tol_rel*norm(c(x0)),tol_abs)
        
        c3 = (nb_iters>=max_iter)
        
        if norm(c(xk1))<=etak
            lk=lk+mk*c(xk1)
            mkp1=mk
            ek=ek/mk
            etak=etak/(mk^beta)
            
        else
            lk=lk
            mkp1=mk*τ
            ek=(1/μ0)/mkp1
            etak=eta/(mkp1^alpha)
            mk = mkp1
        end
        
    x_sol = xk1
    f_sol = f(x_sol)
    ms = vcat(ms, mk)
    ls = vcat(ls,lk)
        
    if c0 
            flag=0

    elseif c3
            flag=3
    end
    
    end
    
    return x_sol, f_sol, flag, nb_iters, ms, ls

end
