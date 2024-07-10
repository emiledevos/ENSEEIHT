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

%% Sur échantillonage
Vecteur_Ns = zeros(1,Ns);
Vecteur_Ns(1) = 1;

x_SE = kron(Mapping,Vecteur_Ns); % Signal sur échantilloné

%% Filtre de mise en forme
Filtre = zeros(1,Taille); 
Filtre(:,1:Ns) = 1;

%% Filtrage par le filtre de mise en forme 
xe = filter(Filtre,1, x_SE);
x = xe;

%% Bruit
Px = mean(abs(x).^2);
consigne_DB = 100; % Eb/N0
consigne = 10^(consigne_DB/10);
sigma = sqrt( (Px*Ns) / (2*consigne) );
bruit_I = sigma*randn(1,length(x));
bruit_Q = sigma*randn(1,length(x));

consigne_DB_v = 1:0.2:6;
consigne_v = 10.^(consigne_DB_v/10);
sigma_v = sqrt( (Px*Ns) ./ (2*consigne_v) );
bruit_v_I = sigma_v'.*randn(1,length(x));
bruit_v_Q = sigma_v'.*randn(1,length(x));

Z = x + bruit_I + 1j*bruit_Q;
Z_v = x + bruit_v_I + 1j*bruit_v_Q;

%% Erreur de phase
Erreur_phase = [exp(1i*(2*pi)/9) exp(1i*(5*pi)/9) exp(1i*pi)];
Z_phase = x.*Erreur_phase';

%% Filtrage 
z_t = filter(Filtre,1, Z);
z_t_v = filter(Filtre,1,Z_v,[],2);
z_t_phase = filter(Filtre,1,Z_phase,[],2);

%% Échantillonage
N0 = 4; % = Ns (selon le diagramme de l'oeil)

z_m_cons = z_t(:,N0:Ns:end);
z_m_v_cons = z_t_v(:,N0:Ns:end);
z_m_phase_cons = z_t_phase(:,N0:Ns:end);

%% Correction erreur de phase porteuse
phi_z_m = correction_phase(z_m_cons);
z_m_corrige = z_m_cons/exp(1i*phi_z_m);

phi_z_m_v = correction_phase(z_m_v_cons);
z_m_v_corrige = z_m_v_cons./exp(1i*phi_z_m_v);

phi_z_m_phase = correction_phase(z_m_phase_cons);
z_m_phase_corrige = z_m_phase_cons./exp(1i*phi_z_m_phase);

z_m = real(z_m_corrige);
z_m_v = real(z_m_v_corrige);
z_m_phase = real(z_m_phase_corrige);

%% Détection
z_m_sup = z_m > 0;
z_m_inf = z_m < 0;
Bits_final = z_m_sup*1 + z_m_inf*0;

%%% Pour la consigne qui varie
Bits_final_v = zeros(length(consigne_v),Taille);
for i = 1:length(consigne_v)
    z_m_i = z_m_v(i,:);
    z_m_sup_i = z_m_i > 0;
    z_m_inf_i = z_m_i < 0;
    Bits_final_v(i,:) = z_m_sup_i*1 + z_m_inf_i*0;
end

%%% Pour la phase qui varie
Bits_final_phase = zeros(length(Erreur_phase),Taille);
for i = 1:length(Erreur_phase)
    z_m_i = z_m_phase(i,:);
    z_m_sup_i = z_m_i > 0;
    z_m_inf_i = z_m_i < 0;
    Bits_final_phase(i,:) = z_m_sup_i*1 + z_m_inf_i*0;
end

%% TEB 

TEB = sum(abs(Bits_final - Bits),2)/length(Bits);
TEB_v = sum(abs(Bits_final_v - Bits),2)/length(Bits);
TEB_phase = sum(abs(Bits_final_phase - Bits),2)/length(Bits);

TEB_theorique =  qfunc( sqrt(2 * consigne_v));

%% Différents TEB pour grapique

[TEB_phase_40,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(1),1);
[TEB_phase_100,~] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(2),1);
[TEB_phase_40_non_corrige, constellation_40_non_corrige] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(1),0);
[TEB_phase_100_non_corrige, constellation_100_non_corrige] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(2),0);
[TEB_phase_180_non_corrige, constellation_180_non_corrige] = calcul_TEB(Z_v, Bits,Ns,consigne_v, Erreur_phase(3),0);
[TEB_phase_0] = calcul_TEB(Z_v, Bits,Ns,consigne_v, 1,0);

%% Tracé

%% Tracé phase non corrigé fig 1

TEB_theorique_phi_40 =  qfunc( sqrt(2 * consigne_v) * cos(40*pi/180));
TEB_theorique_phi_100 =  qfunc( sqrt(2 * consigne_v) * cos(100*pi/180));
TEB_theorique_phi_180 =  qfunc( sqrt(2 * consigne_v) * cos(180*pi/180));

nom = "Tracé des TEBs et constellations pour phase qui varie";
fig_1 = figure('Name', nom, 'NumberTitle','off','Position',[200 200 1200 900]);

