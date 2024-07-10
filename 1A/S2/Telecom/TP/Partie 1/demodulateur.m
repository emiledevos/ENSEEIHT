clear all;
close all;

%% Variables
Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb; % Durée d'un symbole
Taille = 100; % Taille de l'échantillon binaire

%% Génération de bit

Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
x = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping

Mapping_binaire = 2*x - 1;

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping_binaire,Vecteur_Ns); % Signal sur échantilloné

%% Filtre de mise en forme et de réception

Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

%% Signal en sortie du filtre de mie en forme 

x_filtre = filter(Filtre,1,x_SE);

% Affichage

Temps = (0:(Taille*Ns -1))*Te;

figure(1);
plot(Temps,x_filtre,'+');
hold on
plot(Temps,x_filtre);
hold off
ylabel("x modulé");
xlabel("Temps en seconde");
title("Tracé du signal modulé");

%% Signal en sortie du filtre de réception

x_recu = filter(Filtre,1,x_filtre);

%% Détection

x_Sous_Echant = x_recu(Ns:Ns:end);

x_apres_detection = x_Sous_Echant > 0;

%% Taux d'erreur binaire

TEB = sum(abs(x_apres_detection - x))/(length(x))

% Affichage

figure(2);
plot(x_apres_detection,'+');
hold on
plot(x_apres_detection);
hold off
ylabel("valeur binaire");
xlabel("échantillonage");
title("Tracé du signal apres reception");

%% Réponse impulsionelle globale

g = conv(Filtre,Filtre);

% Affichage

figure(3);
plot(g);
ylabel("Amplitude");
xlabel("Temps");
title("Affichage de la réponse impulsionelle globale")

%% Diagramme de l'oeil

figure(4);
plot(reshape(x_recu(2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil");










