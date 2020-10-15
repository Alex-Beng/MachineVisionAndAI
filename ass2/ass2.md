# 图像去噪与滤波作业结果、分析和描述

## 第零步

```matlab
clear ; clc;
```
用于清空工作空间的内容以及命令窗口的内容。

## 第一步

```matlab

% 获得灰度图(原图)
raw_img = imread('big.JPG');
resize_img = imresize(raw_img, [512, 512]);
gray_img = rgb2gray(resize_img);
subplot(3,3,1);
imshow(gray_img);
title('原始图像');

```
这一步没有遇到什么问题，直接使用matlab提供的接口。

因为我用的图像本来就是8位彩色图像，所以没有进行转换。

运行结果

![Image 1](./pic/1.JPG)

## 第二步

```matlab
gaus_img = imnoise(gray_img,'gaussian', 0, (10/255)^2);
subplot(3,3,2);
imshow(gaus_img);
title('高斯噪声');

salt_img = imnoise(gray_img,'salt & pepper', 0.1);
subplot(3,3,3);
imshow(salt_img);
title('椒盐噪声');
```
也是直接使用matlab的接口。
但是需要注意由于imnoise中是先将图像映射到[0,1]区间后进行滤波的。
故需要对X~N(0, 10)也缩小255倍，得到X/255~N(0, (10/255)^2)。
最终的输入方差也应变为(10/255)^2。而不是10^2。

![Image 2](./pic/2.JPG)


## 第三步

```matlab
% 代码较多只给出核心代码
padded_img = zeros(img_row+kernal_a*2, img_col+kernal_b*2);
padded_img(kernal_a+1:kernal_a+img_row, kernal_b+1:kernal_b+img_col) = noisy_image;

for i=1:img_row
    for j=1:img_col
        value = reshape(padded_img(i:i+2*kernal_a, j:j+2*kernal_b), 1, [])*kernal;
        output_image(i, j) = value;
    end
end

% matlab滤波代码
kernal = fspecial('gaussian', 9); 
matlab_filter_out = imfilter(kernal, gaus_img);
```
自行滤波的过程分两步：
1. 按核大小拓展原图，使用0来填充。
2. 按原图行列数遍历，通过变成向量相乘来计算滤波后的像素值。

滤波效果图如下。
![Image 3](./pic/3.JPG)

同时，我将所有自己实现的滤波与matlab实现得到的图像进行相减、取绝对值后求图像的和。
发现都为0。说明**自己实现的滤波效果与matlab的实现一致**。

![Image 4](./pic/4.JPG)

从上图中也能看出，使用默认标准差（0.5）的9x9高斯核对添加高斯噪声和椒盐噪声的图像
得到的信噪比分别为67.12和38.54。

接着比较不同标准差下的信噪比。

可以看到，对于高斯噪声，SNR随着滤波器标准差增加先增后减，即噪声先减少后增加。
对于椒盐噪声，SNR也是先增后减。但是其噪声增加的不会像高斯噪声滤波后那样快。

![Image 5](./pic/5.JPG)

## 第四步

```matlab
% 代码较多也只给出核心代码
padded_img = zeros(img_row+kernal_a*2, img_col+kernal_b*2);
padded_img(kernal_a+1:kernal_a+img_row, kernal_b+1:kernal_b+img_col) = noisy_image;

output_image = zeros(img_row, img_col);

for i=1:img_row
  for j=1:img_col
      value = median(reshape(padded_img(i:i+2*kernal_a, j:j+2*kernal_b), 1, []));
      output_image(i, j) = value;
  end
end

```

代码实现与高斯滤波实现基本一样，只是滤波值的获得变成使用median获得而不是向量相乘获得。

如下图，左边列为高斯噪声中值滤波结果，右边列为椒盐噪声中值滤波结果。

![Image 6](./pic/6.JPG)

显然，相比高斯滤波，中值滤波更适合去除椒盐噪声。因为中值滤波是将领域中的中值作为新的像素值，这样，除非领域几乎都是椒盐噪声（要么为255要么为0），否则噪声几乎是不可能被作为新的像素值的。

## 第五步

```matlab
% 复用了高斯滤波的代码
kernal = [1,2,1; 0,0,0; -1,-2,-1];
my_sobel_out = my_Gauss_filter(gray_img, kernal);

% matlab实现
matlab_edge_out = edge(gray_img, 'sobel');
```
因为edge默认使用的是垂直方向的Sobel核，所以这里我也是使用的垂直方向的。

经过分析，matlab的edge输出为二值图，即经过了阈值后的处理。
经过查找文档，无论时候设置阈值，edge函数都会自动或使用用户设定的阈值对图形进行阈值化处理。

而自行实现的Sobel显然不会进行阈值化处理，故matlab的处理图会显得比自己处理的要清晰明亮的多。

![Image 7](./pic/7.JPG)
