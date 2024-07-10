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
Taille = 1000; % Taille de l'échantillon binaire
Temps = (0:(Taille*Ns -1))*Te;
x_bin = randi(0:1,[1,Taille]); % échantillon binaire
Vecteur_Ns = ones(1,floor(Ns));
NRZ = kron(x_bin,Vecteur_Ns);

%%% Génération de x %%% 

cos_bit_O = cos(2*pi*F0*Temps + Phi_1);

cos_bit_1 = cos(2*pi*F1*Temps + Phi_2);

x = (1 - NRZ).*cos_bit_O + NRZ.*cos_bit_1;

%%% Recherche de Pb %%%

SNR_dB = 5;
Px = mean(abs(x).^2);
Pb = Px/(10^(SNR_dB/10));

%%% Calcul du bruit %%%

bruit = sqrt(Pb)*randn(1,length(x));
x_bruit = x + bruit;

%%% Affichage %%%
figure(1);
subplot(3,1,1);
plot(Temps,x_bruit);
title("X bruité et pas filtré");
xlabel("Temps");

%close all;

%%% Valeur %%%

Fc = (F0+F1)/2;    %%% Je coupe au dessus du plus petit
nu = Fc/Fe;

%%% Ordre du filtre %%%
%N = 61;
N = 201;

%%% Filtre Passe Bas %%%

Borne = -(N-1)/2:(N-1)/2;            % Borne du filtre
H_Pb = 2*nu*sinc(2*nu*Borne);       % Réponse du filtre

%%% Filtre Passe Haut %%%
%%% Filtre en temps car combinaison linéaire de transformé de fourrier
%%% inverse

H_Ph = -H_Pb;
H_Ph(floor(length(H_Ph)/2) + 1 ) = H_Ph(floor(length(H_Ph)/2) + 1 ) + 1;

%%% Filtrage %%% 

%%% On filtre avec le passe bas %%% 

x_filtre_Pb=filter(H_Pb,1,x_bruit);
subplot(3,1,2);
plot(Temps, x_filtre_Pb,"g");
title("x filtré avec un passe bas");
xlabel("Temps");

%%% On filtre avec le passe haut %%%

x_filtre_Ph=filter(H_Ph,1,x_bruit);
subplot(3,1,3);
plot(Temps, x_filtre_Ph,"r");
title("x filtré avec un passe haut");
xlabel("Temps");

%%% Réponse impulsionelle %%% 

figure(2);

subplot(2,1,1);
plot(Borne,H_Pb,"g");
title("Réponse impulsionelle du filtre Passe Bas");

subplot(2,1,2);
plot(Borne,H_Ph,"r");
title("Réponse impulsionelle du filtre Passe Haut");

%%% Réponse en fréquence %%%

F = 0:Fe/(length(fft(H_Pb,256))-1):Fe;

figure(3);

%%% Réponse en fréquence du Passe Bas %%

subplot(3,1,1);
plot(F,abs(fft(H_Pb,256)),"g");
title("Réponse en fréquence du filtre Passe Bas");
xlabel("Fréquence en Hz");
ylabel("Gain");

%%% Réponse en fréquence du Passe Haut %%% 

subplot(3,1,2);
plot(F,abs(fft(H_Ph,256)),"r");
title("Réponse en fréquence du filtre Passe Haut");
xlabel("Fréquence en Hz");
ylabel("Gain");

subplot(3,1,3);
plot(F,abs(fft(H_Pb,256)),"g");
hold on;
plot(F,abs(fft(H_Ph,256)),"r");
title("Superposition des réponses en fréquences des deux filtres" )
legend("Filtre Passe Bas", "Filtre Passe Haut");
hold off



%%% DSP %%%

%%% Calcul de la DSP du signal d'entrée %%%

DSP_x = pwelch(x_bruit,[],[],[],Fe,'centered');
F = (-Fe/2):Fe/(length(DSP_x)-1):Fe/2;

%%% Calcul de la DSP du signal de sortie %%%

