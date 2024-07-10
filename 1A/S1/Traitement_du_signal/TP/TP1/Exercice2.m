clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exercice 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Question 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Car après Fe, le signal va se répéter periodiquement (exemple cosinus
% avec les 2 dhiracs) et donc ca ne sert à rien de calculer après -> on ne
% gagne pas plus d'informations

%%% Question 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Définition des constantes
A = 1;
F0 = 1100;
N = 90;

% échantillonage Fe = 1000 Hz
Fe = 10000;
cos_1 = cos_echan(A,F0,Fe,N);

%Transforméé de Fourrier
Nfft = N/Fe;
fk = 0:1/Nfft:Fe-1;
F_cos_1 = fft(cos_1);
subplot(3,1,1);
semilogy(fk,abs(F_cos_1));
xlabel("Fréquences en Hz");
ylabel(["TFD pour Fe = ",Fe]);

% On retrouve bien la fréquence F0 du cosinus (le pic qu'on voit -> c'est
% le dirhac)

% échantillonage Fe = 1000Hz
Fe = 1000;
cos_2 = cos_echan(A,F0,Fe,N);

%Transformée de Fourrier
Nfft = N/Fe;
fk = 0:1/Nfft:Fe-1;
F_cos_2 = fft(cos_2);
subplot(3,1,2);
semilogy(fk,abs(F_cos_2));
xlabel("Fréquences en Hz");
ylabel(["TFD pour Fe = ",Fe]);

% On ne retrouve pas la fréquence F0, après echantillonage, F0 = 100 Hz

close all;
%%% Question 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Définition des constantes
A = 1;
F0 = 1100;
N = 90;

% échantillonage Fe = 10000 Hz
Fe = 10000;
cos_3 = cos_echan(A,F0,Fe,N);

%Transformé de Fourrier
index = [128 150 200 250];
for i = 1:4
    Np = N*i;
    Nfft = Np/Fe;
    fk = 0:1/Nfft:Fe-1;
    F_cos_3 = fft(cos_3,Np);
    subplot(2,2,i);
    grid on;
    semilogy(fk,abs(F_cos_3));
    xlabel("Fréquences en Hz");
    ylabel(["TFD pour Fe = ",Fe]);
    title(["N < Np = ",Np]);
    hold on
end

close all

%%% Question 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Définition des constantes
A = 1;
F0 = 1100;
N = 90;

% échantillonage Fe = 10000 Hz
Fe = 10000;
cos_4 = cos_echan(A,F0,Fe,N);
dsp = pwelch(cos_4,[],[],[],Fe,'twosided');
Fd = 0:Fe/(length(dsp)-1):Fe;
semilogy(Fd,abs(dsp));




% Définition des fonctions

function [x_echan] = cos_echan(A,F0,Fe,N)
    Te = 1/Fe;
    kTe = [0:N-1]*Te;
    x_echan = cos(2*pi*F0*kTe);
end