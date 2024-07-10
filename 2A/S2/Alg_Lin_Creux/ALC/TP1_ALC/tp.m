close all;
clear all;

load mat1;
%load pde225_5e-1;
%load hydcar20.mat;

n = size(A,1);
fprintf('dimension de A : %4d \n' , n);

b = [1:n]';

x0 = zeros(n, 1);

eps = 1e-6;

kmax = n;

fprintf('FOM\n');
[x, flag, relres, iter0, resvec0] = krylov(A, b, x0, eps, kmax, 0);
fprintf('Nb iterations : %4d \n' , iter0);
semilogy(resvec0, 'c');
if(flag == 0)
  fprintf('pas de convergence\n');
end

pause

fprintf('GMRES\n');
[x, flag, relres, iter1, resvec1] = krylov(A, b, x0, eps, kmax, 1);
fprintf('Nb iterations : %4d \n' , iter1);
hold on
semilogy(resvec1, 'r');
if(flag == 0)
  fprintf('pas de convergence\n');
end

pause 
fprintf('GMRES de matalaba\n');
[x, flag, relres, iter, resvec] = gmres(A, b, [], eps, kmax,[],[], x0);
fprintf('Nb iterations : %4d \n' , iter(2));
hold on
semilogy(resvec, 'b');


