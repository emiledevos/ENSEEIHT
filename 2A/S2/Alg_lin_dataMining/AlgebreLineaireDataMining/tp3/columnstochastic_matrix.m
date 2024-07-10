function [P]=columnstochastic_matrix(Q,N)
% Modification par une matrice de rang 1 afin d'obtenir une matrice
% stochastique par colonne
% Q est la matrice carr?e du graphe d'internet. 
% P est la matrice carr?e du graphe d'internet modifi?.


% Initialisation
n=length(Q(:,1));
d=(N==0);
size(d)
e=ones(1,n)';
size(e)

P=Q+(1/n)*e*d;
    
end