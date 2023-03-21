function [BW,maskedRGBImage] = getMask(RGB, rThresh, gThresh, bThresh)
%takes RGB image and returns high-contrast BW image

% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = rThresh(1);
channel1Max = rThresh(2);

% Define thresholds for channel 2 based on histogram settings
channel2Min = gThresh(1);
channel2Max = gThresh(2);

% Define thresholds for channel 3 based on histogram settings
channel3Min = bThresh(1);
channel3Max = bThresh(2);

%IF ALL THREE COLORS FALL WITHIN RANGE, THEN CONVERT TO WHITE
% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
