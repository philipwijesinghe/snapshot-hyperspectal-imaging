function StitchWidefield(obj, img_stack, save_path, S)
% StitchWidefield Stitches a widefield sequence into a
% widefield image
%
%   StitchWidefield(img_stack, save_path, S)
%
%   img_stack is a 3D array of shape [X, Y, N] or a path to
%   a folder containing the sequence of images in .tif format
%
%   save_path is path (incl. <>.tif) where to save output
%
%   S is a stiching config structure
%       S.n_x
%       S.n_y
%       S.overlap_x
%       S.overlap_y
%       S.crop_x
%       S.crop_y
%       S.rot

if ischar(img_stack)
    img_stack = io.read_tiff_sequence(img_stack);
end

% Fix dimentions
img_stack = permute(img_stack, [2, 1, 3]);
img_stack = rot90(img_stack, 2);

% Rotation
if S.rot ~= 0
    % Rigid transform in TForm
    theta = S.rot;
    rot = [ cosd(theta) sind(theta); ...
        -sind(theta) cosd(theta)];
    tform = rigid2d(rot, [0, 0]);

    % Centres rotation about image centre
    Rin = imref2d(size(img_stack(:,:,1)));
    Rin.XWorldLimits = Rin.XWorldLimits - mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits - mean(Rin.YWorldLimits);

    %                 for ni = 1:size(img_stack, 3)
    %                     img_stack(:,:,ni) = imwarp(img_stack(:,:,ni), Rin, tform, 'OutputView', Rin);
    %                 end
    img_stack = imwarp(img_stack, Rin, tform, 'OutputView', Rin);
end

% Crop to ROI
img_stack = img_stack(...
    S.crop_y:S.crop_y+S.n_crop-1, ...
    S.crop_x:S.crop_x+S.n_crop-1, ...
    : );

img_size = size(img_stack);
img_size(3) = size(img_stack, 3);

% Overlap
if S.overlap_x ~= 0 || S.overlap_y ~= 0
    overlap_x_pix = round((S.overlap_x * img_size(2)) / 2);
    overlap_y_pix = round((S.overlap_y * img_size(1)) / 2);
    % backwards due to matlab orientation
    img_stack = img_stack(1 + overlap_y_pix:end - overlap_y_pix, 1 + overlap_x_pix:end - overlap_x_pix, :);
end

img_size = size(img_stack);
img_size(3) = size(img_stack, 3);

% Tile
if prod([S.n_x, S.n_y]) ~= 1
    img = zeros([img_size(1)*S.n_x, img_size(2)*S.n_y], class(img_stack));
    for i = 1:img_size(3)
        [row, col] = ind2sub([S.n_x, S.n_y], i);
        row = (row - 1)*img_size(1) + 1;
        col = (col - 1)*img_size(2) + 1;
        img(row:row + img_size(1) - 1, col:col + img_size(2) - 1) = img_stack(:,:,i);
    end
else
    img = img_stack;
end

if size(img, 3) == 1
    % Single image
    if ~strcmpi(save_path(end-3:end), '.tif')
       save_path = fullfile(save_path, 'bf.tif'); 
    end
    imwrite(img, save_path);
else
    % Z stack/image stack - write individual img sequences
    n_images = size(img, 3);
    for ni = 1:n_images
        imwrite(img(:,:,ni), fullfile(save_path, sprintf('img_%04i.tif', round(ni))));
    end
end


end