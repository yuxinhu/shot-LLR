function [ res ] = LLR(im,winSize,lambda)
% Apply LLR to the input image (mostly based on Dr. Tao Zhang's code)
% Input :
% im (nx-ny-nc): input image, the third dimension to be applied LLR.
% winSize: block size for LLR (two integers). 
% lambda: regularization parameter for LLR
%
% Output : 
% im_com (nx-ny-nc): image after LLR


% First zero-padd the image to the multiple of winSize, to make the local
% matrix separation easier.

[nx ny nc] = size(im);
bx = ceil(nx/winSize(1));
by = ceil(ny/winSize(2));
zpadx = bx*winSize(1);
zpady = by*winSize(2);

imzpad = zeros(zpadx, zpady, nc);
imzpad(1:nx, 1:ny, :) = im;


% Use a random shift to avoid the blocking artifacts.
nxrs = randperm(winSize(1));
nyrs = randperm(winSize(2));
imzpad = circshift(imzpad,[nxrs(1)-1, nyrs(1)-1, 0]);


for xx = 1 : bx
    for yy = 1 : by
        % Apply LLR for each local matrix
        
        % step1: take the elements and construct the matrix
        imb = imzpad((xx-1)*winSize(1)+1:xx*winSize(1),(yy-1)*winSize(2)+1:yy*winSize(2),:);
        imb = reshape(imb,[winSize(1)*winSize(2),nc]);
        
        % step2: do SVD and apply soft-thresholding
        [Ub,Sb,Vb] = svd(imb,'econ');
        sdiagb = diag(Sb);
        
        mu = lambda;
        sdiagb = sdiagb - mu;
        sdiagb(sdiagb < 0) = 0;
        imb = Ub*(diag(sdiagb))*Vb';
        
        % step3: update the images
        imb = reshape(imb,[winSize(1),winSize(2),nc]);
        imzpad((xx-1)*winSize(1)+1:xx*winSize(1),(yy-1)*winSize(2)+1:yy*winSize(2),:,:) = imb;
        
    end % along nx dimension
end % along ny dimension

% apply the inverse of the random shift
imzpad = circshift(imzpad,[-nxrs(1)+1, -nyrs(1)+1, 0]);
res = imzpad(1:nx, 1:ny, :, :);

end

