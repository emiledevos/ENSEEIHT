clear all;
close all;

%%% Valeur %%%

Fe = 48000;
F0 = 6000;
F1 = 2000;

Fc = (F0+F1)/2;    %%% Je coupe au dessus du plus petit
nu = Fc/Fe;
N = 61;

%%% Filtre Passe Bas %%%

Borne = -(N-1)/2:(N-1)/2;            % Borne du filtre
H_Pb = 2*nu*sinc(2*nu*Borne);       % Réponse du filtre

%%% Filtre Passe Haut %%%
%%% Filtre en temps car combinaison linéaire de transformé de fourrier
%%% inverse

H_Ph = -H_Pb
H_Ph(floor(length(H_Ph)/2)) = H_Ph(floor(length(H_Ph)/2)) + 1;

%%% Filtrage %%% 

%%% On reprend le x bruité de l'exercice 4 




