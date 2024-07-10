clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exercice 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Question 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constantes
A = 1;
Fe = 10000;
Te = 1/Fe;
N = 100;
k = 0:N-1;
kTe = k*Te;
Fc = 2000;         % Fréquence de coupure
Nfft = 512;

% On veut conserver la fréquence f = 1000 Hz, il faut donc couper toutes
% les fréquences au dessus sans modifier f.
% LA fonction de transfert est de la forme H(p) = K/(1+tau*p)

% On cherche h(n)=TF-1(h°(v))        h°(v) une impulsion de longueur v
% h° -> Porte parfaite 

nu = Fc/Fe;                      % durée de l'impulsion
N_a = 11;                    % Ordre du filtre a
N_b = 61;                    % Ordre du filtre b
Borne_a = -(N_a-1)/2:(N_a-1)/2;       % Borne du filtre a
Borne_b = -(N_b-1)/2:(N_b-1)/2;       % Borne du filtre b
h_n_a = 2*nu*sinc(2*nu*Borne_a);          % Réponse du filtre a (calculer à la main)
h_n_b = 2*nu*sinc(2*nu*Borne_b);          % Réponse du filtre a (calculer à la main)
F = 0:Fe/(Nfft-1):Fe;
H_a = fft(h_n_a,Nfft);
H_b = fft(h_n_b,Nfft);

% Affichage
subplot(2,1,1);
plot(F,abs(H_a).^2);
xlabel('fréquence');
ylabel('ordre 11');
subplot(2,1,2);
plot(F,abs(H_b).^2);
xlabel('fréquence');
ylabel('ordre 61');

% on a tracé la reponse impulsionelle du filtre en temporelle


%%% Question 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function [x_echan] = cos_echan(A,F0,Fe,N)
    Te = 1/Fe;
    kTe = [0:N-1]*Te;
    x_echan = cos(2*pi*F0*kTe);
end