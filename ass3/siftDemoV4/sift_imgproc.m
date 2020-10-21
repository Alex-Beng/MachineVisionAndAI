clear ; clc;

% 获得灰度图(原图)
raw_img = imread('../../ass2/big.JPG');
raw_img = rgb2gray(raw_img);

imwrite(raw_img, '0.jpg');

degree3_img = imrotate(raw_img, 3);
degree3_img = imresize(degree3_img, int32(size(degree3_img, [1,2])*1.2));
% figure;
% imshow(degree3_img);
imwrite(degree3_img, '1.jpg');

degree45_img = imrotate(raw_img, 45);
degree45_img = imresize(degree45_img, int32(size(degree45_img, [1,2])*1.4));
% figure;
% imshow(degree45_img);
imwrite(degree45_img, '2.jpg');

degree90_img = imrotate(raw_img, 90);
degree90_img = imresize(degree90_img, int32(size(degree90_img, [1,2])*0.8));
% figure;
% imshow(degree90_img);
imwrite(degree90_img, '3.jpg');
