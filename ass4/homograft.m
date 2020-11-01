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