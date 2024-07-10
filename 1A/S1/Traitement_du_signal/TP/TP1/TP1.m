
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exercice 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Définition des constantes
A = 1;
Fo = 1100;
Fe = 10000;
Te = 1/Fe ;

N = 90; %Nombre d'échantillon
k = [0:N-1];
kTe = k*Te;

%Calcul du signal échantillonnée
x_echan = cos(2*pi*Fo*kTe);

%Affichage
plot(kTe,x_echan);
xlabel("Temps en seconde");
ylabel("cos(2\piF0kTE");
title("Figure du cosinus échantillonnée pour F0 = 1100 Hz et Fe = 10000 Hz");


%Définition des constantes
Fe = 1000;
Te = 1/Fe ;

N = 90; %Nombre d'échantillon
k = [0:N-1];
kTe = k*Te;

%Calcul du signal échantillonnée
x_echan = cos(2*pi*Fo*kTe);

%Affichage
plot(kTe,x_echan);
hold on;
xlabel("Temps en seconde");
ylabel("cos(2\piF0kTE");
title("Figure du cosinus échantillonnée pour F0 = 1100 Hz et Fe = 1000 Hz");






