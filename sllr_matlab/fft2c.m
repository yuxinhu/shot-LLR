function res = fft2c(x)
% 2D Fourier transform
fctr = size(x,1)*size(x,2);

res = fftshift(fft(ifftshift(x,1),[],1),1);
res = fftshift(fft(ifftshift(res,2),[],2),2);

res = 1/sqrt(fctr)*res;



