clear all;
close all;

Dbt_Max = 300; %Bits par seconde 

%%% Valeur %%%

Fc = 1080; %Hz
Delta_f = 100; %Hz
F0 = Fc + Delta_f; %Hz -> Correspond à l'état binaire 0
F1 = Fc - Delta_f; %Hz -> Correspond à l'état binaire 1

Phi_1 = rand*2*pi;
Phi_2 = rand*2*pi;

Fe = 48000; % Fréquence d'échantillonage
Te = 1/Fe; % Période d'échantillonage

%%% Génération du signal NRZ %%%

Ts = 1/Dbt_Max; % Durée d'un échantillon 
Ns = Ts/Te; % Nombre d'échantillon pour un bit
Taille = 20; % Taille de l'échantillon binaire
x = randi(0:1,[1,Taille]); % échantillon binaire
Vecteur_Ns = ones(1,floor(Ns));
NRZ = kron(x,Vecteur_Ns);

%%% Tracé du signal NRZ %%%

figure(1);

Temps = (0:(Taille*Ns -1))*Te;

plot(Temps,NRZ,'+');
hold on
plot(Temps,NRZ);
hold off
ylabel("mi(t)");
xlabel("temps en seconde");
title("Tracé de NRZ");

%close all;

%%% Densité spectrale de puissance du signal NRZ %%%

DSP = pwelch(NRZ,[],[],[],Fe,'twosided');
F = (-Fe/2):Fe/(length(DSP)-1):Fe/2;

%%% Calcul de la DSP théorique

S_NRZ = (Ts*(sinc(F*Ts).^2))/4;
S_NRZ(floor(length(DSP)/2)) = S_NRZ(floor(length(DSP)/2)) + 1/4;

%%% Tracé de la densité spectrale de puissance 

figure(2);

semilogy(F,abs(fftshift(DSP)));
hold on
semilogy(F,abs(S_NRZ));
legend('DSP calculé','DSP théorique');
ylabel("Amplitude");
xlabel("Fréquences Fe = 48 000 Hz");
title("Tracé des DSP");

%close all;

%%% 3.2 %%%

%%% Génération des cosinus

cos_bit_O = cos(2*pi*F0*Temps + Phi_1);

cos_bit_1 = cos(2*pi*F1*Temps + Phi_2);

%%% Signal modulé

x = (1 - NRZ).*cos_bit_O + NRZ.*cos_bit_1;

%%% Affichage du signal

figure(3);
plot(Temps,x);
legend('Signal modulé calculé');
ylabel("x(t)");
xlabel("temps en seconde");
title("Tracé de NRZ modulé avec les cosinus");
%close all;S_NRZ_function(F-F1,Ts) +

%%% Calcul théorique -> cf feuille Emile

figure(4);
subplot(2,1,1);
S_x = (1/4)*(S_NRZ_function(F-F1,Ts) + S_NRZ_function(F+F1,Ts) + S_NRZ_function(F-F0,Ts) + S_NRZ_function(F+F0,Ts));
semilogy(F,abs(S_x));
ylabel("S(f) théorique");
xlabel("Fréquences (en Hz)");
title("Densité spectral théorique de x");

%%% Calcul numérique

DSP_x = pwelch(x,[],[],[],Fe,'twosided');
subplot(2,1,2);
semilogy(F,abs(fftshift(DSP_x)));
xlabel('Fréquence (en Hz)');
ylabel('S(f) calculé');
title('La densité spectrale de puissance de x ');


%%% Fonction

function Valeur = S_NRZ_function(freq,Periode_S)
    Valeur = Periode_S*(sinc(freq*Periode_S).^2)/4;
end 














