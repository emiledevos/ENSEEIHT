function [idx, A,D, Dm1d,L,Y,X] = classification_spectrale(S, k, sigma)
    n = length(S);
    A = zeros(n, n);
    for i = 1:n
        for j = 1:n
            if i ~= j
                A(i, j) = exp(-norm(S(i, :)-S(j, :))^2/(2*sigma^2));
            end
        end
    end

    D = zeros(n, n);
    Dm1d = zeros(n, n);
    for i = 1:n
        D(i, i) = sum(A(i,:));
        Dm1d(i, i) = D(i, i)^(-1/2);
    end

    L = Dm1d * A * Dm1d;
    %disp(L)
    disp(sum(sum(D>0)))

    [Vect, Val] = eig(L);

    [~, ordre] = sort(diag(Val), 'descend');
    
    X = Vect(:, ordre(1:k));
    

    Y = zeros(n, k);


    for i = 1:n
        s = sum(X(i, :).^2)^(1/2);
        Y(i, :) = X(i, :)/s;
    end
    
    % figure(1),  clf, plot(Y(:,1), Y(:,2), 'o')
    
    idy=kmeans(Y,k);

    idx = idy;
end

