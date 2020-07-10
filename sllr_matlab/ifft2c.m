function res = ifft2c(x)
% 2D inverse Fourier transform
fctr = size(x,1)*size(x,2);

res = ifftshift(ifft(fftshift(x,1),[],1),1);
res = ifftshift(ifft(fftshift(res,2),[],2),2);

res = sqrt(fctr)*res;

