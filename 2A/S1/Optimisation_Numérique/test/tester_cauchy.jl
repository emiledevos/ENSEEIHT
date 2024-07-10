# Ecrire les tests de l'algorithme du pas de Cauchy
using Test

function tester_cauchy(cauchy::Function)

	@testset "Pas de Cauchy" begin
    #Cas de test ou a>0 et ou le minimum et derrière la région de confiance. on fait ensuite la même fonction en augmentant la frontière pour avoir a>0 et le minimum dans la région de confiance, ce qui permet de tester tout les cas avec a >0
    g = [2, 2]
    H = [2 0; 0 2]
    a=g'*H*g
    delta=1
    b=norm(g)^2
        # cas de test 1
		s=cauchy(g,H,delta)
        s_attendu=-(b/a)*g
        s_frontiere=-delta/norm(g)*g
		
		@test s≈s_frontiere
        s=cauchy(g,H,10)
        @test s≈s_attendu
        
     #On va faire maintenant faire des cas avec a<0. SI a est négatif, on renvoie dans tout les cas la frontière de la région de confiance
        g = [-2, -2]
        H = [-2 0; 0 -2]
        a=g'*H*g
        delta=1
        b=norm(g)^2
        # cas de test 1
		s=cauchy(g,H,delta)
        s_attendu=-(b/a)*g
        s_frontiere=-delta/norm(g)*g
        @test s≈s_frontiere
    #testons maintenant le cas ou la norme de g est très petite
        g = [0.0000000000000000001, 0.0000000000000000001]
        H = [-2 0; 0 -2]
        a=g'*H*g
        delta=1
        b=norm(g)^2
        # cas de test 1
		s=cauchy(g,H,delta)
        s_attendu=zero(g)
        @test s≈s_attendu
    end

end