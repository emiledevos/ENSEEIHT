function [c0,tab] = decomposition(valeur)
    J=log2(length(valeur));
    tab=sparse(J+1, length(valeur));
    tab(J+1,:) = valeur;
    for j = J:-1:1
        for k = 1:2^(j-1)
            tab(j,k)=(tab(j+1,2*k-1)+tab(j+1,2*k))/sqrt(2);%Premiere moitié contenant les Vj
            tab(j,2^(j-1) + k)=((tab(j+1,2*k-1)-tab(j+1,2*k)))/sqrt(2);%Premiere moitié contenant les Wj
        end

    end
    c0=tab(1,1);
end
