clear all;
close all;

%% VariablesFiltre
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

% Pour le modulateur 2
LUT = [3 1 -1 -3];
x_2bit = string(reshape(x,2,floor(Taille/2)));
x_2bit_string = x_2bit(1,:) + x_2bit(2,:);
x_dec = bin2dec(x_2bit_string);
Mapping_2 = LUT(x_dec + 1);

% Pour le modulateur 1 et 3 

Mapping_1 = 2*x - 1;
Mapping_3 = 2*x - 1;

%% Sur échantillonage

Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

% Pour le modulateur 1 
x_SE_1 = kron(Mapping_1,Vecteur_Ns);

% Pour le modulateur 2
x_SE_2 = kron(Mapping_2,Vecteur_Ns);

% Pour le modulateur 3
x_SE_3 = kron(Mapping_3,Vecteur_Ns);

%% Création du Filtre

% Création du filtre pour le modulateur 1
Filtre_1 = zeros(1,length(Mapping_1)); 
Filtre_1(:,1:Ns) = 1;

% Création du filtre pour le modulateur 2
Filtre_2 = zeros(1,length(Mapping_2)); 
Filtre_2(:,1:Ns) = 1;

% Création du filtre pour le modulateur 2
alpha = 0.6;
L = floor((Taille - 1)/Ns);
Filtre_3 = rcosdesign(alpha, L, Ns);

%% Filtrage du signal

% Pour le modulateur 1 
x_module_1 = filter(Filtre_1,1,x_SE_1);

% Pour le modulateur 2
x_module_2 = filter(Filtre_2,1,x_SE_2);

% Pour le modulateur 3
x_module_3 = filter(Filtre_3,1,[x_SE_3 zeros(1,floor(length(x_SE_3)/10)-1)]);
x_module_3 = x_module_3(floor(length(x_SE_3)/10):length(x_module_3));

%% DSP calculé

nfft = 512;

% Pour le modulateur 1 
DSP_1 = pwelch(x_module_1,[],[],nfft,Fe,'twosided');

% Pour le modulateur 2
DSP_2 = pwelch(x_module_2,[],[],nfft,Fe,'twosided');

% Pour le modulateur 1 
DSP_3 = pwelch(x_module_3,[],[],nfft,Fe,'twosided');

F = (-Fe/2):Fe/(length(DSP_1)-1):Fe/2;

%% DSP Théorique

% Pour le modulateur 1 
DSP_theorique_1 = Ts*(sinc(F*Ts)).^2;

% Pour le modulateur 2 
DSP_theorique_2 = 5*Ts*(sinc(F*Ts)).^2;

% Pour le modulateur 3

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

% Comparaison des DSP calculées

nom = "Comparaison_DSP_calculees_taille_" + num2str(Taille);
fig1 = figure('Name',nom, 'NumberTitle','off');

semilogy(F,abs(fftshift(DSP_1)));
hold on;
semilogy(F,abs(fftshift(DSP_2)));
hold on;
semilogy(F,abs(fftshift(DSP_3)));
legend("Modulateur 1","Modulateur 2", "Modulateur 3");
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Comparaison des DSP calculées des 3 modulateurs")

saveas(fig1,fullfile(pathname,nom+".png"));

% Comparaison des DSP théoriques

nom = "Comparaison_DSP_theoriques_taille_" + num2str(Taille);
fig2 = figure('Name',nom, 'NumberTitle','off');

semilogy(F,abs(DSP_theorique_1));
hold on;
semilogy(F,abs(DSP_theorique_2));
hold on;
semilogy(F,abs(S_X));
legend("DSP modulateur 1","DSP modulateur 2","DSP modulateur 3");
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Comparaison des 3 DSP théoriques");

saveas(fig2,fullfile(pathname,nom+".png"));








