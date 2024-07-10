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

%% Filtre de mise en forme

Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

% Filtrage du signal
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
title("Tracé du signal après la mise en forme");

%% Simulation du canal de propagation
BW = 8000; % Bande passante du filtre
nu = (BW/2)/Fe;
Ordre = 201;
Pas_filtre = -Ordre/2:(Ordre-1)/2;
h_pb = 2*nu*sinc(2*nu*Pas_filtre);

% On rajoute des 0 à la fin pour la gestion du retard
x_filtre = [x_filtre zeros(1,floor((Ordre-1)/2))];

% On filtre pour le canal
x_canal = filter(h_pb,1,x_filtre);

% On enlève le début qui correspond à la phase transitoire du filtre
x_canal = x_canal(:,floor((Ordre-1)/2)+1:end);


%% Signal en sortie du filtre de réception

x_recu = filter(Filtre,1,x_canal);

Temps = (0:(Taille*Ns -1))*Te;

figure(6);
plot(Temps,x_recu,'+');
hold on
plot(Temps,x_recu);
hold off
ylabel("x modulé");
xlabel("Temps en seconde");
title("Tracé du signal après réception");


%% Détection

N0 = 8; % selon le diagramme de l'oeil
x_Sous_Echant = x_recu(N0:Ns:end);

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

%% Tracé

%%% Convolution de H et Hr

g = conv(Filtre,Filtre);

% Affichage

n_fft = 32768;
F = -Fe/2:Fe/(n_fft-1):Fe/2;

figure(3);
hold on
plot(F,abs(fft(g,n_fft)),"red");
plot(F,abs(fft(h_pb,n_fft)),"blue");
hold off;
legend("|H(f)H_{r}(f)|","|H_{c}(f)|")
ylabel("Amplitude");
xlabel("fréquence");
title("Affichage de la TF de la convolution de H et Hr")

%%% Réponse impulsionelle globale

g_globale = conv(g,h_pb);

% Affichage

figure(4);
plot(g);
ylabel("Amplitude");
xlabel("Temps");
title("Affichage de la réponse impulsionelle globale")

%%% Diagramme de l'oeil

figure(5);
plot(reshape(x_recu(2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil");





