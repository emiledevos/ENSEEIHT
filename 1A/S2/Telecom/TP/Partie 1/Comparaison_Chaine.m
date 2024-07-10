clear all;
close all;

%% Variables

Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 3000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb; % Durée d'un symbole
Taille = 10000; % Taille de l'échantillon binaire

%% Génération de l'échantillon binaire

Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
x = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping

% Mapping pour la chaine 1 et 2 
Mapping_1_2 = 2*x - 1;

% Mapping pour la chaine 3
LUT = [3 1 -1 -3];
x_2bit = string(reshape(x,2,floor(Taille/2)));
x_2bit_string = x_2bit(1,:) + x_2bit(2,:);
x_dec = bin2dec(x_2bit_string);
Mapping_3 = LUT(x_dec + 1);

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

% Pour la chaine 1
x_SE_1 = kron(Mapping_1_2,Vecteur_Ns);

% Pour la chaine 2
x_SE_2 = kron(Mapping_1_2,Vecteur_Ns);

% Pour la chaine 3
x_SE_3 = kron(Mapping_3,Vecteur_Ns);

%% Création du filtre de mise en forme

Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

%% Filtrage avec le filtre de mise en forme

% Pour la chaine 1
x_filtre_1 = filter(Filtre,1,x_SE_1);

% Pour la chaine 2
x_filtre_2 = filter(Filtre,1,x_SE_2);

% Pour la chaine 3
x_filtre_3 = filter(Filtre,1,x_SE_3);

%% Simulation du canal avec le bruit 

%% Pour les chaines 1 et 2 

% Création du bruit

Puissance = mean(abs(x_filtre_1).^2);
M = 2; %Ordre de la modulation (2 si binaire et 4 si 4-aire)

% Création du signal bruité

consigne_variable = [0:0.5:16]';

constante = (Puissance*Ns)/(2*log2(M));

sigma_variable = sqrt(constante./(10.^(consigne_variable/10)));

bruit_variable = sigma_variable*randn(1,length(x_filtre_1));

x_TEB = kron(ones(length(consigne_variable),1), x_filtre_1) + bruit_variable;

% Création du filtre de réception pour la chaine 2
Filtre_reception = zeros(1,Taille); 
Filtre_reception(:,1:floor(Ns/2)) = 1;

% Filtre de réception pour la chaine 1
x_TEB_1 = filter(Filtre,1,x_TEB,[],2);

% Filtre de réception pour la chaine 2
x_TEB_2 = filter(Filtre_reception,1,x_TEB,[],2);

%% Détection pour la chaine 1 

% Détection 
N0 = 8;
x_sous_echant_variable_1 = x_TEB_1(:,N0:Ns:end);
x_apres_detection_variable_1 = x_sous_echant_variable_1 > 0;

%Taux d'erreur binaire
TEB_variable_1 = sum(abs(x_apres_detection_variable_1 - x),2)/(length(x));

%% Détection pour la chaine 2

%%% Détection
N0 = 6;
x_sous_echant_variable_2 = x_TEB_2(:,N0:Ns:end);
x_apres_detection_variable_2 = x_sous_echant_variable_2 > 0;

%%% Taux d'erreur binaire
TEB_variable_2 = sum(abs(x_apres_detection_variable_2 - x),2)/(length(x));


%% Pour la chaine 3

Puissance = mean(abs(x_filtre_3).^2);

M = 4; %Ordre de la modulation (2 si binaire et 4 si 4-aire)

constante = (Puissance*Ns)/(2*log2(M));

sigma_variable = sqrt(constante./(10.^(consigne_variable/10)));

bruit_variable = sigma_variable*randn(1,length(x_filtre_3));

x_TEB = kron(ones(length(consigne_variable),1), x_filtre_3) + bruit_variable;

%%% Signal en sortie du filtre de réception
x_TEB = filter(Filtre,1,x_TEB,[],2);

%%% Détection

%%% Définition des seuilss

S1 = 16;
S2 = -16;
N0 = 8; % selon le diagramme de l'oeil
TEB_variable_3 = zeros(length(consigne_variable),1);

