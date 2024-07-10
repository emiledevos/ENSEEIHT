clear all

Q = [2 2 2; 2 4 5; 2 5 7];
R = chol(Q) ;
ibarre = [0.1; 0.2; 0.3] ;

[m,n] = size(Q);
I = round(ibarre);
v = R*(I-ibarre);  chi_de_v = v'*v;
chi = chi_de_v;
g = zeros(n,1);
d = zeros(n,1);
i = zeros(n,1);

g(n) = ceil(-sqrt(chi)/R(n,n)+ibarre(n));
d(n) = floor(sqrt(chi)/R(n,n)+ibarre(n));

boolcontinue = true;
i = zeros(n,1);
i(n) = g(n);
l = n;

while i(n) <= d(n)
    if i(l) <= d(l)
        v = R(l:n,l:n)*(i(l:n)-ibarre(l:n));
        chi_de_v = v'*v;
%       [l,chi_de_v,chi], [i,g,d], pause
        if l > 1
            if (chi > chi_de_v)
                l = l-1;
                g(l) = ceil(-(sqrt(chi - chi_de_v) - R(l,l+1:n)*(i(l+1:n)-ibarre(l+1:n)))/R(l,l)+ibarre(l));
                d(l) = floor((sqrt(chi - chi_de_v) - R(l,l+1:n)*(i(l+1:n)-ibarre(l+1:n)))/R(l,l)+ibarre(l));
                i(l) = g(l);
            else
                i(l) = i(l) + 1;
            end
        else
            if (chi > chi_de_v)
                chi = chi_de_v;
                Imin = i;
            end
            i(l) = i(l) + 1;
        end
    else
        if l < n
            l = l+1;
        end
        i(l) = i(l) + 1;
    end
 end
 
chi
Imin