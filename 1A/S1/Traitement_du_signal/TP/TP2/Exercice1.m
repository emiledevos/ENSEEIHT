
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exercice 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%

A = 1;
Fe = 10000;
Te = 1/Fe;

%Nombre d'échantillon
N = 100;
k = 0:N-1;
kTe = k*Te;

%Calcul des signaux échantillonnés
cos_1 = cos_echan(A,1000,Fe,N);
cos_2 = cos_echan(A,3000,Fe,N);

cos_somme = cos_1 + cos_2;

%Affichage
subplot(2,1,1);
plot(kTe,cos_somme);
xlabel("Temps en seconde");
ylabel("cos(2\piF0kTE");
title("Figure du cosinus échantillonnée pour F0 = 1100 Hz et Fe = 10000 Hz");


%Transforméé de Fourrier
Nfft = N/Fe;
fk = 0:1/Nfft:Fe-1;
F_cos_somme = fft(cos_somme);
subplot(2,1,2);
semilogy(fk,abs(F_cos_somme));
xlabel("Fréquences en Hz");
ylabel(["TFD pour Fe = ",Fe]);





function [x_echan] = cos_echan(A,F0,Fe,N)
    Te = 1/Fe;
    kTe = [0:N-1]*Te;
    x_echan = cos(2*pi*F0*kTe);
end

