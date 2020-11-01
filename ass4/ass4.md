# 相机标定与单应矩阵计算作业报告

开头吐槽一句, 除非几乎不踩坑, 不然基本做不到6-8小时做完.

## 相机标定

首先是代码, 我分成两个部分, 一个用于获得点(uv和对应xyz), 
一个用于进行计算标定矩阵C和分解K, R, t. 其中的数据通过
matlab的内置函数save和load来进行串联.

### 完整代码
首先是获得点的代码, 这里我使用了27个点进行标定. 

由于只有stereo2012d这张图能看到所有的27个点, 
所以只能用这张图片.

其次是由于三维XYZ点的顺序在代码中是硬编码的,
所以二维点的点击顺序也是固定的.
```matlab
% 获得dlt用到的二维点和三维点

im = imread("Assignment-4-Material/stereo2012d.jpg");
imshow(im);

% 二维点点击顺序如下
%             |y
%             |         
%             |   16   17   18
%       25    | 
%             |   13   14   15 
%    26  22   | 
%             |   10   11   12
%  27  23  19 |______________________x
%             /   
%    24  20  /    1   2    3
%           /     
%      21  /    4    5    6
%         /      
%        /    7    8    9
%       / 
%      /  
%     /   
%    /z   

pnt2d = ginput(27);

pnt3d = zeros(27, 3);
cnt = 1;
square_len = 70;
for z=1:3
    for x=1:3
        pnt_x = x*square_len;
        pnt_y = 0;
        pnt_z = z*square_len;
        pnt3d(cnt, :) = [pnt_x, pnt_y, pnt_z];
        cnt = cnt+1;
    end
end

for y=1:3
    for x=1:3
        pnt_x = x*square_len;
        pnt_y = y*square_len;
        pnt_z = 0;
        pnt3d(cnt, :) = [pnt_x, pnt_y, pnt_z];
        cnt = cnt+1;
    end
end

for y=1:3
    for z=1:3
        pnt_x = 0;
        pnt_y = y*square_len;
        pnt_z = z*square_len;
        pnt3d(cnt, :) = [pnt_x, pnt_y, pnt_z];
        cnt = cnt+1;
    end
end

save("cali_pnts.mat", "pnt2d", "pnt3d");
```

然后是计算部分的代码
```matlab
im = imread("Assignment-4-Material/stereo2012d.jpg");
rws = size(im, 1);
load("cali_pnts.mat");

num_of_pnts = size(pnt2d, 1);
for cnt=1:num_of_pnts
    pnt2d(cnt, 1) = rws-pnt2d(cnt, 1);
end

C = calibrate(im, pnt3d, pnt2d)
C = [C; 1];
C = reshape(C, [3, 4]);
[K, R, t] = vgg_KR_from_P(C, 0);


function C = calibrate(im, XYZ, uv)
    % 检查三维点二维点维数
    if size(XYZ, 2) ~= 3 
        throw("三维点第二个维度不为3");
    end
    if size(uv, 2) ~= 2 
        throw("二维点第二个维度不为3");
    end

    %  先检查点数目对不对的上
    if size(uv, 1) ~= size(XYZ, 1)
        throw("三维点和二维点维度不一致");
    end
    
    num_of_pnts = size(uv, 1);
    A = zeros(num_of_pnts*2, 11);
    B = zeros(num_of_pnts*2, 1);
    for pnt_cnt=1:num_of_pnts
        pnt2d = uv(pnt_cnt, :);
        pnt3d = XYZ(pnt_cnt, :);

        X = pnt3d(1);
        Y = pnt3d(2);
        Z = pnt3d(3);
        u = pnt2d(1);
        v = pnt2d(2);
        A(2*pnt_cnt-1, :) = [X, Y, Z, 1, 0, 0, 0, 0, -u*X, -u*Y, -u*Z, ];
        A(2*pnt_cnt, :) = [0, 0, 0, 0, X, Y, Z, 1, -v*X, -v*Y, -v*Z, ];
        % 设m34 = 1
        B(2*pnt_cnt-1, :) = [u, ];
        B(2*pnt_cnt, :) = [v, ];
    end
    % 最小二乘法
    C = ((A'*A)^(-1))*(A')*B;

    % 以下是在尝试如果不引入m34=1的约束
    % 来求解LA=0
    % size(pinv(A))
    % size(B)
    % C = pinv(A)*B;

    % size(A)
    % A = A'*A;
    % size(A) 
    % size(B)
    % rank(A)
    % C=null(A, 'r');
    % size(B)
    % C = A\B;
    % size(C)
    % rank(A)
end
```

