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

%% Signal en sortie du filtre de mise en forme 

x_filtre = filter(Filtre,1,x_SE);

%% Signal en sortie du filtre de réception

x_recu = filter(Filtre,1,x_filtre);

%% Détection

N0 = 8;
x_Sous_Echant = x_recu(N0:Ns:end);

x_apres_detection = x_Sous_Echant > 0;

%% Taux d'erreur binaire

TEB = sum(abs(x_apres_detection - x))/(length(x))

%% Réponse impulsionelle globale

g = conv(Filtre,Filtre);

%% Affichage

pathname = "Transmission_figure";

% Affichage du signal après le filtre de mise en forme

Temps = (0:(Taille*Ns -1))*Te;

nom = "Transmission_sans_canal_apres_mise_en_forme_taille_" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');
fig1.Position(3:4) = [1000 400];

plot(Temps,x_filtre,'+');
hold on
plot(Temps,x_filtre);
hold off
ylabel("x modulé");
xlabel("Temps en seconde");
title("Tracé du signal après le filtre de mise en forme");

saveas(fig1,fullfile(pathname,nom+".png"));

% Affichage du signal après détection

nom = "Transmission_sans_canal_apres_detection_taille_" + num2str(Taille);
fig2 = figure('Name',nom, 'NumberTitle','off');
fig2.Position(3:4) = [1000 400];

plot(x_apres_detection,'+');
hold on
plot(x_apres_detection);
hold off
ylabel("valeur binaire");
xlabel("échantillonage");
title("Tracé du signal apres détection");

saveas(fig2,fullfile(pathname,nom+".png"));

% Affichage de la réponse impulsionelle globale

nom = "Transmission_sans_canal_reponse_impulsionelle_globale_taille_" + num2str(Taille);
fig3 = figure('Name',nom, 'NumberTitle','off');
fig3.Position(3:4) = [1000 400];

plot(g(1:20));
ylabel("Amplitude");
xlabel("Temps");
title("Affichage de la réponse impulsionelle globale")

saveas(fig3,fullfile(pathname,nom+".png"));

% Diagramme de l'oeil

nom = "Transmission_sans_canal_diagramme_oeil_taille_" + num2str(Taille);
fig4 = figure('Name',nom, 'NumberTitle','off');

plot(reshape(x_recu(2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil");

saveas(fig4,fullfile(pathname,nom+".png"));










