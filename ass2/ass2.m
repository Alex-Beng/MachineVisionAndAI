tic
clear ; clc;

% 获得灰度图(原图)
raw_img = imread('big.JPG');
resize_img = imresize(raw_img, [512, 512]);
gray_img = rgb2gray(resize_img);
subplot(3,3,1);
imshow(gray_img);
title('原始图像');

gaus_img = imnoise(gray_img,'gaussian', 0, (10/255)^2);
subplot(3,3,2);
imshow(gaus_img);
title('高斯噪声');

salt_img = imnoise(gray_img,'salt & pepper', 0.1);
subplot(3,3,3);
imshow(salt_img);
title('椒盐噪声');

% 高斯噪声滤波
my_Gauss_filter_out = my_Gauss_filter(gaus_img, fspecial('gaussian', 9));
subplot(3,3,5);
imshow(my_Gauss_filter_out);
title('自行高斯滤波');
% 使用matlab的filter
gaus_img = double(uint8(gaus_img));
kernal = fspecial('gaussian', 9); 
matlab_filter_out = imfilter(gaus_img, kernal);
size(matlab_filter_out)
size(my_Gauss_filter_out)
matlab_filter_out = uint8(matlab_filter_out);
subplot(3,3,8);
imshow(matlab_filter_out);
title('matlab高斯滤波');
% 输出差值
fprintf("高斯噪声图像自行高斯滤波与matlab滤波图像差值绝对值之和为%d\n", sum(sum(abs(matlab_filter_out-my_Gauss_filter_out))));
% 计算信噪比并输出
snr = 20*log(norm(double(gray_img),'fro')/norm(double(gray_img-my_Gauss_filter_out), 'fro')); 
fprintf("默认0.5标准差高斯滤波信噪比%f\n", snr);
% 使用不同标准差的高斯滤波器
x = 0.05:0.05:10;
y = [];
for i=x
    % fprintf("使用标准差为%f的高斯滤波器", i);
    kernal = fspecial('gaussian', 9, i); 
    matlab_filter_out = imfilter(gaus_img, kernal);
    matlab_filter_out = uint8(matlab_filter_out);
    snr = 20*log(norm(double(gray_img),'fro')/norm(double(gray_img-matlab_filter_out), 'fro')); 
    y = [y, snr];
    % fprintf("信噪比%f\n", snr);
end
figure(2);
subplot(1, 2, 1);
plot(x, y);
title("高斯噪声9x9不同标准差滤波后SNR");
figure(1);
% 中值滤波
kernal = zeros(3, 3);
my_Middle_filter_out = my_Middle_filter(gaus_img, kernal);
figure(3);
subplot(2, 2, 1);
imshow(my_Middle_filter_out);
title("自行中值滤波");
matlab_filter_out = medfilt2(gaus_img, [3,3]);
subplot(2, 2, 3);
imshow(matlab_filter_out);
title("matlab中值滤波");
figure(1);
size(matlab_filter_out)
size(my_Middle_filter_out)
my_Middle_filter_out = double(my_Middle_filter_out);
fprintf("高斯噪声图像自行中值滤波与matlab滤波图像差值绝对值之和为%d\n", sum(sum(abs(matlab_filter_out-my_Middle_filter_out))));





% 椒盐噪声滤波
my_Gauss_filter_out = my_Gauss_filter(salt_img, fspecial('gaussian', 9));
subplot(3,3,6);
imshow(my_Gauss_filter_out);
title('自行高斯滤波');
% 使用matlab的filter
salt_img = uint8(salt_img);
kernal = fspecial('gaussian', 9); 
matlab_filter_out = imfilter(salt_img, kernal);
size(matlab_filter_out)
size(my_Gauss_filter_out)
matlab_filter_out = uint8(matlab_filter_out);
subplot(3,3,9);
imshow(matlab_filter_out);
title('matlab高斯滤波');
% 输出差值
fprintf("椒盐噪声图像自行高斯滤波与matlab滤波图像差值绝对值之和为%d\n", sum(sum(abs(matlab_filter_out-my_Gauss_filter_out))));
% 计算信噪比并输出
snr = 20*log(norm(double(gray_img),'fro')/norm(double(gray_img-my_Gauss_filter_out), 'fro')); 
fprintf("默认0.5标准差高斯滤波信噪比%f\n", snr);
% 使用不同标准差的高斯滤波器
x = 0.05:0.05:10;
y = [];
for i=x
    % fprintf("使用标准差为%f的高斯滤波器", i);
    kernal = fspecial('gaussian', 9, i); 
    matlab_filter_out = imfilter(salt_img, kernal);
    matlab_filter_out = uint8(matlab_filter_out);
    snr = 20*log(norm(double(gray_img),'fro')/norm(double(gray_img-matlab_filter_out), 'fro')); 
    y = [y, snr];
    % fprintf("信噪比%f\n", snr);
