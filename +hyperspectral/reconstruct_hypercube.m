function hypercube = reconstruct_hypercube(img, coords_xy, dlambda, lambda0, lambda_vector, spatial_sampling, varargin)
% Reconstructs a hypercube from a raw image based on calibration vectors

import hyperspectral.interp_coords2
import hyperspectral.gaussian_smooth

if nargin == 7
    filtw0 = 1;
else
    filtw0 = 0;
end

pix_dl = abs(lambda_vector(2) - lambda_vector(1)) / dlambda;
filt_size_vh = [10, pix_dl/2] / 2.68;

hypercube = zeros([spatial_sampling, spatial_sampling, length(lambda_vector)], 'uint16');

xv = linspace(1, size(img, 2), spatial_sampling);
yv = linspace(1, size(img, 1), spatial_sampling);
[X, Y] = meshgrid(xv, yv);
F = scatteredInterpolant(coords_xy(:, 1), coords_xy(:, 2), coords_xy(:, 1), 'nearest');

if filtw0
    img(isnan(img)) = 0;
    img = gaussian_smooth(double(img), [filt_size_vh(1), filt_size_vh(2)]);
end

if 0
    % Visualise all
    figure;
    imagesc(img);
    colormap(gray(256));
    axis image
    hold on
    scatter(coords_xy(:, 1), coords_xy(:, 2), 'r');
end

parfor lam_ = 1:length(lambda_vector)

    [img_lambda_coord, pix_shift] = interp_coords2(coords_xy, img, lambda_vector(lam_), lambda0, dlambda);

    % Update Interpolant values
    F1 = F;
    F1.Values = img_lambda_coord;
    
    % Interpolate onto raster grid
    hypercube(:, :, lam_) = F1(X - pix_shift, Y); % pixel correction is needed to compensate for dispersion

%     if filtw0
%         tmp = hypercube(:, :, lam_);
%         tmp(isnan(tmp)) = 0;
%         hypercube(:, :, lam_) = gaussian_smooth(tmp, [filt_size_vh(1), filt_size_vh(2)]);
%     end
end

hypercube(isnan(hypercube)) = 0;

end



% xv = linspace(1, size(img, 2), spatial_sampling);
% yv = linspace(1, size(img, 1), spatial_sampling);
% [X, Y] = meshgrid(xv, yv);
% img_hyper = zeros([spatial_sampling, spatial_sampling, length(lambda_vector)]);
% 
% for lam_ = 1:length(lambda_vector)
%     img_lambda_coord = interp_coords2(coords_xy, img, lambda_vector(lam_), lambda0, dlambda, filtw0);
%     if lam_ == 1
%         F = scatteredInterpolant(coords_xy(:, 1), coords_xy(:, 2), img_lambda_coord, 'nearest');
%     else
%         F.Values = img_lambda_coord;
%     end
%     img_hyper(:, :, lam_) = F(X, Y);
%     
%     if filtw0
%         tmp = img_hyper(:, :, lam_);
%         tmp(isnan(tmp)) = 0;
% %         img_hyper(:, :, lam_) = medfilt2(tmp, [5, 5]);
%         img_hyper(:, :, lam_) = gaussian_smooth(tmp, [filtw0, filtw0]);
%     end
% end
% 
% img_hyper(isnan(img_hyper)) = 0;

