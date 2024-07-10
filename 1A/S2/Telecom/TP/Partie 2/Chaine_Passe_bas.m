clear all;
close all;

%% Variables

Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb/2; % Durée d'un symbole
alpha = 0.35;
Taille = 100; % Taille de l'échantillon binaire
Fp = 2000; %Hz (fréquence porteuse) 
Be=(1+alpha)/(2*Ts);
F_max=2*Fp+Be;
pathname = "Chaine_Passe_Bas_Figure";
sauvegarde = true;

%% Génération de l'échantillon binaire
M = 4;
Rs = Rb/log2(M);
Ns = Fe/Rs;
%Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
Bits = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping QPSK
Mapping = (2*Bits(1:2:end)-1)+1j*(2*Bits(2:2:end)-1); 
expo = [exp(1j*pi/4) exp(1j*3*pi/4) exp(-1j*pi/4) exp(-1j*3*pi/4)];

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping,Vecteur_Ns); % Signal sur échantilloné

%% Filtre de mise en forme
L = 201;
Filtre = rcosdesign(alpha, L, Ns);
Puissance_Filtre = mean(abs(Filtre).^2);

%% Filtrage par le filtre de mise en forme 
xe1 = filter(Filtre,1, [x_SE zeros(1,(L*Ns)/2)]);
xe = xe1((L*Ns)/2+1:end); 
x = xe;

%% Canal complexe passe-bas équivalent
%BW = 2*Be; % Bande passante du filtre
%nu = (BW/2)/Fe;
%Ordre = 201; % Ordre du filtre 
%Pas_filtre = -Ordre/2:(Ordre-1)/2;
%h_ce = 2*nu.*sinc(2*nu*Pas_filtre);

% Filtrage

%x = filter(h_ce/2,1,[xe zeros(1,(Ordre-1)/2)]);
%x = x((Ordre-1)/2 + 1:end);
%x = x/sqrt(mean(abs(x).^2)/mean(abs(xe).^2));


%% Bruit
Px = mean(abs(x).^2);
M = 4;
consigne_DB = 5; % Eb/N0
consigne = 10^(consigne_DB/10);
sigma = sqrt( (Px*Ns) / (4*consigne) );
bruit_I = sigma*randn(1,length(x));
bruit_Q = sigma*randn(1,length(x));

consigne_DB_v = 1:0.2:6;
consigne_v = 10.^(consigne_DB_v/10);
sigma_v = sqrt( (Px*Ns) ./ (4*consigne_v) );
bruit_v_I = sigma_v'.*randn(1,length(x));
bruit_v_Q = sigma_v'.*randn(1,length(x));

Z = x + bruit_I + 1j*bruit_Q;
Z_v = x + bruit_v_I + 1j*bruit_v_Q;

%% Filtrage de réception
z_t = filter(Filtre,1, [Z zeros(1,(L*Ns)/2)]);
z_t = z_t((L*Ns)/2+1:end);

z_t_v1 = filter(Filtre,1, [Z_v zeros(length(consigne_v),(L*Ns)/2)],[],2);
z_t_v = z_t_v1(:,(L*Ns)/2+1:end);


