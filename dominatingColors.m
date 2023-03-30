clear; close all;
image = imread("imageSeries2_year2001.png");
M = 1701; N = 1913;
imageR = image(:,:,1);
%imageR_vec = imageR(:);

imageG = image(:,:,2);
%imageG_vec = imageG(:);

imageB = image(:,:,3);
%imageB_vec = imageB(:);

imageR_reduced = zeros(floor(M/10), floor(N/10)); imageG_reduced = imageR_reduced; imageB_reduced = imageR_reduced;

i = 1; %reduced matrix's m element
for m = 1:10:M
    j = 1; %reduced matrix's n element
    for n = 1:10:N
        imageR_reduced(i,j)= imageR(m,n);
        imageG_reduced(i,j)= imageG(m,n);
        imageB_reduced(i,j)= imageB(m,n);


        j = j+1;
    end
    i = i+1;
end

%check that image is reconstructed
% image_reduced = zeros(171, 192, 3);
% image_reduced(:,:,1) = imageR_reduced;
% image_reduced(:,:,2) = imageG_reduced;
% image_reduced(:,:,3) = imageB_reduced;
% image_reduced = uint8(image_reduced);
% imshow(image_reduced);



% 
Mvec = linspace(1, floor(M/10), floor(M/10)+1);
Nvec = linspace(1, floor(N/10), floor(N/10)+1);

figure
surf(Nvec, Mvec, imageR_reduced, 'FaceColor', 'r')
hold on
surf(Nvec, Mvec, imageG_reduced, 'FaceColor', 'g')
surf(Nvec, Mvec, imageB_reduced, 'FaceColor', 'b')
view([0 90])
colorbar
grid on




%plot(x, imageR_vec, 'Color', 'r');

% plot(x, imageG_vec, 'Color', 'g');
% plot(x, imageB_vec, 'Color', 'b');

%test
% x = linspace(1, 5, 5); y = x;
% plot(x, y)




% x=[0.2;0.5;0.8;1;1.5];
% y=[0;0.2;0.4;0.6;0.8];
% z = x*y';
% figure
% surf(x, y, z)
% grid on
% xlabel('x')
% ylabel('y')
