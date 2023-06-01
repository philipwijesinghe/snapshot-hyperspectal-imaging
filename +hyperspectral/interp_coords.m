function img_lambda_coord = interp_coords(coords_xy, img, lambda_test, lambda0, dlambda, varargin)

import hyperspectral.gaussian_smooth

if nargin == 6
    filtw0 = varargin{1};
else
    filtw0 = 0;
end

[X, Y] = meshgrid(1:size(img, 1), 1:size(img, 2));

pix_shift = (lambda_test - lambda0)/dlambda;

coords_xy_lambda = coords_xy;
coords_xy_lambda(:, 1) = coords_xy(:, 1) + pix_shift;

if filtw0
    tmp = img;
    tmp(isnan(tmp)) = 0;
    img = gaussian_smooth(double(tmp), [filtw0, filtw0]);
end

img_lambda_coord = interp2(X, Y, double(img), coords_xy_lambda(:, 1), coords_xy_lambda(:, 2), 'nearest', 0);

end