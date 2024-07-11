clear all;
close all;

%% Variables

Fe = 24000; % Hz
Te = 1/Fe; % Période d'échantillonage
Rb = 6000; % Bits par seconde
Tb = 1/Rb; % Ici Tb = Ts
Ts = Tb/2; % Durée d'un symbole
alpha = 0.20;
Taille = 10000; % Taille de l'échantillon binaire
Fp = 2000; %Hz (fréquence porteuse) 
Be=(1+alpha)/(2*Ts);
F_max=2*Fp+Be;
pathname = "Figure";
sauvegarde = true;

%% Génération de l'échantillon binaire
M = 2;
Rs = Rb/log2(M);
Ns = Fe/Rs;
%Ns = floor(Ts/Te); % Nombre d'échantillon pour un symbole
Bits = randi(0:1,[1,Taille]); % Echantillon binaire

%% Mapping BPSK
Mapping = 2*Bits - 1;
Mapping_pas_transition = Mapping;

%% Codage par transition
ck_1 = 1;
for i = 1:length(Mapping)
    Mapping(i) = Mapping(i) * ck_1;
    ck_1 = Mapping(i);
end

%% Sur échantillonage
Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping,Vecteur_Ns); % Signal sur échantilloné
x_SE_pt = kron(Mapping_pas_transition,Vecteur_Ns);

%% Filtre de mise en forme
Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

%% Filtrage par le filtre de mise en forme 
x = filter(Filtre,1, x_SE);
x_pt = filter(Filtre,1, x_SE_pt);

%% Bruit
Px = mean(abs(x).^2);
consigne_DB = 100; % Eb/N0
consigne = 10^(consigne_DB/10);
sigma = sqrt( (Px*Ns) / (2*consigne) );
bruit_I = sigma*randn(1,length(x));
bruit_Q = sigma*randn(1,length(x));

consigne_DB_v = 1:0.2:6;
consigne_v = 10.^(consigne_DB_v/10);

% Bruit pour codage par transition
sigma_v = sqrt( (Px*Ns) ./ (2*consigne_v) );
bruit_v_I = sigma_v'.*randn(1,length(x));
bruit_v_Q = sigma_v'.*randn(1,length(x));

% Bruit pour codage normal (pas transition)
Px_pt = mean(abs(x_pt).^2);
sigma_v_pt = sqrt( (Px_pt*Ns) ./ (2*consigne_v) );
bruit_v_I_pt = sigma_v_pt'.*randn(1,length(x_pt));
bruit_v_Q_pt = sigma_v_pt'.*randn(1,length(x_pt));

Z = x; %+ bruit_I + 1j*bruit_Q;
Z_v = x + bruit_v_I  + 1j*bruit_v_Q;
Z_v_pt = x_pt + bruit_v_I_pt  + 1j*bruit_v_Q_pt;

%% Erreur de phase
Erreur_phase = [exp(1i*(2*pi)/9) exp(1i*(5*pi)/9) exp(1i*pi)];
%Erreur_phase = [1 1 1];

%% TEB théorique

TEB_theorique =  2*qfunc( sqrt(2*consigne_v));

%% Différents TEB pour grapique
% c = phase corrigé
% nc = phase pas corrigé
% n = codage normal
% pt = codage par transition
%
[TEB_phase_40_nc_n,~] = calcul_TEB(Z_v_pt, Bits,Ns,consigne_v, Erreur_phase(1),0,0);
[TEB_phase_40_c_n,~] = calcul_TEB(Z_v_pt, Bits,Ns,consigne_v, Erreur_phase(1),1,0);
[TEB_phase_40_nc_pt,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(1),0,1);
[TEB_phase_40_c_pt,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(1),1,1);

[TEB_phase_100_nc_n,~] = calcul_TEB(Z_v_pt, Bits,Ns,consigne_v, Erreur_phase(2),0,0);
[TEB_phase_100_c_n,~] = calcul_TEB(Z_v_pt, Bits,Ns,consigne_v, Erreur_phase(2),1,0);
[TEB_phase_100_nc_pt,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(2),0,1);
[TEB_phase_100_c_pt,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(2),1,1);

