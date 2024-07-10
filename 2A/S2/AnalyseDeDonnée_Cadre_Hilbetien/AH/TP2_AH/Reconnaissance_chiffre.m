% Ce programme est le script principal permettant d'illustrer
% un algorithme de reconnaissance de chiffres.

% Nettoyage de l'espace de travail
clear all; close all;

% Repertories contenant les donnees et leurs lectures
addpath('Data');
addpath('Utils')

rng('shuffle')


% Bruit
sig0=0.2;

%tableau des csores de classification
% intialisation aléatoire pour affichage
r=rand(6,5);
r2=rand(6,5);
tab_esp=[];
li = [];
distance=zeros(6,5);
for k=1:5
% Definition des donnees
file=['D' num2str(k)]

% Recuperation des donnees
disp('Generation de la base de donnees');
sD=load(file);
D=sD.(file);
%

% Bruitage des données
Db= D+sig0*randn(size(D));


%%%%%%%%%%%%%%%%%%%%%%%
% Analyse des donnees 
%%%%%%%%%%%%%%%%%%%%%%%
disp('PCA : calcul du sous-espace');
%%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
disp('TO DO')
n=size(Db,1);
indivMoyen = (1/n)*sum(Db');
X=Db-indivMoyen';
sigma=(1/n)*X*X';
[U,D]=eig(sigma);
[VP_trier,arangement] = sort(diag(D),'descend');
U_trier=U(:,arangement);
C = U_trier*X;
Precision_voulu=0.99999;

i=2;
while VP_trier(i)/VP_trier(1)>1 - Precision_voulu
   i=i+1;
end
esp = U_trier(:,1:i);
%%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%
disp('kernel PCA : calcul du sous-espace');

%%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%

K=noyeau(Db, Db);
K_gram = K - (1/size(K,1))*ones(size(K))*K - (1/size(K,1))*K*ones(size(K)) + (1/size(K,1)^2)*ones(size(K))*K*ones(size(K));

[U_k,D_k]=eig(K_gram);
[VP_trier_k,arangement_k] = sort(diag(D_k),'descend');
U_trier_k=U_k(:,arangement_k);
Precision_voulu_k=0.99999;

i=2;
while VP_trier_k(i)/VP_trier_k(1)>1 - Precision_voulu_k && i < size(U_trier_k, 1)
   i=i+1;
end
esp_k = U_trier_k(:,1:i);


%%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconnaissance de chiffres
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Lecture des chiffres à reconnaitre
 disp('test des chiffres :');
 tes(:,1) = importerIm('test1.jpg',1,1,16,16);
 tes(:,2) = importerIm('test2.jpg',1,1,16,16);
 tes(:,3) = importerIm('test3.jpg',1,1,16,16);
 tes(:,4) = importerIm('test4.jpg',1,1,16,16);
 tes(:,5) = importerIm('test5.jpg',1,1,16,16);
 tes(:,6) = importerIm('test9.jpg',1,1,16,16);


 for tests=1:6
    % Bruitage
    tes(:,tests)=tes(:,tests)+sig0*randn(length(tes(:,tests)),1);
    
    % Classification depuis ACP
     %%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
     disp('PCA : classification');
     disp('TO DO');
    r(tests,k)=norm((eye(256)-esp*esp')*tes(:,tests))/norm(tes(:,tests));
     if(tests==k)
       figure(100+k)
       subplot(1,2,1); 
       imshow(reshape(tes(:,tests),[16,16]));
       subplot(1,2,2);
       imReconstruite= indivMoyen' + (esp*esp') * (tes(:,tests) - indivMoyen');
       imshow(reshape(imReconstruite,[16,16]));
     end  
     if (tests == 6)
        figure(100+9)
       subplot(1,2,1); 
       imshow(reshape(tes(:,6),[16,16]));
       subplot(1,2,2);
       imReconstruite= indivMoyen' + (esp*esp') * (tes(:,6) - indivMoyen');
       imshow(reshape(imReconstruite,[16,16]));
     end
    %%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%
  
   % Classification depuis kernel ACP
     %%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
     disp('kernel PCA : classification');
     disp('TO DO')
    
     alpha_k = (1./sqrt(VP_trier_k(1:i)')).*esp_k;
     Pj_k = alpha_k' * noyeau(tes(:,tests), Db)';
     Pjb_k = alpha_k' * sum(K,2) /size(K,2);
     Beta_k = sum((Pj_k-Pjb_k)' .* alpha_k,2);

     num = Beta_k' * K * Beta_k;
     denum = noyeau(tes(:,tests),tes(:,tests)) - (2/size(K,1)) * sum(noyeau(tes(:,tests), Db)) + (1/(size(K,1)^2)) * sum(sum(K,1),2);
     
     r2(tests,k) = sqrt(1 - num/denum);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%    
 end
 
end


% Affichage du résultat de l'analyse par PCA
couleur = hsv(6);

figure(11)
for tests=1:6
     hold on
     plot(1:5, r(tests,:),  '+', 'Color', couleur(tests,:));
     hold off
 
     for i = 1:4
        hold on
         plot(i:0.1:(i+1),r(tests,i):(r(tests,i+1)-r(tests,i))/10:r(tests,i+1), 'Color', couleur(tests,:),'LineWidth',2)
         hold off
     end
     hold on
     if(tests==6)
       testa=9;
     else
       testa=tests;  
     end
     text(5,r(tests,5),num2str(testa));
     hold off
 end

% Affichage du résultat de l'analyse par kernel PCA
figure(12)
for tests=1:6
     hold on
     plot(1:5, r2(tests,:),  '+', 'Color', couleur(tests,:));
     hold off
 
     for i = 1:4
        hold on
         plot(i:0.1:(i+1),r2(tests,i):(r2(tests,i+1)-r2(tests,i))/10:r2(tests,i+1), 'Color', couleur(tests,:),'LineWidth',2)
         hold off
     end
     hold on
     if(tests==6)
       testa=9;
     else
       testa=tests;  
     end
     text(5,r2(tests,5),num2str(testa));
     hold off
end

function [res] = noyeau(x,y)
    c=0;
    d=1;
    res = (x'*y + c).^d;
end
