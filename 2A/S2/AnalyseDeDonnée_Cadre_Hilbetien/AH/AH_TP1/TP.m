

function D = TP(tableau)
    J = size(tableau, 1) - 1;
    D = sparse(J+1, 2^J);
    for j = 1:J
        for k = 1:2^(j)
            D(j, k) = tableau(j, k +  2^(j-1));
        end
    end
end