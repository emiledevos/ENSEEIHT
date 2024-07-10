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

Mapping_binaire = 2*x - 1;

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping_binaire,Vecteur_Ns); % Signal sur échantilloné

%% Création du filtre de mise en forme 

Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

%% Filtrage du signal

x_filtre = filter(Filtre,1,x_SE);

%% Simulation du canal de propagation

BW = [1000 8000]'; % Bande passante du filtre
nu = (BW/2)/Fe;
Ordre = 201; % Ordre du filtre 
Pas_filtre = -Ordre/2:(Ordre-1)/2;
h_pb = 2*nu.*sinc(2*nu*Pas_filtre);

% On rajoute des 0 à la fin pour la gestion du retard

% On filtre pour le canal avec BW = 1000
x_BW_1000 = filter(h_pb(1,:),1,[x_filtre zeros(1,floor((Ordre-1)/2))]);

% On filtre pour le canal avec BW = 8000
x_BW_8000 = filter(h_pb(2,:),1,[x_filtre zeros(1,floor((Ordre-1)/2))]);

% On concatène les deux signaux
x_canal = [x_BW_1000;x_BW_8000];

% On enlève le début qui correspond à la phase transitoire du filtre
x_canal = x_canal(:,floor((Ordre-1)/2)+1:end);


%% Signal en sortie du filtre de réception

x_recu = filter(Filtre,1,x_canal,[],2);

%% Détection

N0 = 8; % selon le diagramme de l'oeil
x_Sous_Echant = x_recu(:,N0:Ns:end);

x_apres_detection = x_Sous_Echant > 0;

%% Taux d'erreur binaire

TEB = sum(abs(x_apres_detection - x),2)/(length(x));

%% Convolution de H et Hr

g = conv(Filtre,Filtre);

%% Réponse impulsionelle globale

g_globale = [conv(g,h_pb(1,:)); conv(g,h_pb(2,:))];

%% Affichage

Temps = (0:(Taille*Ns -1))*Te;
pathname = "Transmission_figure";

% Affichage du après le filtre de mise en forme

nom = "Transmission_avec_canal_apres_mise_en_forme_taille_" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');

plot(Temps,x_filtre,'+');
hold on
plot(Temps,x_filtre);
hold off
ylabel("x modulé");
xlabel("Temps en seconde");
title("Tracé du signal après le filtre de mise en forme");

saveas(fig1,fullfile(pathname,nom+".png"));

% Affichage des réponses en fréquences
n_fft = 32768;
F = -Fe/2:Fe/(n_fft-1):Fe/2;

nom = "Transmission_avec_canal_reponse_en_frequence_taille_" + num2str(Taille);
fig2 = figure('Name',nom, 'NumberTitle','off');
fig2.Position(3:4) = [800 500];

subplot(2,2,1);
hold on
semilogy(F,fftshift(abs(fft(g,n_fft)))/max(abs(fft(g,n_fft))),"red");
semilogy(F,fftshift(abs(fft(h_pb(1,:),n_fft)))/max(abs(fft(h_pb(1,:),n_fft))),"blue");
hold off;
legend("|H(f)H_{r}(f)|","|H_{c}(f)|")
ylabel("Amplitude");
xlabel("fréquence");
title("Tracé de |H(f)H_{r}(f)| et |H_{c}(f)| avec BW = " + BW(1))

subplot(2,2,2);
hold on
semilogy(F,fftshift(abs(fft(g,n_fft)))/max(abs(fft(g,n_fft))),"red");
semilogy(F,fftshift(abs(fft(h_pb(2,:),n_fft)))/max(abs(fft(h_pb(2,:),n_fft))),"blue");
hold off;
legend("|H(f)H_{r}(f)|","|H_{c}(f)|")
ylabel("Amplitude");
xlabel("fréquence");
title("Tracé de |H(f)H_{r}(f)| et |H_{c}(f)| avec BW = " + BW(2))

subplot(2,2,[3,4]);
hold on
semilogy(F,fftshift(abs(fft(h_pb(1,:),n_fft))),"red");
semilogy(F,fftshift(abs(fft(h_pb(2,:),n_fft))),"blue");
hold off;
legend("BW = " + BW(1),"BW = " + BW(2));
ylabel("Amplitude");
xlabel("fréquence");
title("Tracé de la réponse en fréquence du filtre du canal pour BW différent");

saveas(fig2,fullfile(pathname,nom+".png"));

% Affichage des réponses impulsionnelle globale

nom = "Transmission_avec_canal_reponse_impulsionelle_globale_taille_" + num2str(Taille);
fig3 = figure('Name',nom, 'NumberTitle','off');

plot(g_globale(1,1:250));
hold on;
plot(g_globale(2,1:250));
hold off;
ylabel("Amplitude");
xlabel("Temps");
legend("BW = " + BW(1),"BW = " + BW(2));
title("Affichage des réponses impulsionelle globale en fonction de BW")

saveas(fig3,fullfile(pathname,nom+".png"));

% Diagramme de l'oeil

nom = "Transmission_avec_canal_diagramme_oeil_taille_" + num2str(Taille);
fig4 = figure('Name',nom, 'NumberTitle','off');

subplot(1,2,1)
plot(reshape(x_recu(1,2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil pour BW " + BW(1));

subplot(1,2,2)
plot(reshape(x_recu(2,2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil pour BW " + BW(2));

saveas(fig4,fullfile(pathname,nom+".png"));






