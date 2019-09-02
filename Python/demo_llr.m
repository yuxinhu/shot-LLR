%%
p.filepath = '/Users/huyx11/Downloads/code_llr';
p.NSHOT = 4; % number of shots
p.NDIR = 4; % number of directions (1 b0 + 3 dwi)
p.lambda = 0.004; % LLR regularization parameter
p.iter = 200; % number of iterations for LLR reconstruction
p.savetemp = false; % save reconstruction results of each nex and direction
%% load b = 0 images in k1.mat
load([p.filepath,'/k1.mat'])
[p.NX,p.NY,p.NC,p.NEX,p.NS] = size(k0);
final_res = zeros(p.NX,p.NY,p.NS, p.NDIR);
%% calculate b = 0 images using root sum of square (no partial fourier)
im = bart('fft -u -i 3',k0); % fourier transform in the first 2 dimensions using bart
im = bart('rss 4',im); % sum of square 
final_res(:,:,:,1) = squeeze(mean(im,4));
p.scale = max(abs(final_res(:)));
final_res = final_res/p.scale; % normalize the image
%% sensitivity map calculation from b = 0 images 
% using the first nex to calculate sensitivity map based on BART
for s = 1 : p.NS
    sens(:,:,s,:) = bart('ecalib -r 24 -m 1', permute(k0(:,:,:,1,s),[1 2 4 3]));
end
% % or using the low-resolution b0 images (divided by root-sos)
% p.acs = 24;
% ktemp = permute(squeeze(k0(:,:,:,1,:)),[1 2 4 3]);
% ktemp(:,[1:p.NY/2-p.acs/2, p.NY/2+p.acs/2+1:end],:,:) = 0;
% ktemp([1:p.NX/2-p.acs/2, p.NX/2+p.acs/2+1:end],:,:,:) = 0;
% 
% imtemp = bart('fft -u -i 3',ktemp);
% sens = imtemp ./ bart('rss 8',imtemp);
%%

for d = 2 : p.NDIR
    disp(['Reconstructing direction ', num2str(d), '/', num2str(p.NDIR)]);
    load([p.filepath,'/k',num2str(d),'.mat'])
    k0 = k0 / p.scale;
    clear res
    for s = 1 : p.NS % for each slice
        ktemp = preProcess(k0,s,p.NSHOT);
        for n = 1 : size(k0,4) % for each nex
            ktemp2 = permute(ktemp(:,:,:,:,n),[1 2 5 3 6 4]);
            comm = sprintf(['res(:,:,:,n) = squeeze(bart(',char(39),...
            'pics -R L:7:7:%d -w 1 -i %d',char(39),', ktemp2,sens(:,:,s,:)));'], p.lambda,p.iter);
            eval(comm);
        end % end of nex loop
        if p.savetemp
            save([p.filepath, '/res_dir',num2str(d),'_slice',num2str(s),'.mat'],'res')
        end 
        final_res(:,:,s,d) = mean(abs(res(:,:,:)),3);
    end % end of slice loop
end

save([p.filepath,'/LLR_sensb02.mat'],'final_res')
