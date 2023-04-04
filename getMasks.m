function [MaskedImages,idxs] = getMasks(Images, thresholds)
%GETMASKS returns mask for each image in Images array 
%   takes: 
%       Images (indices [# images, 3, M, N])  
%       thresholds (3x2 array containing min and max for each RGB)
%   
%   returns:
%       MaskedImages (Images masked with specified thresholds)
%       idxs (indices that are 1 for cases of object removal)

    if ndims(Images)==3  %check if one image
        ImagesHold = Images;
        clear('Images');
        Images(1,:,:,:) = ImagesHold;
    end


    dim = size(Images); numImages = dim(1);
    m = dim(2); n = dim(3);
    MaskedImages = zeros(numImages, m, n);
    
    rThresh = thresholds(1,:);
    bThresh = thresholds(2, :);
    gThresh = thresholds(3, :);
    for i = 1:numImages
        MaskedImages(i, :, :) = Mask(squeeze(Images(i,:,:,:)), rThresh, bThresh, gThresh);
    end
    
    idxs = (MaskedImages == 1); %pixels that are white in image
    idxs = logical(idxs);
    
end

