function [img_lambda_coord, pix_shift] = interp_coords2(coords_xy, img, lambda_test, lambda0, dlambda)

% [X, Y] = meshgrid(1:size(img, 1), 1:size(img, 2));

pix_shift = (lambda_test - lambda0)/dlambda;

coords_xy_lambda = coords_xy;
coords_xy_lambda(:, 1) = coords_xy(:, 1) + pix_shift;

% img_lambda_coord = interp2(X, Y, double(img), coords_xy_lambda(:, 1), coords_xy_lambda(:, 2), 'nearest', 0);

% faster?

coords_xy_lambda = round(coords_xy_lambda);
coords_xy_lambda(coords_xy_lambda>2048) = 2048;
coords_xy_lambda(coords_xy_lambda<1) = 1;

img = double(img(:));
img_lambda_coord = img(coords_xy_lambda(:, 2)+(coords_xy_lambda(:, 1)-1)*2048);



end