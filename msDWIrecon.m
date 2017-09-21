% msDWIrecon: reconstructed multishot phase incoherent DWI images
%
%
% INPUT
% k_spa:              cpx phase inhoerent k space data in [ky kz n_coil n_shots]
% sensemaps:          cpx sense maps in [ky kz n_coil]
% phase_error_maps:   cpx phase maps for every shot in [ky kz 1 n_shots]
% pars:               reconstruction parameters structure
%
% OUTPUT
% image_corrected:    reconstructed image
%
% (c) Qinwei Zhang (q.zhang@amc.uva.nl) 2017 @AMC Amsterdam



function image_corrected = msDWIrecon(kspa, sense_map, phase_error, pars)

[ky_dim, kz_dim, nc, ns] = size(kspa);

if (nc==1)
    assert(length(size(sense_map)) == 2 && sum([ky_dim kz_dim]==size(sense_map)) ==  2); %sense_map size check
else
    assert(length(size(sense_map)) == 3 && sum([ky_dim kz_dim nc]==size(sense_map)) ==  3); %sense_map size check
end

if(ns > 1)
    assert(length(size(phase_error)) == 4 && sum([ky_dim kz_dim 1 ns]==size(phase_error)) ==  4); %phase_error size check
else
    warning('This is a single-shot dataset!')
end




%% algorithms
if strcmp(pars.method, 'CG_SENSE_I')
    %% IMAGE SPACE CG_SENSE
    
    %preprocessing
    if(nc>1)
        sense_map = permute((normalize_sense_map(permute(sense_map,[4 1 2 3]))),[2 3 4 1]); %normalized in 4th dimension; so permute and permute back
    end
    phase_error = normalize_sense_map(phase_error); %miss use normalized_sense_map function to normalized phase_error map
    mask = abs(kspa) > 0;
    b = col(kspa);
    
    
    A=FPSoperator(sense_map, phase_error, [ky_dim kz_dim], nc, ns, mask);
    %         image_corrected = A'*b;  %direct inverse
    lamda =  pars.CG_SENSE_I.lamda;
    maxit =  pars.CG_SENSE_I.nit;
    tol =   pars.CG_SENSE_I.tol;
    image_corrected=regularizedReconstruction(A,b,@L2Norm,lamda,'maxit',maxit,'tol', tol);
elseif strcmp(pars.method, 'CG_SENSE_K')    
    %% KSPACE CG_SENSE TODO
    
    
    
elseif strcmp(pars.method, 'POCS_ICE') %update phase map iteratively
    %% POCS_ICE TODO
    trj = [];
    image_corrected = POCS_SENESE(kspa,trj, sense_map, pars);
    
    
elseif strcmp(pars.method, 'LRT') %recon in the LRT frame
    %% LRT TODO
else
    error('recon method not recognized...')
end


end