[TEB_classique,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, 1,0,1);


%% Tracé

%% Figure 1 (bon fonctionement du codage par transition)

nom = "Tracé du TEB codage transition";
fig_1 = figure('Name', nom, 'NumberTitle','off','Position',[200 200 700 700]);

semilogy(consigne_DB_v,TEB_classique,"-b");
hold on;
semilogy(consigne_DB_v,TEB_theorique,"--k");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs codage par transition et théorique");
legend("TEB calculé","TEB théorique");

if sauvegarde
    saveas(fig_1,fullfile(pathname,nom+".png"));
end

%% Figure 2 

nom = "Tracé codage transition comparaison";
fig_2 = figure('Name', nom, 'NumberTitle','off','Position',[200 200 1000 1000]);

subplot(2,1,1)
semilogy(consigne_DB_v,TEB_phase_40_nc_n,"-b",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_40_c_n,"--r",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_40_nc_pt,":k",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_40_c_pt,"-.m",'LineWidth',1);
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs pour phi = 400^{°}");
legend("Correction phase : non, Codage : normal", ...
    "Correction phase : oui, Codage : normal", ...
    "Correction phase : non, Codage : transition", ...
    "Correction phase : oui, Codage : transition")

subplot(2,1,2)
semilogy(consigne_DB_v,TEB_phase_100_nc_n,"-b",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_100_c_n,"--r",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_100_nc_pt,":k",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_100_c_pt,"-.m",'LineWidth',1);
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs pour phi = 100^{°}");
legend("Correction phase : non, Codage : normal", ...
    "Correction phase : oui, Codage : normal", ...
    "Correction phase : non, Codage : transition", ...
    "Correction phase : oui, Codage : transition")

if sauvegarde
    saveas(fig_2,fullfile(pathname,nom+".png"));
end



%% Fonction 

function [TEB, constellation] = calcul_TEB(x_init, Bits_init,Ns_init,consigne_init, expo_phase, correction, codage_transition)

    Filtre_init = zeros(1,length(Bits_init)); 
    Filtre_init(:,1:Ns_init) = 1;
    
    %% Erreur de phase
    Z = x_init*expo_phase;

    %% Filtrage 
    z_t = filter(Filtre_init,1,Z,[],2);
    
    %% Échantillonage
    N0 = 4; % = Ns (selon le diagramme de l'oeil)
    constellation = z_t(:,N0:Ns_init:end);

    %% Correction de phase
    if correction
        phi = mod(correction_phase(constellation),pi);
        constellation = constellation./exp(1i*phi);
    end

    z_m = real(constellation);

    %% Détection
    %%% Pour la consigne qui varie
    Bits_final = zeros(length(consigne_init),length(Bits_init));
    if codage_transition 
        for i = 1:length(consigne_init)
            z_m_i = z_m(i,:);

            % Décodage par Transition
            Decoding = zeros(1,length(z_m_i));
            Decoding(1) = z_m_i(1);
            for j = 2:length(z_m_i)
                Decoding(j) = z_m_i(j)*z_m_i(j-1);
            end

            % Détection
            z_m_sup_i = Decoding > 0;
            z_m_inf_i = Decoding < 0;
            Bits_final(i,:) = z_m_sup_i*1 + z_m_inf_i*0;
        end
    
    else
        for i = 1:length(consigne_init)
            z_m_i = z_m(i,:);
            z_m_sup_i = z_m_i > 0;
            z_m_inf_i = z_m_i < 0;
            Bits_final(i,:) = z_m_sup_i*1 + z_m_inf_i*0;
        end

    end

    TEB = sum(abs(Bits_final- Bits_init),2)/length(Bits_init);

end


function phi = correction_phase(Z_m) 
    phi = angle(sum(Z_m.^2,2))/2;
end



