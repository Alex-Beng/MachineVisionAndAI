# Harris角点检测与SIFT实验报告

## 实现Harris角点检测算子
以下是完整代码。
```matlab
clear ; clc;
% 读入灰度图像
bw = imread('test.jpg');
if ndims(bw)==3
    bw = rgb2gray(bw);
end

% Harris Corner detector
sigma=2; thresh=0.1; sze=11; disp=0;
% Derivative masks
dy = [-1 0 1; -1 0 1; -1 0 1];
dx = dy'; %dx is the transpose matrix of dy
Ix = conv2(bw, dx, 'same');
Iy = conv2(bw, dy, 'same');
% Calculating the gradient of the image Ix and Iy
g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);

Ix2 = conv2(Ix.^2, g, 'same'); % Smoothed image derivatives
Iy2 = conv2(Iy.^2, g, 'same');
Ixy = conv2(Ix.*Iy, g, 'same');
% Compute the cornerness.

% 上面的Ix2 Iy2 Ixy其实是 ∑w(x,y)Ix^2 等, 即 G*(Ix^2) 等, 也是文档中的 Sx 等.
% 接着直接计算cornerness
k = 0.01;
cornerness = zeros(size(bw));

row = size(bw, 1);
col = size(bw, 2);
% 为每一像素计算响应
for x=1:row
    for y=1:col
        M = [Ix2(x, y), Ixy(x, y); Ixy(x, y), Iy2(x, y)];
        R = det(M) - k*(trace(M)^2);
        % 响应需要大于阈值
        if R > thresh
            cornerness(x, y) = R;
        end
    end
end

% fprintf("%d %d", max(max(cornerness)), min(min(cornerness)));
% imshow(cornerness);
% figure(2);

% Now we need to perform non-maximum suppression and threshold
% 用邻域最大值代替当前像素
% 然后保留与之前像素值一样的像素(即邻域最大值)

% 对cornerness中寻找某一像素 sze x sze邻域(ones表示全选)中第sze^2大(即最大响应)代替此像素
% 类似中值滤波, 但是选择方式不一样
max_res = ordfilt2(cornerness, sze^2, ones(sze));
% 生成掩模然后取交
cornerness = (cornerness==max_res) & cornerness;

[rws,cols] = find(cornerness); % Find row,colcoords. clf ;
imshow(bw);
hold on;
p=[cols rws];
plot(p(:,1),p(:,2),'or');
title('\bf Harris Corners')

% matlab 默认使用Harris
C = corner(bw);
figure(2);
imshow(bw);
hold on;
plot(C(:,1),C(:,2),'or');
title('\bf Matlab Harris Corners')

```
接着是结果的分析。

如下图所示，自己实现的Harris角点与Matlab内置函数corner区别主要在于
1. 边界上的点不会误判为角点
2. 某些角点位置有1个像素的偏移

![Image 1](./pic/1.JPG)

## 测试SIFT代码, 并运行图像匹配算法

```matlab
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
```
第一步是获得不同旋转和尺度的图片。使用matlab内置函数可以轻松做到。以下是结果。

![Image 2](./pic/2.JPG)


第二步是测试sift.m的特征提取效果，并可视化。

代码如下
```matlab
show_sift("./1.jpg");
show_sift("./2.jpg");
show_sift("./3.jpg");
function show_sift(file_path)
    [img, desp, pnts] = sift(file_path);
    showkeys(img, pnts);
end
```

![Image 3](./pic/3.JPG)

第三步是运行匹配算法，并画线连接匹配点。

```matlab
match("./1.jpg", './0.jpg');
match("./2.jpg", './0.jpg');
match("./3.jpg", './0.jpg');
```

![Image 4](./pic/4.JPG)
