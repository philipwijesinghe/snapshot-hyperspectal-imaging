function coords_xy = pinhole_coordinates(basis_xy, x0, varargin)
% coords_xy = pinhole_coordinates(basis_xy, x0)
% coords_xy = pinhole_coordinates(basis_xy, x0, 'ImageWidth', 2048)
%
% Generates a vector array of the pixel coordinates corresponding to the
% microlens foci on the camera at a central wavelength
%
%   basis_xy is an array of two vectors that form the basis of the
%       pupil coordinates. Rows represent each vector. First column is x
%       and second column is y (In matlab image coordinates).
%
%   x0 is an offset vector that describes the relative coordinate shift
%       from zero associated with a desired central wavelength
%
%   basis_xy and x0 are determined from main_calibrate_hyperspectral
%
%   'ImageWidth' (default: 2048) is the image size on camera in pixels
%
% Example:
%
% Contributions and Changelog accessed via a private git repository:
% https://github.com/philipwijesinghe/hyperspectral.git
% philip.wijesinghe@gmail.com
%
% Copyright (c) 2021 Philip Wijesinghe@University of St Andrews (pw64@st-andrews.ac.uk)

p = inputParser;
addParameter(p, 'ImageWidth', 2048, @isinteger);
parse(p, varargin{:});

% linearlize pinhole coordinates
img_width =  p.Results.ImageWidth;
coord_max_n = ceil(img_width/(sqrt(basis_xy(1,:)*basis_xy(1,:)')/2));
[m, n] = meshgrid(-coord_max_n:coord_max_n, -coord_max_n:coord_max_n);
n = n(:);
m = m(:);
coords_xy = [n, m] * basis_xy;

% filter out of image range coords
coords_xy = coords_xy(all((abs(coords_xy)<img_width/2)'), :);
% coords_xy = fliplr(coords_xy); % matlab can be dumb

% offset by centroid
coords_xy(:, 1) = coords_xy(:, 1) + x0(1);
coords_xy(:, 2) = coords_xy(:, 2) + x0(2);
end

