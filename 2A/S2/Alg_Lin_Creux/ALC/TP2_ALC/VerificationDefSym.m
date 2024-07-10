function [b] = VerificationDefSym(A)
%VERIFICATIONDEFSYM Summary of this function goes here
%   Detailed explanation goes here
D=sort(eig(A));
b= (D(1) > 0) && (isequal(A,A'));
end