subplot(2,3,1)
semilogy(consigne_DB_v,TEB_phase_40_non_corrige,"-b");
hold on;
semilogy(consigne_DB_v,TEB_theorique_phi_40,"-.k");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEB théorique et phi = 40 degres");
legend("TEB calculé avec phi = 40^{°}","TEB théorique");

subplot(2,3,2)
semilogy(consigne_DB_v,TEB_phase_100_non_corrige,"-b");
hold on;
semilogy(consigne_DB_v,TEB_theorique_phi_100,"-.k");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEB théorique et phi = 100 degres");
legend("TEB calculé avec phi = 100^{°}","TEB théorique");

subplot(2,3,3)
semilogy(consigne_DB_v,TEB_phase_180_non_corrige,"-b");
hold on;
semilogy(consigne_DB_v,TEB_theorique_phi_180,"-.k");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEB théorique et phi = 180 degres");
legend("TEB calculé avec phi = 180^{°}","TEB théorique");

for i = 1:length(Erreur_phase)
    subplot(2,3,i+3);
    j = [40 100 180];
    s1 = scatter(real(z_m_phase_cons(i,:)),imag(z_m_phase_cons(i,:)),".k");
    s1.SizeData = 1000;
    hold on;
    s2 = scatter(real(Mapping),imag(Mapping),".r"); % Multiplication par la valeur de l'exponentielle
    s2.SizeData = 1000;
    grid on;
    xlabel("a_{k} (partie en phase)");
    ylabel("b_{k} (partie en quadrature)");
    title("Constellation pour phi = " + j(i));
    legend("Après échantilloneur pour phi = " + j(i),"Après mapping");
end

if sauvegarde
    saveas(fig_1,fullfile(pathname,nom+".png"));
end

%% Tracé phase non corrigé fig 2

nom = "Tracé des TEBs phase qui varie";
fig_2 = figure('Name', nom, 'NumberTitle','off','Position',[200 200 700 700]);

subplot(1,2,1)
semilogy(consigne_DB_v,TEB_phase_40_non_corrige,"-b");
hold on;
semilogy(consigne_DB_v,TEB_phase_0,"-.r");
hold on;
semilogy(consigne_DB_v,TEB_theorique,"--k");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs phi égale à 40 et 0");
legend("phi = 40^{°}","phi = 0^{°}","TEB théorique");

subplot(1,2,2)
semilogy(consigne_DB_v,TEB_phase_40_non_corrige,"-b");
hold on;
semilogy(consigne_DB_v,TEB_phase_100_non_corrige,"-.r");
hold on;
semilogy(consigne_DB_v,TEB_theorique,"--k");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs phi égale à 40 et 100");
legend("phi = 40^{°}","phi = 100^{°}","TEB théorique");

if sauvegarde
    saveas(fig_2,fullfile(pathname,nom+".png"));
end

%% Tracé figure phase corrigé

nom = "Tracé des TEBs phase corrigée qui varie";
fig_3 = figure('Name', nom, 'NumberTitle','off','Position',[200 200 700 700]);

subplot(2,2,1)
semilogy(consigne_DB_v,TEB_phase_40_non_corrige,"-b",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_0,"-.r",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_40,"--k",'LineWidth',1);
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs pour phi égale à 40 ou 0");
legend("phi = 40^{°}","phi = 0^{°}","phi = 40^{°} phase corrigée");

subplot(2,2,2)
semilogy(consigne_DB_v,TEB_phase_100_non_corrige,"-b",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_0,"-.r",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_phase_100,"--k",'LineWidth',1);
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs pour phi égale à 100 ou 0");
legend("phi = 100^{°}","phi = 0^{°}","phi = 100^{°} phase corrigée");

subplot(2,2,3)
semilogy(consigne_DB_v,TEB_phase_40,"-b",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_theorique,"--k",'LineWidth',1);
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs phi = 40 correction de phase");
legend("phi = 40^{°} phase corrigée","Teb théorique");

subplot(2,2,4)
semilogy(consigne_DB_v,TEB_phase_100,"-b",'LineWidth',1);
hold on;
semilogy(consigne_DB_v,TEB_theorique,"--k",'LineWidth',1);
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison TEBs phi = 100 correction de phase");
legend("phi = 100^{°} phase corrigée","Teb théorique");

if sauvegarde
    saveas(fig_3,fullfile(pathname,nom+".png"));
end

%% Fonction 

function [TEB, constellation] = calcul_TEB(x_init, Bits_init,Ns_init,consigne_init, expo_phase, correction)

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
    for i = 1:length(consigne_init)
        z_m_i = z_m(i,:);
        z_m_sup_i = z_m_i > 0;
        z_m_inf_i = z_m_i < 0;
        Bits_final(i,:) = z_m_sup_i*1 + z_m_inf_i*0;
    end

    TEB = sum(abs(Bits_final- Bits_init),2)/length(Bits_init);

end


function phi = correction_phase(Z_m) 
    phi = angle(sum(Z_m.^2,2))/2;
end