for i = 1:length(consigne_variable)
    x_Sous_Echant = x_TEB(i,N0:Ns:end);
    x_positif = x_Sous_Echant > 0;
    x_3 = x_Sous_Echant > S1;
    x_1 = x_positif - x_3;

    x_negatif = x_Sous_Echant < 0;
    x_n3 = x_Sous_Echant < S2;
    x_n1 = x_negatif - x_n3;

    x_apres_detection = 3*x_3 + x_1 + -1*x_n1 + -3*x_n3;

    x_apres_detection_bin = 0*x_3 + x_1 + 2*x_n1 + 3*x_n3;

    LUT_inv = [0 1 2 3];

    x_map_inv = LUT_inv(x_apres_detection_bin + 1);
    x_bin_inv = de2bi(x_map_inv);
    x_bin_inv = [x_bin_inv(:,2) x_bin_inv(:,1)];
    infoBinaireDecode = reshape(x_bin_inv',[1,Taille]);

    % TEB
    TEB_variable_3(i) = sum(abs(infoBinaireDecode - x))/length(x);
end

%% TEB théorique

% Pour la chaine 1
M = 2;
TEB_theorique_1 = 2*((M - 1) / (M*log2(M))) * qfunc(sqrt(((6 * log2(M)) / (M^2 - 1)) * 10.^(consigne_variable/10)));

% Pour la chaine 2
TEB_theorique_2 = 2*((M - 1) / (M*log2(M))) * qfunc(sqrt(((3 * log2(M)) / (M^2 - 1)) * 10.^(consigne_variable/10)));

% Pour la chaine 3
M = 4;
TEB_theorique_3 = 2*((M - 1) / (M*log2(M))) * qfunc(sqrt(((6 * log2(M)) / (M^2 - 1)) * 10.^(consigne_variable/10)));


%% Tracé

pathname = "Comparaison_Chaine_Figure";

% Affichage du TEB entre la chaine 1 et 2 

nom = "Comparaison_TEB_Chaine1_Chaine2_Taille" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');

semilogy(consigne_variable,TEB_variable_1,"--squareb");
hold on;
semilogy(consigne_variable,TEB_variable_2,"-.^r");
hold off
xlabel("E_{b}/N_{0}");
ylabel("TEB");
legend("Chaine 1", "Chaine 2");
title("Comparaison des TEB en fonction du bruit")

saveas(fig1,fullfile(pathname,nom+".png"));

% Affichage du TEB entre la chaine 1 et 3

nom = "Comparaison_TEB_Chaine1_Chaine3_Taille" + num2str(Taille);
fig2 = figure('Name',nom, 'NumberTitle','off');

semilogy(consigne_variable,TEB_variable_1,"--squareb");
hold on;
semilogy(consigne_variable,TEB_variable_3,"-vm");
hold off;
xlabel("E_{b}/N_{0}");
ylabel("TEB");
legend("Chaine 1", "Chaine 3");
title("Comparaison des TEB en fonction du bruit")

saveas(fig2,fullfile(pathname,nom+".png"));

% Affichage des TEB avec les TEB théoriques

nom = "Comparaison_TEB_Taille" + num2str(Taille);
fig3 = figure('Name',nom, 'NumberTitle','off');
fig3.Position(3:4) = [1000 420];

subplot(1,3,1);
semilogy(consigne_variable,TEB_variable_1,"--squareb");
hold on
semilogy(consigne_variable,TEB_theorique_1,":ok");
hold off
xlabel("E_{b}/N_{0}");
ylabel("TEB");
legend("TEB variable", "TEB théorique");
title("Chaine 1");

subplot(1,3,2);
semilogy(consigne_variable,TEB_variable_2,"-.^r");
hold on;
semilogy(consigne_variable,TEB_theorique_2,":ok");
hold off;
xlabel("E_{b}/N_{0}");
ylabel("TEB");
legend("TEB variable", "TEB théorique");
title("Chaine 2");

subplot(1,3,3);
semilogy(consigne_variable,TEB_variable_3,"-vm");
hold on;
semilogy(consigne_variable,TEB_theorique_3,":ok");
hold off;
xlabel("E_{b}/N_{0}");
ylabel("TEB");
legend("TEB variable", "TEB théorique");
title("Chaine 3");

fig3.Position

saveas(fig3,fullfile(pathname,nom+".png"));







