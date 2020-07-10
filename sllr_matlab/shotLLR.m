function imcom = shotLLR(k0,smap,iter,lambda)
%% LLR reconstruction solved by projection onto convex sets (POCS)
% Input :
% k (nx-ny-nc-ns): undersampled kspace data
% smap (nx-ny-nc) : sensitivity map 
% iter : number of iteration
% lambda: regularization parameter for LLR
%
% Output : 
% im_com (nx-ny-ns): coil-combined image
% By Yuxin Hu, Jan 30, 2018


winSize = [5,5];
[nx ny nc nshot] = size(k0);


mask = k0.*0;
mask(k0~=0) = 1; % get the sampling mask based on input k-space data.

smap = repmat(smap, [1 1 1 nshot]);

ktemp = k0;
for i = 1 : iter
    % step1: Projection based on the LLR term
    
    imtemp = ifft2c(ktemp) .* conj(smap);
    imcom = sum(imtemp,3); % get the coil combined image

    imcom = permute(LLR(squeeze(imcom),winSize,lambda),[1 2 4 3]); % apply the LLR constraint

    
    % step2: Projection based on the data consistency term

    imtemp = repmat(imcom,[1 1 nc 1]);
    ktemp = fft2c(smap.*imtemp);
    ktemp = ktemp.*(1-mask)+k0;

end


end

