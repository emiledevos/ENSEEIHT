function [val] = CalculErreurInv(A,b,x)
%CALCULERREURINV Summary of this function goes here
%   Detailed explanation goes here
val=norm(b-A*x)/norm(b);
end