end
figure(2);
subplot(1, 2, 2);
plot(x, y);
title("椒盐噪声9x9不同标准差滤波后SNR");
figure(1);
% 中值滤波
kernal = zeros(3, 3);
my_Middle_filter_out = my_Middle_filter(salt_img, kernal);
figure(3);
subplot(2, 2, 2);
imshow(my_Middle_filter_out);
title("自行中值滤波");
matlab_filter_out = medfilt2(salt_img, [3,3]);
subplot(2, 2, 4);
imshow(matlab_filter_out);
title("matlab中值滤波");
figure(1);
fprintf("椒盐噪声图像自行中值滤波与matlab滤波图像差值绝对值之和为%d\n", sum(sum(abs(matlab_filter_out-my_Middle_filter_out))));


% Sobel边缘检测
figure(4);
% 自己实现
kernal = [1,2,1; 0,0,0; -1,-2,-1];
my_sobel_out = my_Gauss_filter(gray_img, kernal);
subplot(1, 2, 1);
imshow(my_sobel_out);
title("my Sobel");

% matlab实现
matlab_edge_out = edge(gray_img, 'sobel', [], 'horizontal');
subplot(1, 2, 2);
imshow(matlab_edge_out);
title("matlab Sobel");

fprintf("自行Sobel与matlab实现图像差值绝对值之和%d\n", sum(sum(abs(double(my_sobel_out)-matlab_edge_out))));





toc

function output_image = my_Gauss_filter(noisy_image, kernal)
    % 检查kernal size
    kernal_size = size(kernal);
    kernal_row = kernal_size(1);
    kernal_col = kernal_size(2);
    if mod(kernal_row, 2)==0 || mod(kernal_col, 2)==0
        throw("输入核size需为奇数");
    end

    kernal_a = floor(kernal_row/2.0);
    kernal_b = floor(kernal_col/2.0);

    noisy_image = double(noisy_image);
    noisy_image = noisy_image/255;
    
    img_shape = size(noisy_image);
    img_row = img_shape(1);
    img_col = img_shape(2);
    
    % 先获得padded image
    padded_img = zeros(img_row+kernal_a*2, img_col+kernal_b*2);
    padded_img(kernal_a+1:kernal_a+img_row, kernal_b+1:kernal_b+img_col) = noisy_image;

    output_image = zeros(img_row, img_col);
    
    kernal = reshape(kernal, [], 1);
    for i=1:img_row
        for j=1:img_col
            value = reshape(padded_img(i:i+2*kernal_a, j:j+2*kernal_b), 1, [])*kernal;
            output_image(i, j) = value;
        end
    end
    output_image(output_image>1) = 1;
    output_image = uint8(output_image*255);

end

function output_image = my_Middle_filter(noisy_image, kernal) 
    % 检查kernal size
    kernal_size = size(kernal);
    kernal_row = kernal_size(1);
    kernal_col = kernal_size(2);
    if mod(kernal_row, 2)==0 || mod(kernal_col, 2)==0
        throw("输入核size需为奇数");
    end
    
    kernal_a = floor(kernal_row/2.0);
    kernal_b = floor(kernal_col/2.0);

    noisy_image = double(noisy_image);
    noisy_image = noisy_image/255;
    
    img_shape = size(noisy_image);
    img_row = img_shape(1);
    img_col = img_shape(2);
    
    % 先获得padded image
    padded_img = zeros(img_row+kernal_a*2, img_col+kernal_b*2);
    padded_img(kernal_a+1:kernal_a+img_row, kernal_b+1:kernal_b+img_col) = noisy_image;

    output_image = zeros(img_row, img_col);
    
    for i=1:img_row
        for j=1:img_col
            value = median(reshape(padded_img(i:i+2*kernal_a, j:j+2*kernal_b), 1, []));
            output_image(i, j) = value;
        end
    end
    output_image(output_image>1) = 1;
    output_image = uint8(output_image*255);

end