clear all;
close all;

%% Variables

Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb; % Durée d'un symbole
Taille = 1000; % Taille de l'échantillon binaire

%% Génération de l'échantillon binaire

Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
x = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping

LUT = [3 1 -1 -3];
x_2bit = string(reshape(x,2,floor(Taille/2)));
x_2bit_string = x_2bit(1,:) + x_2bit(2,:);
x_dec = bin2dec(x_2bit_string);
Mapping_3 = LUT(x_dec + 1);

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping_3,Vecteur_Ns); % Signal sur échantilloné

%% Création du filtre de mise en forme 

Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

%% Filtrage du signal avec le filtre de mise en forme 

x_filtre = filter(Filtre,1,x_SE);

%% Simulation du canal de propagation 

BW = 8000; % Bande passante du filtre
nu = (BW/2)/Fe;
Ordre = 201;
Pas_filtre = -Ordre/2:(Ordre-1)/2;
h_pb = 2*nu*sinc(2*nu*Pas_filtre);

%% Création du bruit

Puissance = mean(abs(x_filtre).^2);
M = 4; %Ordre de la modulation (2 si binaire et 4 si 4-aire)

consigne = 10; %Eb/N0
sigma = (Puissance*Ns)/(2*log2(M)*(10^(consigne/10)));
bruit = sqrt(sigma)*randn(1,length(x_filtre));

%% Ajout du bruit

% on fait un signal avec bruit et un signal sans bruit
x_filtre_bruit = [bruit + x_filtre; x_filtre];

% Le signal sur la première est avec le bruit tandis que sur la deuxième
% ligne le signal n'a pas de bruit


%% Filtrage par le filtre de réception

x_recu = filter(Filtre,1,x_filtre_bruit, [], 2);

%% Définition des seuilss
S1 = 16;
S2 = -16;
N0 = 8; % selon le diagramme de l'oeil

%% Détection
x_pre_detection = x_recu(:,N0:Ns:end);
infoBinaireDecode = zeros(2,Taille);

for i = 1:2
    %% Catégorisation des différents points
    x_Sous_Echant = x_pre_detection(i,:);
    x_positif = x_Sous_Echant > 0;
    x_3 = x_Sous_Echant > S1;
    x_1 = x_positif - x_3;

    x_negatif = x_Sous_Echant < 0;
    x_n3 = x_Sous_Echant < S2;
    x_n1 = x_negatif - x_n3;

    x_apres_detection_bin = 0*x_3 + x_1 + 2*x_n1 + 3*x_n3;

    %% LUT inverse

    LUT_inv = [0 1 2 3];
    x_map_inv = LUT_inv(x_apres_detection_bin + 1);
    x_bin_inv = de2bi(x_map_inv);
    x_bin_inv = [x_bin_inv(:,2) x_bin_inv(:,1)];
    infoBinaireDecode(i,:) = reshape(x_bin_inv',[1,Taille]);

end

%% Taux d'erreur binaire

TEB = sum(abs(infoBinaireDecode - x),2)/length(x);

%% Tracé

pathname = "Chaine3_figure";

% Diagramme de l'oeil

nom = "Chaine_3_Diagramme_de_oeil_taille_" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');

subplot(1,2,1)
plot(reshape(x_recu(1,2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil avec le bruit dans le canal, Eb/N0 = " + consigne);

subplot(1,2,2)
plot(reshape(x_recu(2,2*Ns + 1:end),2*Ns ,[]),"blue");
xlabel("Amplitude");
ylabel("Temps");
title("Diagramme de l'oeil sans le bruit dans le canal");

saveas(fig1,fullfile(pathname,nom+".png"));

%%
%%
%%
%%
%%

%%% On reprend le même principe, mais on fait maintenant varier le rapport
%%% Eb/n0


%% Création du bruit (Eb/N0 variables)
consigne_variable = [0:0.5:16]';

constante = (Puissance*Ns)/(2*log2(M));

sigma_variable = sqrt(constante./(10.^(consigne_variable/10)));

bruit_variable = sigma_variable*randn(1,length(x_filtre));

x_TEB = kron(ones(length(consigne_variable),1), x_filtre) + bruit_variable;

%%% Signal en sortie du filtre de réception
x_TEB = filter(Filtre,1,x_TEB,[],2);

%%% Détection
TEB_variable = zeros(length(consigne_variable),1);
for i = 1:length(consigne_variable)
    x_Sous_Echant = x_TEB(i,N0:Ns:end);
    x_positif = x_Sous_Echant > 0;
    x_3 = x_Sous_Echant > S1;
    x_1 = x_positif - x_3;

    x_negatif = x_Sous_Echant < 0;
    x_n3 = x_Sous_Echant < S2;
    x_n1 = x_negatif - x_n3;

    x_apres_detection_bin = 0*x_3 + x_1 + 2*x_n1 + 3*x_n3;

    LUT_inv = [0 1 2 3];

    x_map_inv = LUT_inv(x_apres_detection_bin + 1);
    x_bin_inv = de2bi(x_map_inv);
    x_bin_inv = [x_bin_inv(:,2) x_bin_inv(:,1)];
    infoBinaireDecode = reshape(x_bin_inv',[1,Taille]);

    % TEB
    TEB_variable(i) = sum(abs(infoBinaireDecode - x))/length(x);
end


%%% TEB théorique
TEB_theorique = 2*((M - 1) / (M*log2(M))) * qfunc(sqrt(((6 * log2(M)) / (M^2 - 1)) * 10.^(consigne_variable/10)));

%% Tracé

% Affichage du TEB qui varie

nom = "Chaine_3_variation_TEB_taille_" + num2str(Taille);
fig2 = figure('Name',nom, 'NumberTitle','off');

semilogy(consigne_variable,TEB_variable,"--squareb");
hold on;
semilogy(consigne_variable,TEB_theorique,":or");
xlabel("E_{b}/N_{0}");
ylabel("TEB");
legend("TEB calculé", "TEB théorique");
title("Comparaison des TEB en fonction du bruit")

saveas(fig2,fullfile(pathname,nom+".png"));

% Affichage du diagramme de l'oeil pour différents rapport Eb/N0

nom = "Chaine_1_variation_Diagramme_oeil_taille_" + num2str(Taille);
fig3 = figure('Name',nom, 'NumberTitle','off');

k = 1;
style = ["b","r","g","m"];
for i = [2 4 6 9]
    hold on;
    subplot(2,2,k);
    plot(reshape(x_TEB(i,2*Ns + 1:end),2*Ns ,[]),style(k));
    xlabel("Amplitude");
    ylabel("Temps");
    legend("E_{b}/N_{0} = " + consigne_variable(i));
    title("Diagramme de l'oeil avec E_{b}/N_{0} = " + consigne_variable(i));
    k = k + 1;
end
hold off;

saveas(fig3,fullfile(pathname,nom+".png"));


