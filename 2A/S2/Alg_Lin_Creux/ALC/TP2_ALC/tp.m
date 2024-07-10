%%Le calcul de cholesky a un coup de 4nnz%%


%%Verification que les matrices sont symétrique et définie positive%%
load mat0.mat



L=chol(A,"lower");
n=size(A,1);
y=L\b;
x=L'\y;
%SymDefPos=VerificationDefSym(A);
erreur = CalculErreurInv(A,b,x);
erreur

figure
spy(A)

figure
spy(L)

%%Resolution avec Permutation et cholesky%%
p=symamd(A);
C=A(p,p);
b2=b(p);

Lbis=chol(C,"lower");
n=size(C,1);
y=Lbis\b2;
xbis=Lbis'\y;
SymDefPos=VerificationDefSym(A);
x(p) = xbis;
erreur2 = CalculErreurInv(A,b,x);
erreur2

figure
spy(C)

figure
spy(Lbis)

%%%%%%%%%%%%%%% LU %%%%%%%%%%%%%


load hydcar20.mat

%%Resolution avec la factorisation LU%%

[L,U,Q] =lu(A);
BPermute=Q*B;
n=size(A,1);
y=L\BPermute;
x=U\y;

erreur = CalculErreurInv(A,B,x);
erreur

figure
spy(A)

figure
spy(L)

figure
spy(U)

%%%Factorisation LU avec en plus la permutation trouvé avec amd%%%%%

p=amd(A);
A=A(p,p);
Bp=B(p);
[L,U,Q] =lu(A);
n=size(A,1);
Bp=Q*B;

y=L\Bp;
x=U\y;

erreur2 = CalculErreurInv(A,B,x);
erreur2


figure
spy(A)

figure
spy(L)

figure
spy(U)