### 展示图像
![Image 1](./pic/1.JPG)

### 计算得到的C

![Image 2](./pic/2.JPG)

这个踩了好多坑.

首先是数学上的问题. 标定矩阵计算最后得到的是一个齐次线性方程, 即Ax=0的形式.
当时直接A\B求解只能得到0解, 或者自己构造最小二乘用到的方阵,
哪怕秩小于未知数个数还是0解, 用null获得通解也是获得一个12x0的空矩阵.

![Image 4](./pic/4.JPG)


于是去了解如何使用matlab如何求解线性方程上.
通过查找 [matlab的文档](https://ww2.mathworks.cn/help/matlab/math/systems-of-linear-equations.html)可以知道如果直接对于Ax=B形式的方程使用x=A\B
求解, 其是会去自适应选择求解方法的.
![Image 3](./pic/3.JPG)


但是知道咋用也求不出C. 
于是只能滚去查dlt标定的具体方法. 粗略看了这篇论文[A Four-step Camera Calibration Procedure with Implicit Image Correction](http://www.vision.caltech.edu/bouguetj/calib_doc/papers/heikkila97.pdf)之后, 对于dlt认识加深许多.

首先是使用最小二乘法求解形如La=0的齐次线性方程组本身就存在直接得到平凡解, 此处为a11,..a34=0的问题.

于是此时是需要再添加约束的(原文是normalization). 最初提出DLT标定的Abdel-Aziz和Karara使用的是将a34=1, 我后面实现也是将它设为了1.
a34的真实值应该与相机的在世界坐标系中的z坐标相关, 若相机的位姿实际值很接近0, 就不能这样做了. 此时可以通过旋转矩阵的特性引入a31^2+a32^2+a33^2=1的约束.

由于C实际上无物理意义, 之后需要对C再进行RQ分解得到焦距, 主点等信息.

### 分解结果

以下是分解得到的K, R, t

![Image 5](./pic/5.JPG)

### 回答问题

#### 相机焦距

由分解结果的K可得, x方向焦距为98.4689, y方向焦距为321.7337. 

#### 相机的中心在世界坐标系中的三维坐标

由分解结果的t可得, 坐标应为  [2.3900, 0.0069, 0.0005]

我觉得有两个值极其接近0应该是引入了a34=1的原因.



## 单应矩阵的计算

### 完整代码
与相机标定的类似, 也分成了两个部分的代码.

获得点的部分
```matlab
im = imread("Assignment-4-Material/Left.jpg");
imshow(im);
pnt2d_l = ginput(6);

im = imread("Assignment-4-Material/Right.jpg");
imshow(im);
pnt2d_r = ginput(6);

save("homo_pnts.mat", "pnt2d_l", "pnt2d_r");
```

计算部分
```matlab
load("homo_pnts.mat");

num_of_pnts = size(pnt2d_l, 1);

A = zeros(2*num_of_pnts, 8);
B = zeros(2*num_of_pnts, 1);

for cnt=1:num_of_pnts
    Xr = pnt2d_r(cnt, 1);
    Yr = pnt2d_r(cnt, 2);
    Xc = pnt2d_l(cnt, 1);
    Yc = pnt2d_l(cnt, 2);

    A(2*cnt-1, :) = [Xr, Yr, 1, 0, 0, 0, -Xc*Xr, -Xc*Yr];
    A(2*cnt, :) = [0, 0, 0, Xr, Yr, 1, -Xr*Yr, -Yc*Yr];
    B(2*cnt-1, :) = [Xc];
    B(2*cnt, :) = [Yc];
end

H = A\B;
H = [H; 1];
H = reshape(H, [3, 3])
```

### 点的位置

![Image 6](./pic/6.JPG)

### 计算得到的H

![Image 7](./pic/7.JPG)