DSP_x_Pb = pwelch(x_filtre_Pb,[],[],[],Fe,'centered');
DSP_x_Ph = pwelch(x_filtre_Ph,[],[],[],Fe,'centered');

figure(4);

subplot(2,2,[1,2]);
semilogy(F,abs(DSP_x));
title("DSP signal d'entrée");

subplot(2,2,3);
semilogy(F,abs(DSP_x_Pb),"g");
title("DSP sortie passe bas");

subplot(2,2,4);
semilogy(F,abs(DSP_x_Ph),"r");
title("DSP  sortie passe haut ");

%%% Detection d'énergie %%%

figure(5)
%%% En sortie du filtre, le signal est retardé, on règle alors ce retard
%%% pour comparer les signaux d'entrées et de sorties

x_filtre_Pb_non_retarde = [x_filtre_Pb(floor((N-1)/2) + 1: length(x_filtre_Pb)) , x_filtre_Pb(1:floor((N-1)/2))];
somme = sum(reshape(x_filtre_Pb_non_retarde,floor(Ns),[]).^2);
Seuil = (max(somme) + min(somme))/2; %% On prend la moyenne
x_decodee = somme > Seuil;

%%% Taux d'erreur binaire %%%

Diff_Bin = x_bin - x_decodee;
Taux_Erreur_Binaire = sum(abs(Diff_Bin))/length(Diff_Bin);

subplot(3,1,1);
plot(x_bin);
title("Signal d'entrée");
subplot(3,1,2);
plot(x_decodee);
title("Signal bruitée qui a été décodé");
subplot(3,1,3);
plot(x_filtre_Pb);
title("Signal bruitée dans le passe bas");

NRZ_decode = kron(x_decodee, ones(1,floor(Ns)));
figure(6)
hold on;
plot(Temps,NRZ, "+");
plot(Temps,NRZ_decode);
xlabel("temps");
ylabel("Amplitude");
title("Comparaison signal initial et décodée");
hold off;

Taux_Erreur_Binaire

%%% 5.6.1 On constate une amélioration du taux d'erreur binaire (il est plus bas) %%% 

%%% 5.6.2 Lorsque qu'il n'y a pas de bruit, le taux d'erreur binaire n'est
%%% jamais tout le temps nul. 
%%% On ne peu tque augmenter l'ordre.

% Affichage du bon fonctionnement du filtre passe bas

figure(7)
subplot(3,1,1);
plot(Borne,H_Pb,"g");
title("Réponse impulsionelle du filtre Passe-Bas");
xlabel("Temps");
ylabel("Amplitude")
subplot(3,1,2);
F = 0:Fe/(length(fft(H_Pb,256))-1):Fe;
plot(F,abs(fft(H_Pb,256)),"g");
title("Réponse en fréquence du filtre Passe_Bas");
xlabel("Fréquence en Hz");
ylabel("Gain");
subplot(3,1,3);
F = (-Fe/2):Fe/(length(DSP_x)-1):Fe/2;
semilogy(F,abs(DSP_x_Pb),"g");
title("DSP sortie du Passe-Bas");
xlabel("Fréquence en Hz");
ylabel("Puissance")

% Affichage du bon fonctionnement du filtre passe haut

figure(8)
subplot(3,1,1);
plot(Borne,H_Ph,"r");
title("Réponse impulsionelle du filtre Passe-Haut");
xlabel("Temps");
ylabel("Amplitude")
subplot(3,1,2);
F = 0:Fe/(length(fft(H_Ph,256))-1):Fe;
plot(F,abs(fft(H_Ph,256)),"r");
title("Réponse en fréquence du filtre Passe-Haut");
xlabel("Fréquence en Hz");
ylabel("Gain");
subplot(3,1,3);
F = (-Fe/2):Fe/(length(DSP_x)-1):Fe/2;
semilogy(F,abs(DSP_x_Ph),"r");
title("DSP sortie du Passe-Haut");
xlabel("Fréquence en Hz");
ylabel("Puissance")







