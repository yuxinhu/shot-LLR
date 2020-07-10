%% Load data and set parameters


load('example.mat')
% k: nx - ny - ncoil - nshot
% sens: nx - ny - ncoil

iter = 100; % number of iterations
lambda = 0.02; % regularization parameter for LLR term

%% shot-LLR recon
llr2 = shotLLR(k, sens,iter,lambda);

figure,imshow(fftshift(mean(abs(squeeze(llr2)),3)',1),[])
% Using magnitude average to combine the shot dimension here. 
% Doing some shift and rotation to make the image direction look good.

