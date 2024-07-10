clear all;
close all;
load("TEB.mat");

consigne_DB_v = 1:0.2:6;

fig_Comparaison = figure('Name',"Comparaison des 3 chaînes", 'NumberTitle','off');
fig_Comparaison.Position = [100 100 900 400];
subplot(1,3,1);
semilogy(consigne_DB_v,TEB_calculee_DVB_S,".-k");
hold on;
semilogy(consigne_DB_v,TEB_calculee_Passe_Bas,"--+r");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB DVB_S","TEB Passe_bas");

subplot(1,3,2);
semilogy(consigne_DB_v,TEB_calculee_DVB_S,".-k");
hold on;
semilogy(consigne_DB_v,TEB_calculee_DVB_S2,"-og");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB DVB_S","TEB DVB_S2");

subplot(1,3,3);
semilogy(consigne_DB_v,TEB_calculee_DVB_S2,"-og");
hold on;
semilogy(consigne_DB_v,TEB_calculee_Passe_Bas,"--+r");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB DVB_S2","TEB Passe_bas");

nom = "Comparaison_Taille_10000";
saveas(fig_Comparaison,fullfile("Comparaison",nom+".png"));

fig_Comparaison_theorique = figure('Name', "Comparaison des TEBS théoriques", 'NumberTitle','off');
fig_Comparaison_theorique.Position = [100 100 900 400];

consigne_DB_v = 1:0.2:6;
consigne_v = 10.^(consigne_DB_v/10);

TEB_theorique_M_4 =  qfunc( sqrt(4 * consigne_v) * sin(pi/4) );
TEB_theorique_M_8 =  2*qfunc( sqrt(6 * consigne_v) * sin(pi/8) )/3;

subplot(1,3,1);
semilogy(consigne_DB_v,TEB_calculee_DVB_S,".-k");
hold on;
semilogy(consigne_DB_v,TEB_theorique_M_4,"b");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB DVB_S","TEB théorique");

subplot(1,3,2);
semilogy(consigne_DB_v,TEB_calculee_DVB_S,".-k");
hold on;
semilogy(consigne_DB_v,TEB_theorique_M_4,"b");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB DVB_S","TEB thérique");

subplot(1,3,3);
semilogy(consigne_DB_v,TEB_calculee_DVB_S2,"-og");
hold on;
semilogy(consigne_DB_v,TEB_theorique_M_8,"b");
xlabel("E_{n}/N_{0}");
ylabel("TEB");
title("Comparaison des TEBs");
legend("TEB DVB_S2","TEB théorique");

nom = "Comparaison_Theorique_Taille_10000";
saveas(fig_Comparaison_theorique,fullfile("Comparaison",nom+".png"));


%% Affichage des DSP

fig_DSP = figure('Name',"Comparaison des 3 chaînes pour DSP", 'NumberTitle','off');

Fe = 24000;
%DSP_DVB_S = pwelch(DSP_DVB_S, [], [], [], Fe, 'twosided');
%semilogy(linspace(-Fe/2,Fe/2,length(DSP_DVB_S)),fftshift(DSP_DVB_S));

%hold on;

DSP_Passe_Bas = pwelch(DSP_Passe_Bas, [], [], [], Fe, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_Passe_Bas)),fftshift(DSP_Passe_Bas));

hold on;

Fe = 6000;
DSP_DVB_S2 = pwelch(DSP_DVB_S2, [], [], [], 6000, 'twosided');
semilogy(linspace(-Fe/2,Fe/2,length(DSP_DVB_S2)),fftshift(DSP_DVB_S2));

xlabel("Fréquence (Hz)");
ylabel("Amplitude");
title("Comparaison des DSP");
legend("Passe Bas", "DVB S2");

nom = "Comparaison_DSP";
saveas(fig_DSP,fullfile("Comparaison",nom+".png"));


