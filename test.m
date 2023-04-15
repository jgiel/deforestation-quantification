image = imread("imageSeries2_year2001.png");
thresh = [ 0.04    1;0    1;120/250    1];
%thresh = [ 0    0.01;0 .01;0 .01];
%thresh = [.0784 .5882];
color = 1;
% images = zeros(1, 1701, 1913, 3);
% images(1,:,:,:) = image;
mask = squeeze(getMasks(image, thresh ));

imshow(mask, [])