%% Échantillonage
N0 = 1; % = Ns (selon le diagramme de l'oeil)

% Echantilloneur
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

%%% Tracé des signaux phases et quadratures
% Trac ́e des signaux g ́en ́er ́es sur les voies en phase et en quadrature avec une  ́echelle temporelle correcte.

T = 0:Ts:((length(x)-1)*Ts);
nom = "Tracé_des_signaux_phases_et_quadratures_" + Taille;

fig_p_q = figure('Name',nom, 'NumberTitle','off');
subplot(2,2,[1,2]);
plot(T,real(xe),"-b");
hold on
plot(T,imag(xe),".-r");
xlabel("Temps (s)");
ylabel("Amplitude");
title("Affichage des signaux générés sur les voies en phase et en quadrature");
legend("en phase","en quadrature");

subplot(2,2,3);
plot(T,real(xe),"-b");
xlabel("Temps (s)");
ylabel("Amplitude");
title("Affichage des signaux générés sur la voie en phase");

subplot(2,2,4);
plot(T,imag(xe),".-r");
xlabel("Temps (s)");
ylabel("Amplitude");
title("Affichage des signaux générés sur la voie en quadrature");

if sauvegarde
    saveas(fig_p_q,fullfile(pathname,nom+".png"));
end

%%%% Tracé des DSPs

% DSP de phase et quadrature

nom = "Tracé_des_DSP_de_phase_et_quadrature_" + Taille;

fig_DSP_Xe = figure('Name',nom, 'NumberTitle','off');
subplot(1,2,1)
DSP_xe_real=pwelch(real(xe), [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_xe_real)),fftshift(DSP_xe_real));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("La voie en phase");


subplot(1,2,2)
DSP_xe_imag=pwelch(imag(xe), [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_xe_imag)),fftshift(DSP_xe_imag));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("La voie en quadrature");

if sauvegarde
    saveas(fig_DSP_Xe,fullfile(pathname,nom+".png"));
end

% DSP de X

nom = "Tracéde_la_DSP_de_x_" + Taille;

fig_DSP_x = figure('Name',nom, 'NumberTitle','off');
DSP_x=pwelch(x, [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_x)),fftshift(DSP_x));
xlabel('Fréquences (Hz)');
ylabel('S_{x_e}(f)');
title("Tracé de la DSP de x");

saveas(fig_DSP_x,fullfile(pathname,nom+".png"));

%%%% Tracé constellation

nom = "Constellation_" + Taille + "_consigne_DB_" + consigne;
fig_const = figure('Name',nom, 'NumberTitle','off');

for i = 1:6
    subplot(2,3,i);
    j = 1:5:26;
    i = j(i);
    scatter(real(z_m_v(i,:)),imag(z_m_v(i,:)),".k");
    hold on;
    s = scatter(0.7071*real(Mapping),0.7071*imag(Mapping),".r"); % Multiplication par la valeur de l'exponentielle
    s.SizeData = 800;
    xlabel("a_{k} (partie en phase)");
    ylabel("b_{k} (partie en quadrature)");
    title("Constellation pour Eb/N0 = " + consigne_DB_v(i));
    legend("Après échantilloneur","Après mapping");
end

if sauvegarde
    saveas(fig_const,fullfile(pathname,nom+".png"));
end

%%%% diagramme de l'oeil

nom = "Diagramme de l'oeil_" + Taille;

fig3 = figure('Name',nom, 'NumberTitle','off');
subplot(1,2,1)
plot(reshape(real(xe),2*Ns,length(real(xe))/(2*Ns)));
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil de partie réelle de xe");

subplot(1,2,2)
plot(reshape(imag(xe),2*Ns,length(xe)/(2*Ns)));
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil de partie imaginaire de xe");

if sauvegarde
    saveas(fig3,fullfile(pathname,nom+".png"));
end

%%%% Tracé des TEB

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

%% Sauvegarde du TEB calculée dans un fichier

if Taille == 10000 & consigne_DB_v == 1:0.2:6
    Taille_DVB_S = 0;
    TEB_calculee_DVB_S = 0;
    Taille_DVB_S = 0;
    TEB_calculee_DVB_S = 0;
    DSP_DVB_S = 0;
    DSP_DVB_S2 = 0;
    load("TEB.mat");
    Taille_Passe_Bas = Taille;
    TEB_calculee_Passe_Bas = TEB_v;
    DSP_Passe_Bas = x;
    save("TEB.mat","Taille_DVB_S","TEB_calculee_DVB_S","DSP_DVB_S","Taille_Passe_Bas","TEB_calculee_Passe_Bas","DSP_Passe_Bas","Taille_DVB_S2","TEB_calculee_DVB_S2","DSP_DVB_S2");
end



