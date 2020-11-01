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