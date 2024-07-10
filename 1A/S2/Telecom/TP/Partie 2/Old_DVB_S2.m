clear all;
close all;

%% Variables

Fe = 6000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb/2; % Durée d'un symbole
alpha = 0.20;
Taille = 3*(10000); % Taille de l'échantillon binaire
Fp = 2000; %Hz (fréquence porteuse) 
Be=(1+alpha)/(2*Ts);
F_max=2*Fp+Be;
pathname = "DVB_S2_Figure";
sauvegarde = false;

%% Génération de l'échantillon binaire
M = 8;
Rs = Rb/log2(M);
Ns = Fe/Rs;
%Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
Bits = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping QPSK

% Définition des symboles 8-PSK
constellation = exp(1j*pi*(1:2:15)/8);

Mapping = constellation(bi2de(reshape(Bits,log2(M),[])','left-msb')+1);
%Mapping = pskmod(Bits,M)


%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping,Vecteur_Ns); % Signal sur échantilloné

%% Filtre de mise en forme
L = 201;
Filtre = rcosdesign(alpha, L, Ns);

%% Filtrage par le filtre de mise en forme 
xe1 = filter(Filtre,1, [x_SE zeros(1,(L*Ns)/2)]);
xe = xe1((L*Ns)/2+1:end);

%% Canal complexe passe-bas équivalent
%BW = 2*Be; % Bande passante du filtre
%nu = (BW/2)/Fe;
%Ordre = 201; % Ordre du filtre 
%Pas_filtre = -Ordre/2:(Ordre-1)/2;
%h_ce = 2*nu.*sinc(2*nu*Pas_filtre);

% Puissance du filtre
%P_h_ce = mean(abs(h_ce).^2);

% Filtrage

%x = filter(h_ce/(2),1,[xe zeros(1,(Ordre-1)/2)]);
%x = x((Ordre-1)/2 + 1:end);
%x = x/sqrt(x(1)/xe(1));

x = xe;

%% Bruit
Px = mean(abs(x).^2);
M = 8;
consigne_DB = 100; % Eb/N0
consigne = 10^(consigne_DB/10);
sigma = sqrt( (Px*Ns) / (6*consigne) );
bruit_I = sigma*randn(1,length(x));
bruit_Q = sigma*randn(1,length(x));

consigne_DB_v = 1:0.2:6;
consigne_v = 10.^(consigne_DB_v/10);
sigma_v = sqrt( (Px*Ns) ./ (6*consigne_v) );
bruit_v_I = sigma_v'.*randn(1,length(x));
bruit_v_Q = sigma_v'.*randn(1,length(x));

Z = x + bruit_I + 1j*bruit_Q;
Z_v = x + bruit_v_I + 1j*bruit_v_Q;

%% Filtrage 
z_t = filter(Filtre,1, [Z zeros(1,(L*Ns)/2)]);
z_t = z_t((L*Ns)/2+1:end);

z_t_v1 = filter(Filtre,1, [Z_v zeros(length(consigne_v),(L*Ns)/2)],[],2);
z_t_v = z_t_v1(:,(L*Ns)/2+1:end);

%% Échantillonage
N0 = 1; % = Ns (selon le diagramme de l'oeil)
z_m = z_t(:,N0:Ns:end);

z_m_v = z_t_v(:,N0:Ns:end);

%% Détection

distances_euclidiennes = abs(z_m.'-constellation).^2;
[~, indices] = min(distances_euclidiennes,[],2);
symboles = constellation(indices);
Bits_v1 = de2bi(indices-1,log2(length(constellation)),'left-msb');
Bits_final = reshape(Bits_v1',size(Bits'))';

%%% Pour la consigne qui varie
Bits_final_v = zeros(length(consigne_v),Taille);
for i = 1:length(consigne_v)
    z_m_i = z_m_v(i,:);
    distances_euclidiennes = abs(z_m_i.'-constellation).^2;
    [~, indices] = min(distances_euclidiennes,[],2);
    symboles = constellation(indices);
    Bits_v1 = de2bi(indices-1,log2(length(constellation)),'left-msb');
    Bits_final_v(i,:) = reshape(Bits_v1',size(Bits'))';
end

%% TEB 

TEB = sum(abs(Bits_final - Bits),2)/length(Bits);
TEB_v = sum(abs(Bits_final_v - Bits),2)/length(Bits);

TEB_theorique =  2*qfunc( sqrt(6 * consigne_v) * sin(pi/M) )/3;

%% Tracé

%%%% diagramme de l'oeil

nom = "Diagramme de l'oeil_" + Taille;

fig3 = figure('Name',nom, 'NumberTitle','off');
subplot(1,2,1)
plot(reshape(real(xe),2*Ns,length(real(xe))/(2*Ns)));
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil de partie réelle de xe");

subplot(1,2,2)
plot(reshape(imag(xe),2*Ns,length(imag(xe))/(2*Ns)));
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil de partie imaginaire de xe");

if sauvegarde
    saveas(fig3,fullfile(pathname,nom+".png"));
end

%%%% Tracé des TEB

nom = "Comparaison des TEBs_" + Taille;

fig_TEB = figure('Name',nom, 'NumberTitle','off');
semilogy(consigne_DB_v,TEB_v,"-b");
hold on;
semilogy(consigne_DB_v,TEB_theorique,"-.r");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB calculé","TEB théorique");

if sauvegarde
    saveas(fig_TEB,fullfile(pathname,nom+".png"));
end

%%%% Tracé constellation

nom = "Constellation_" + Taille;
fig_const = figure('Name',nom, 'NumberTitle','off');

for i = 1:6
    subplot(2,3,i);
    j = 1:5:26;
    i = j(i);
    scatter(real(z_m_v(i,:)),imag(z_m_v(i,:)),".k");
    hold on;
    s = scatter(real(Mapping),imag(Mapping),".r"); % Multiplication par la valeur de l'exponentielle
    s.SizeData = 800;
    xlabel("a_{k} (partie en phase)");
    ylabel("b_{k} (partie en quadrature)");
    title("Constellation pour Eb/N0 = " + consigne_DB_v(i));
    legend("Après échantilloneur","Après mapping");
end

if sauvegarde
    saveas(fig_const,fullfile(pathname,nom+".png"));
end

%% Sauvegarde du TEB calculée dans un fichier

if Taille == 30000 & consigne_DB_v == 1:0.2:6
    Taille_DVB_S = 0;
    TEB_calculee_DVB_S = 0;
    Taille_Passe_Bas = 0;
    TEB_calculee_Passe_Bas = 0;
    load("TEB.mat");
    Taille_DVB_S2 = Taille;
    TEB_calculee_DVB_S2 = TEB_v;
    save("TEB.mat","Taille_DVB_S","TEB_calculee_DVB_S","Taille_Passe_Bas","TEB_calculee_Passe_Bas","Taille_DVB_S2","TEB_calculee_DVB_S2");
end



