function [percentWhite] = percentWhite(MaskedImages, idxs)
%PERCENTWHITE returns array of percent of white in each BW image 
%   takes:
%       masked images and (optional) indexes that should be ignored
%   returns:
%       percentage of white pixels (ignoring specified pixels)
    dim = size(MaskedImages); numImages = dim(1);
    percentWhite = zeros(1, numImages);

    if exist('idxs', 'var') %if idxs to ignore are passed to method 
        for i = 1:numImages
            numIgnore = nnz(idxs(i,:,:)); %num of elements to ignore (elements that are 1 from river)
            
            numWhite = nnz(MaskedImages(i,:,:));% # white pixels
            numTotal = numel(MaskedImages(i,:,:))-numIgnore; % # of total pixels, except those from first mask (river)
        
            percentWhite(i) = numWhite / numTotal; %percent deforestation of each images
        end
    else
        for i = 1:numImages
            
            numWhite = nnz(MaskedImages(i,:,:));% # white pixels
            numTotal = numel(MaskedImages(i,:,:)); % # of total pixels, except those from first mask (river)
        
            percentWhite(i) = numWhite / numTotal; %percent deforestation of each images
        end
    end
end

