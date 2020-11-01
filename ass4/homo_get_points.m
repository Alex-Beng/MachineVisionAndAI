im = imread("Assignment-4-Material/Left.jpg");
imshow(im);
pnt2d_l = ginput(6);

im = imread("Assignment-4-Material/Right.jpg");
imshow(im);
pnt2d_r = ginput(6);

save("homo_pnts.mat", "pnt2d_l", "pnt2d_r");
