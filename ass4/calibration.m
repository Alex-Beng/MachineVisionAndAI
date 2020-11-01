% CALIBRATE 
% 
% Function to perform camera calibration 
% 
% Usage: C = calibrate(im, XYZ, uv) 
% 
% Where: im - is the image of the calibration target. 
% XYZ - is a N x 3 array of XYZ coordinates 
% of the calibration target points.
% uv - is a N x 2 array of the image coordinates 
% of the calibration target points.
% C - is the 3 x 4 camera calibration matrix. 
% The variable N should be an integer greater than or equal to 6. 
% 
% This function plots the uv coordinates onto the image of 
% the calibration target. It also projects the XYZ coordinates 
% back into image coordinates using the calibration matrix 
% and plots these points too as a visual check on the accuracy of 
% the calibration process.
% Lines from the origin to the vanishing points in the X, Y and 
% Z directions are overlaid on the image. 
% The mean squared error between the positions of the uv coordinates and the projected XYZ coordinates is also reported.

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

% n = size(pnt3d, 1);
% for cnt=1:n
%     t_p3d = pnt3d(cnt, :);
%     size(t_p3d')
%     t_p2d = K*[R,t]*[t_p3d, 1]';
%     t_p2d./t_p2d(3);
%     t_p2d = t_p2d';
%     plot(t_p2d(:,1),t_p2d(:,2),'or');
% end



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
    %  最小二乘法
    C = ((A'*A)^(-1))*(A')*B;

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

