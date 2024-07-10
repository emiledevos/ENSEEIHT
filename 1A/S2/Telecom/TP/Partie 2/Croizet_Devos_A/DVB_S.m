clear all;
close all;

%% Variables

Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb/2; % Durée d'un symbole
alpha = 0.35;
Taille = 10000; % Taille de l'échantillon binaire
Fp = 2000; %Hz (fréquence porteuse) 
Be=(1+alpha)/(2*Ts);
F_max=2*Fp+Be;
pathname = "DVB_S_Figure";
sauvegarde = true;

%% Génération de l'échantillon binaire
M = 4;
Rs = Rb/log2(M);
Ns = Fe/Rs;
%Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
Bits = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping QPSK
Mapping = (2*Bits(1:2:end)-1)+1j*(2*Bits(2:2:end)-1);

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

%% Transposition en fréquence

T = 0:Te:(Taille*Ns/2 -  1)*Te;
expo = exp(1j*2*pi*Fp*T);


%% Partie réelle 
x = real(expo.*xe);

%% Bruit
Px = mean(abs(x).^2);
M = 4;
consigne_DB = 5; % Eb/N0
consigne = 10^(consigne_DB/10);
sigma = sqrt( (Px*Ns) / (4*consigne) );
bruit = sigma*randn(1,length(x));

consigne_DB_v = 1:0.2:6;
consigne_v = 10.^(consigne_DB_v/10);
sigma_v = sqrt( (Px*Ns) ./ (4*consigne_v) );
bruit_v = sigma_v'.*randn(1,length(x));

x_v = x + bruit_v;
x = x + bruit;

%% Récupération de I et Q
I = 2*x.*cos(2*pi*Fp*T) ;
Q = 2*x.*sin(2*pi*Fp*T);

%I = real(xe);
%Q = imag(xe);

I_v = 2*x_v.*cos(2*pi*Fp*T) ;
Q_v = 2*x_v.*sin(2*pi*Fp*T);

%% Création de Z
Z = I - 1j*Q;
Z_v = I_v - 1j*Q_v;

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
z_11 = real(z_m) > 0 & imag(z_m) > 0;
z_10 = real(z_m) > 0 & imag(z_m) < 0;
z_01 = real(z_m) < 0 & imag(z_m) > 0;
z_00 = real(z_m) < 0 & imag(z_m) < 0;

d_m = 3*z_11 + 2*z_10 + 1*z_01 + 0*z_00;

LUT_inv = [0 1 2 3];
x_map_inv = LUT_inv(d_m + 1);
x_bin_inv = de2bi(x_map_inv);
x_bin_inv = [x_bin_inv(:,2) x_bin_inv(:,1)];
Bits_final = reshape(x_bin_inv',[1,Taille]);

%%% Pour la consigne qui varie
Bits_final_v = zeros(length(consigne_v),Taille);
for i = 1:length(consigne_v)
    z_m_i = z_m_v(i,:);
    z_11 = real(z_m_i) > 0 & imag(z_m_i) > 0;
    z_10 = real(z_m_i) > 0 & imag(z_m_i) < 0;
    z_01 = real(z_m_i) < 0 & imag(z_m_i) > 0;
    z_00 = real(z_m_i) < 0 & imag(z_m_i) < 0;

    d_m = 3*z_11 + 2*z_10 + 1*z_01 + 0*z_00;

    LUT_inv = [0 1 2 3];
    x_map_inv = LUT_inv(d_m + 1);
    x_bin_inv = de2bi(x_map_inv);
    x_bin_inv = [x_bin_inv(:,2) x_bin_inv(:,1)];
    Bits_final_v(i,:) = reshape(x_bin_inv',[1,Taille]);
end

%% TEB 

TEB = sum(abs(Bits_final - Bits),2)/length(Bits);
TEB_v = sum(abs(Bits_final_v - Bits),2)/length(Bits);

TEB_theorique =  qfunc( sqrt(4 * consigne_v) * sin(pi/M) );
%% Tracé

%%%% Tracé de I et Q
% Trac ́e des signaux g ́en ́er ́es sur les voies en phase et en quadrature avec une  ́echelle temporelle correcte.

T = 0:Ts:((length(I)-1)*Ts);
nom = "Tracé_de_I_(en phase)_et_Q_(en quadrature)_" + Taille;

fig1 = figure('Name',nom, 'NumberTitle','off');
plot(T,I,"-b");
hold on
plot(T,Q,".-r");
xlabel("Temps (s)");
ylabel("Amplitude");
title("Affichage de I et Q");
legend("tracé de Q","tracé de I");

if sauvegarde
    saveas(fig1,fullfile(pathname,nom+".png"));
end

%%%% Tracé de x 
% Tracé du signal transmis sur fréquence porteuse avec une échelle temporelle correcte

T = 0:Ts:((length(x)-1)*Ts);

nom = "Tracé_du_signal_transmis_sur_fréquene_porteuse_" + Taille;

fig_x = figure('Name',nom, 'NumberTitle','off');
plot(T,x,"-b");
xlabel("Temps (s)");
ylabel("Amplitude");
title("Affichage du signal transmis sur fréquence porteuse (x)");
legend("tracé de x");

if sauvegarde
    saveas(fig_x,fullfile(pathname,nom+".png"));
end

%%%% Tracé des DSPs

% Tracé de la DSP de z_T 

nom = "Tracé_des_DSP_de_z_t" + Taille;

fig_DSP_zt = figure('Name',nom, 'NumberTitle','off');
subplot(1,2,1)
DSP_xe_real=pwelch(real(z_t), [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_xe_real)),fftshift(DSP_xe_real));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("Tracé de la DSP de real(z_t)");


subplot(1,2,2)
DSP_xe_imag=pwelch(imag(z_t), [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_xe_imag)),fftshift(DSP_xe_imag));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("Tracé de la DSP de imag(z_t)");

