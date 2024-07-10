clear all;
close all;

Dbt_Max = 300; %Bits par seconde 

%%% Valeur %%%

Fe = 48000;
F0 = 1180;
F1 = 980;

Phi_1 = rand*2*pi;
Phi_2 = rand*2*pi;

Fe = 48000; % Fréquence d'échantillonage
Te = 1/Fe; % Période d'échantillonage

%%% Génération du signal NRZ %%%

Ts = 1/Dbt_Max; % Durée d'un échantillon 
Ns = Ts/Te; % Nombre d'échantillon pour un bit
Taille = 10000; % Taille de l'échantillon binaire
Temps = (0:(Taille*Ns -1))*Te;
x_bin = randi(0:1,[1,Taille]); % échantillon binaire
Vecteur_Ns = ones(1,floor(Ns));
NRZ = kron(x_bin,Vecteur_Ns);

%%% Génération de x %%% 

cos_bit_0 = cos(2*pi*F0*Temps + Phi_1);

cos_bit_1 = cos(2*pi*F1*Temps + Phi_2);

x = (1 - NRZ).*cos_bit_0 + NRZ.*cos_bit_1;

%%% Recherche de Pb %%%

SNR_dB = 20;
Px = mean(abs(x).^2);
Pb = Px/(10^(SNR_dB/10));

%%% Calcul du bruit %%%

bruit = sqrt(Pb)*randn(1,length(x));
x_bruit = x + bruit;

%%% Calcule du démodulateur V21 sans bruit%%%

x_bin_0 = sum(reshape(x.*cos_bit_0, floor(Ns), []));

x_bin_1 = sum(reshape(x.*cos_bit_1, floor(Ns), []));

x_demod = x_bin_1 - x_bin_0;

x_demod = x_demod > 0;

NRZ_decode = kron(x_demod, ones(1,floor(Ns)));
figure(1)
hold on;
plot(Temps,NRZ, "+");
plot(Temps,NRZ_decode);
xlabel("temps");
ylabel("Amplitude");
title("Comparaison signal initial et décodée");
hold off;

Diff_Bin = x_bin - x_demod;
Taux_Erreur_Binaire = sum(abs(Diff_Bin))/length(Diff_Bin);


%%%% Gestion d'une erreur de synchronisation de phase porteuse

theta0 = rand*2*pi - pi;
theta1 = rand*2*pi - pi;
%theta0 = pi/4;
%theta1 = pi/4;

%%% Création des cos et des sin

cos_bit_0 = cos(2*pi*F0*Temps + theta0);
sin_bit_0 = sin(2*pi*F0*Temps + theta0);

cos_bit_1 = cos(2*pi*F1*Temps + theta1);
sin_bit_1 = cos(2*pi*F1*Temps + theta1);

%%% Création des signaux %%%

x_bin_0_bruit = sum(reshape(x.*(cos_bit_0+sin_bit_0),floor(Ns),[])).^2;
x_bin_1_bruit = sum(reshape(x.*(cos_bit_1+sin_bit_1),floor(Ns),[])).^2;

%%% Signal final %%%

x_final = x_bin_1_bruit - x_bin_0_bruit;

%%% Le signal retrouvé %%%

x_decode = x_final > 0;

%%% Calcul du taux d'erreur binaire %%%

Diff_bin = x_bin - x_decode;
Taux_Erreur_Binaire = sum(abs(Diff_Bin))/length(Diff_Bin)

%%% Retrouver l'image %%% 

load fichier1.mat;

%%% Récupération du temps %%%

Temps = [0:Te:(length(signal)-1)*Te];

%%% Création des cos et des sin

cos_bit_0 = cos(2*pi*F0*Temps + theta0);
sin_bit_0 = sin(2*pi*F0*Temps + theta0);

cos_bit_1 = cos(2*pi*F1*Temps + theta1);
sin_bit_1 = cos(2*pi*F1*Temps + theta1);

%%% Démodulation du signal 

signal_bin_0_bruit = sum(reshape(signal.*(cos_bit_0+sin_bit_0),floor(Ns),[])).^2;
signal_bin_1_bruit = sum(reshape(signal.*(cos_bit_1+sin_bit_1),floor(Ns),[])).^2;

%%% Signal final %%%

signal_final = signal_bin_1_bruit - signal_bin_0_bruit;

signal_decode = signal_final > 0;

%%% Affichage %%%

image(reconstitution_image(signal_decode));


function image_retrouvee = reconstitution_image(suite_binaire_reconstruite)


    %Reconstruction de l'image à partir de la suite de bits retrouvée
    mat_image_binaire_retrouvee=reshape(suite_binaire_reconstruite,105*100,8);
    mat_image_decimal_retrouvee=bi2de(mat_image_binaire_retrouvee);
    image_retrouvee=reshape(mat_image_decimal_retrouvee,105,100);

end











