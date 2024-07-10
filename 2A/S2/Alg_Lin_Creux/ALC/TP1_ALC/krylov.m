
function [x, flag, relres, iter, resvec] = krylov(A, b, x0, tol, maxit, type)
% Résolution de Ax = b par une méthode de Krylov

% x      : solution
% flag   : convergence (0 = convergence, 1 = pas de convergence en maxit)
% relres : résidu relatif (backward error normwise)
% iter   : nombre d'itérations
% resvec : vecteur contenant les iter normes du résidu


% A     :matrice du système
% b     : second membre
% x0    : solution initiale
% tol   : seuil de convergence (pour l'erreur inverse)
% maxit : nombre d'itérations maximum
% type : méthode de Krylov
%        type == 0  FOM
%        type == 1  GMRES

n = size(A, 2);
r0 = b - A*x0;
beta = norm(r0);
normb = norm(b);
% résidu relatif backward erreur normwise
relres = beta / normb;
% matlab va agrandir de lui même le vecteur resvec et les matrices V et H
resvec(1) = beta;
V(:,1) = r0 / beta;
H=zeros(maxit+1,maxit);
j = 1;
x = x0;


while (j<=maxit && relres>tol) % critère d'arrêt
    wj=A*V(:,j);
    for i = 1:j 
         H(i,j)=V(:,i)'*wj;
         wj=wj-H(i,j)*V(:,i);
    end
    H(j+1,j)=norm(wj);
    if H(j+1,j)==0 
        break;
    end
    V(:,j+1)=wj/H(j+1,j);   

    % suivant la méthode
    if(type == 0)
        betae1= zeros(j,1);
        betae1(1)=beta;
        ym=H(1:j,1:j) \ betae1;
        % FOM
        % résolution du système linéaire H.y = beta.e1
        % construction de beta.e1 (taille j)
        % ... 
        % résolution de H.y = beta.e1 avec '\'
        % ...
    else
        betae1= zeros(j+1,1);
        betae1(1)=beta;
        ym=H(1:j+1,1:j) \ betae1;
        % GMRES
        % résolution du problème aux moindres carrés argmin ||beta.e1 - H_barre.y||
        % construction de beta.e1 (taille j+1)
        % ... 
        % résolution de argmin ||beta.e1 - H_barre.y|| avec '\'
        % ...
    end
    
    % calcul de l'itérée courant x 
    x=x0+V(:,1:j)*ym;
    % calcul dde la norme du résidu et rangement dans resvec
    % calcul de la norme relative du résidu (backward error) relres
    j= j+1;
    resvec(j)=norm(b-A*x);
    relres=resvec(j)/norm(b);
    
    
end

% le nombre d'itération est j - 1 (imcrément de j en fin de boucle)
iter = j-1;

% positionnement du flac suivant comment on est sortie de la boucle
if(relres > tol)
    flag = 1;
else
    flag = 0;
end
