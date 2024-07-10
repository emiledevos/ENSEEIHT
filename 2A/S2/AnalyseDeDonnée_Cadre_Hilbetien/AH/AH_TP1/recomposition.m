function valf = recomposition(c0, D)
    J = size(tableau, 1) - 1;
    C = sparse(J+1, 2^J);
    C(1, 1) = c0;
    for j = 1:J
        for k = 1:2^(j)
            C(j+1, 2* k - 1) = (C(j, k) + D(j, k))/sqrt(2);
            C(j+1, 2* k) = (C(j, k) - D(j, k))/sqrt(2);
        end
    end
    valf = C(J+1, :);
end
