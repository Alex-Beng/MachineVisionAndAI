tic

show_sift("./1.jpg");
show_sift("./2.jpg");
show_sift("./3.jpg");

toc
function show_sift(file_path)
    [img, desp, pnts] = sift(file_path);
    showkeys(img, pnts);
end