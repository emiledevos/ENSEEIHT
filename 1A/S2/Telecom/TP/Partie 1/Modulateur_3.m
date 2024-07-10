clear all;
close all;
%% Variables
Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb; % Durée d'un symbole
Taille = 10000; % Taille de l'échantillon binaire

%% Génération de bit

Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
x = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping

Mapping_3 = 2*x - 1;

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping_3,Vecteur_Ns); % Signal sur échantilloné

%% Création du Filtre

%Filtre = rcosdesign(alpha,Taille,Ns);
alpha = 0.6;
L = floor((Taille - 1)/Ns);
Filtre = rcosdesign(alpha, L, Ns);

%% Filtrage du Signal

x_module = filter(Filtre,1,[x_SE zeros(1,floor(length(x_SE)/10)-1)]);
x_module = x_module(floor(length(x_SE)/10):length(x_module));

%% DSP

% DSP calculé

DSP = pwelch(x_module,[],[],[],Fe,'twosided');
F = (-Fe/2):Fe/(length(DSP)-1):Fe/2;

% DSP Théorique

sigma_a_carre = Taille/4;

borne_inf = (1-alpha)/(2*Ts);
borne_sup = (1+alpha)/(2*Ts);

condition1 = find(abs(F) <= borne_inf);
condition2 = find(borne_inf < abs(F) & abs(F) < borne_sup);

S_X = zeros(1,length(F));

S_X(condition1) = Ts;
S_X(condition2) = (Ts/2)*(1 + cos(((pi*Ts)/alpha) * (abs(F(condition2)) - borne_inf)));

S_X = S_X*(var(Mapping_3)/Ts);


%% Affichage

pathname = "Modulateur_figure";

Temps = (0:(Taille*Ns -1))*Te;

nom = "Modulateur_3_taille_" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');
fig1.Position(3:4) = [800 600];

subplot(3,1,1);
plot(Temps,x_module,'+');
hold on
plot(Temps,x_module);
hold off
ylabel("Amplitude");
xlabel("Temps en seconde");
title("Tracé du signal après le modulateur 3");


DSP_cal = abs(fftshift(DSP));

subplot(3,1,2);
semilogy(F,DSP_cal);
legend("DSP calculé");
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Tracé de le DSP calculé")

subplot(3,1,3);
semilogy(F,DSP_cal/max(DSP_cal));
hold on;
semilogy(F,abs(S_X)/max(S_X));
legend("DSP calculé","DSP théorique");
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("   Tracé de le DSP calculé superposé avec la DSP théorique")

saveas(fig1,fullfile(pathname,nom+".png"));





