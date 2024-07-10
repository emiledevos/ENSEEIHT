function [Q,N]=matrix_representation(A,n)
% Représentation sous forme de matrice du graphe Internet
% A contient les arcs du graphe orienté.
% n représente le nombre de sommets.
% Q est la matrice du graphe Internet.

% Initialisation
Q=zeros(n,n);
%Q=sparse(n,n);
N=zeros(1,n);
for j=1:n
for k = 1:size(A,1)
    if A(k,1) == j 
        N(j)=N(j)+1;
    end
end

end
N

for k = 1:size(A,1)
    Q(A(k,2),A(k,1))=1/N(A(k,1));

end
end