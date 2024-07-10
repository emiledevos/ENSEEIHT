close all
clear
clc

%% Partie 1

load("ToyExample.mat");

k=2;
sigma=0.5;

[idx, A, B, C,L,Y,X] = classification_spectrale(Data, k, sigma);

figure()
clf
plot(Data((idx==1), 1), Data((idx==1), 2), "rx"); hold on
plot(Data((idx==2), 1), Data((idx==2), 2), "bx")


%% Partie 2.1

load("DataTransverse.mat");

DataTempsT=reshape(Image_DataT,64*54,20);
k=5;
sigma=0.57;
[idx, A, B, C] = classification_spectrale(DataTempsT, k, sigma);
idx_reshaped = reshape(idx, 64, 54);
DataTempsT=reshape(Image_DataT,64*54,20);
figure()
subplot(1, 2, 1)
imagesc(idx_reshaped)

subplot(1, 2, 2)
imagesc(Image_ROI_T)

%% Partie 2.2


load("DataSagittale.mat");

DataTempsS=reshape(Image_DataS,64*54,20);
k=8;
sigma=0.333333333333;
[idx, A, B, C] = classification_spectrale(DataTempsS, k, sigma);
idx_reshaped = reshape(idx, 64, 54);
DataTempsS=reshape(Image_DataS,64*54,20);
figure()
subplot(1, 2, 1)
imagesc(idx_reshaped)

subplot(1, 2, 2)
imagesc(Image_ROI_S)



