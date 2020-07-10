%% Load data and set parameters

% Please do not forget to include BART into path!

load('example.mat')
% k: nx - ny - ncoil - nshot
% sens: nx - ny - ncoil

iter = 100; % number of iterations
lambda = 0.0008; % regularization parameter for LLR term

%% shot-LLR recon by BART
k_bart = permute(k(:,:,:,:,1), [1 2 6 3 5 4]); 
% This is just to permute the dimension of the k-space to satisify BART's 
% requirement: the first three should be x-y-z, then the forth dimension is
% the coil dimension. We are putting the shot dimension as the time
% dimension in BART and apply LLR along that direction.

sens = permute(sens,[1 2 4 3]);
% Same here, but eaiser since no shot dimension for sensitivity map.

comm = sprintf(['llr = squeeze(bart(',char(39),...
    'pics -R L:7:7:%d -w 1 -i %d',char(39),', k_bart,sens));'], lambda,iter);
% Using the pics function in BART to solve the rereconstruction problem. 
% Please refer to BART about how to call it. 

eval(comm);

figure,imshow(fftshift(mean(abs(llr),3)',1),[])
% Using magnitude average to combine the shot dimension here. 
% Doing some shift and rotation to make the image direction look good.