if sauvegarde
    saveas(fig_DSP_zt,fullfile(pathname,nom+".png"));
end

% Tracé de la DSP de x

nom = "Tracé_de_la_DSP_de_x_" + Taille;

fig_DSP_x = figure('Name',nom, 'NumberTitle','off');
DSP_x=pwelch(x, [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_x)),fftshift(DSP_x));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("Tracé de la DSP de x");

if sauvegarde
    saveas(fig_DSP_x,fullfile(pathname,nom+".png"));
end

% Tracé de la DSP de xe

nom = "Tracé_de_la_DSP_de_xe_" + Taille;

fig_DSP_xe = figure('Name',nom, 'NumberTitle','off');
DSP_xe = pwelch(xe, [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_xe)),fftshift(DSP_xe));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("Tracé de la DSP de xe");

if sauvegarde
    saveas(fig_DSP_xe,fullfile(pathname,nom+".png"));
end

%%%% diagramme de l'oeil

nom = "Diagramme_de_l'oeil_" + Taille + "bruit_" + consigne_DB;

fig3 = figure('Name',nom, 'NumberTitle','off');
subplot(1,2,1)
plot(reshape(real(z_t),2*Ns,length(real(xe))/(2*Ns)));
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil de partie réelle de xe");

subplot(1,2,2)
plot(reshape(imag(z_t),2*Ns,length(imag(xe))/(2*Ns)));
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil de partie imaginaire de xe");

if sauvegarde
    saveas(fig3,fullfile(pathname,nom+".png"));
end

%%%% Tracé des TEB

% Trac ́e du taux d’erreur binaire obtenu en fonction du rapport signal `a bruit par bit `a l’entr ́ee du r ́ecepteur pour des valeurs allant de 0 `a 6 dB.

nom = "Comparaison_des_TEBs_" + Taille;

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

nom = "Constellation_" + Taille + "_consigne_DB_" + consigne;
fig_const = figure('Name',nom, 'NumberTitle','off');

subplot(1,3,1);
scatter(real(z_m),imag(z_m),".k");
xlabel("a_{k} (partie en phase)");
ylabel("b_{k} (partie en quadrature)");
title("Constellation après échantilloneur");

subplot(1,3,2);
scatter(real(Mapping),imag(Mapping),"+r");
xlabel("a_{k} (partie en phase)");
ylabel("b_{k} (partie en quadrature)");
title("Constellation en sortie du mapping");

subplot(1,3,3);
scatter(real(z_m),imag(z_m),".k");
hold on;
s = scatter(real(Mapping),imag(Mapping),".r"); % Multiplication par la valeur de l'exponentielle
s.SizeData = 800;
xlabel("a_{k} (partie en phase)");
ylabel("b_{k} (partie en quadrature)");
title("Constellation en sortie du mapping");
legend("Après échantilloneur","Après mapping");

if sauvegarde
    saveas(fig_const,fullfile(pathname,nom+".png"));
end

%% Sauvegarde du TEB calculée dans un fichier

if Taille == 10000 & consigne_DB_v == 1:0.2:6
    Taille_Passe_Bas = 0;
    TEB_calculee_Passe_Bas = 0;
    Taille_DVB_S2 = 0;
    TEB_calculee_DVB_S2 = 0;
    x_Passe_Bas = 0;
    DSP_Passe_Bas = 0;
    DSP_DVB_S2 = 0;
    load("TEB.mat");
    Taille_DVB_S = Taille;
    TEB_calculee_DVB_S = TEB_v;
    DSP_DVB_S = x;
    save("TEB.mat","Taille_DVB_S","TEB_calculee_DVB_S","DSP_DVB_S","Taille_Passe_Bas","TEB_calculee_Passe_Bas","DSP_Passe_Bas","Taille_DVB_S2","TEB_calculee_DVB_S2","DSP_DVB_S2");
end

