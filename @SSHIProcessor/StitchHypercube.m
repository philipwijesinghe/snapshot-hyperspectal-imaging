function StitchHypercube(obj, hypercube, save_path, S)
% StitchHypercubeDirect Stitches a hypercube sequence into
% widefield image
%
%   StitchHypercubeDirect(hypercube, save_path, S)
%
%   hypercube is a 4D array of shape [X, Y, L, N] or a path to
%   a .mat file contating the data
%
%   save_path is path where to save output file incl. <>.mat
%
%   S is a stiching config structure
%       S.n_x
%       S.n_y
%       S.overlap_x
%       S.overlap_y
%       S.rot

if ischar(hypercube)
    m = matfile(hypercube, 'Writable', false);
    hypercube = m.hypercube;
end

% Fix orientation
hypercube = permute(hypercube, [2, 1, 3, 4]);
hc_size = size(hypercube);
hc_size(4) = size(hypercube, 4);

% Rotation
if S.rot ~= 0
    % Rigid transform in TForm
    theta = S.rot;
    rot = [ cosd(theta) sind(theta); ...
        -sind(theta) cosd(theta)];
    tform = rigid2d(rot, [0, 0]);

    % Centres rotation about image centre
    Rin = imref2d(size(hypercube(:,:,1,1)));
    Rin.XWorldLimits = Rin.XWorldLimits - mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits - mean(Rin.YWorldLimits);

    %                 for ni = 1:size(hypercube, 4)
    %                     for nv = 1:size(hypercube, 3)
    %                         hypercube(:,:,nv,ni) = imwarp(hypercube(:,:,nv,ni), Rin, tform, 'OutputView', Rin);
    %                     end
    %                 end
    hypercube = imwarp(hypercube, Rin, tform, 'OutputView', Rin);
end

% Overlap
if S.overlap_x ~= 0 || S.overlap_y ~= 0
    overlap_x_pix = round((S.overlap_x * hc_size(2)) / 2);
    overlap_y_pix = round((S.overlap_y * hc_size(1)) / 2);
    % backwards due to matlab orientation
    hypercube = hypercube(1 + overlap_y_pix:end - overlap_y_pix, 1 + overlap_x_pix:end - overlap_x_pix, :, :);
end

hc_size = size(hypercube);
hc_size(4) = size(hypercube, 4);

% Stitch
if prod([S.n_x, S.n_y]) ~= 1
    tmp = zeros([hc_size(1)*S.n_x, hc_size(2)*S.n_y, hc_size(3)], 'uint16');
    for i = 1:hc_size(4)
        [row, col] = ind2sub([S.n_x, S.n_y], i);
        row = (row - 1)*hc_size(1) + 1;
        col = (col - 1)*hc_size(2) + 1;
        tmp(row:row + hc_size(1) - 1, col:col + hc_size(2) - 1, :) = hypercube(:,:,:,i);
    end
else
    % Just a single image transformed
    tmp = hypercube;
end

save_path_mat = fullfile(save_path);

s = matfile(save_path_mat, 'Writable', true);
s.hypercube = tmp;
end