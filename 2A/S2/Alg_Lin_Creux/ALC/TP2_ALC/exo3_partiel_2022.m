A = [1 0 0 1 0 0 0 1 0;
     0 1 0 0 1 1 0 0 0;
     0 0 1 0 0 0 0 1 0;
     1 0 0 1 0 1 1 0 0;
     0 1 0 0 1 0 0 0 1;
     0 1 0 1 0 1 0 1 0;
     0 0 0 1 0 0 1 0 0;
     1 0 1 0 0 1 0 1 0;
     0 0 0 0 1 0 0 0 1];
 
 %norm(A - A')
 
subplot(2,3,1);
spy(A);
title('Original matrix A');

 
[count,h,parent,post,R] = symbfact(A);
ALU=R+R';
subplot(2,3,2)
spy(ALU);
title('Factors of A')
fillin=nnz(ALU)-nnz(A)

% visualisation du fill
C=spones(A);
CLU=spones(ALU);
FILL=CLU-C;
subplot(2,3,3)
spy(FILL)
title('Fill on original A')
