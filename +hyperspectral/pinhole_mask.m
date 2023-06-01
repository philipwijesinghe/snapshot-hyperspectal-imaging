function pinhole_img = pinhole_mask(coords_xy, X, Y, lambda_test, lambda0, dlambda, w0)

pix_shift = (lambda_test - lambda0)/dlambda;

coords_xy_lambda = coords_xy;
coords_xy_lambda(:, 1) = coords_xy(:, 1) + pix_shift;

pinhole_img = zeros([size(X, 1), size(X, 2)]);
for c_ = 1:size(coords_xy_lambda, 1)
    pinhole_img = pinhole_img ...
        + exp(-(X - coords_xy_lambda(c_, 1)).^2/w0^2) ...
        .*exp(-(Y - coords_xy_lambda(c_, 2)).^2/w0^2);
end

end