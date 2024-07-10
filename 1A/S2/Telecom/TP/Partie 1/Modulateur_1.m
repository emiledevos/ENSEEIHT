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

Mapping_1 = 2*x - 1;

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping_1,Vecteur_Ns); % Signal sur échantilloné

%% Création du Filtre

Filtre = zeros(1,length(Mapping_1)); 
Filtre(:,1:Ns) = 1;

%% Filtrage du signal

x_module = filter(Filtre,1,x_SE);


%% DSP

% DSP calculé

DSP = pwelch(x_module,[],[],[],Fe,'twosided');
F = (-Fe/2):Fe/(length(DSP)-1):Fe/2;

% DSP Théorique

DSP_theorique = Ts*(sinc(F*Ts)).^2;

%% Affichage

pathname = "Modulateur_figure";

Temps = (0:(Taille*Ns -1))*Te;

nom = "Modulateur_1_taille_" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');
fig1.Position(3:4) = [800 600];

subplot(3,1,1);
plot(Temps,x_module,'+');
hold on
plot(Temps,x_module);
hold off
ylabel("Amplitude");
xlabel("Temps en seconde");
title("Tracé du signal après le modulateur 1");

subplot(3,1,2);
semilogy(F,abs(fftshift(DSP)));
legend("DSP calculé");
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Tracé de le DSP calculé")


subplot(3,1,3);
semilogy(F,abs(fftshift(DSP)));
hold on;
semilogy(F,abs(DSP_theorique));
legend("DSP calculé","DSP théorique");
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Tracé de le DSP calculé superposé avec la DSP théorique")

saveas(fig1,fullfile(pathname,nom+".png"));
