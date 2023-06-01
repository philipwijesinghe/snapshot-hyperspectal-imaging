function [basis_vector, x0, dlambda, lambda0] = calibrate_hyperspectral(cal_dir)


% Load all images
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
img_files = dir(strcat(cal_dir, '\*.tif'));
img = {};
for i_ =  1:numel(img_files)
    img{end+1} = imread(fullfile(img_files(i_).folder, img_files(i_).name));
end
img_stack = cat(3, img{:});
img_stack = img_stack(1:end-1,1:end-1,:);


% Obtain basis vectors
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
basis_in = {};
waitfor(msgbox('Image will pop up. Select two points far away from each other along a unique vector/line and count the number of points in between including the selection.'));
happy = 0;
while ~happy
    imgcrop = round(2048/4);
    fh = figure('Position', [100, 100, 900, 900]);
    imagesc(imgcrop+(1:1024), imgcrop+(1:1024), img_stack(imgcrop+(1:1024),imgcrop+(1:1024),1)); % 669.071106502805
    title('Select two points along a unique vector, press Enter when done');
    %     [xi,yi] = getpts(fh);
    [xi,yi] = ginput(2);
    close(fh);
    xn = inputdlg('How many points between the selection (inclusive)?');
    
    xv = (xi(2)-xi(1))/(str2double(xn{1})-1);
    yv = (yi(2)-yi(1))/(str2double(xn{1})-1);
    
    answer = questdlg(sprintf('Vector is: %.2f, %.2f. OK?', [xv, yv]), ...
        '', ...
        'yes', 'no', 'yes');
    
    if strcmp(answer, 'yes')
        happy = 1;
    end
end

basis_in{end+1} = [xv, yv];

waitfor(msgbox('Repeat with a new independent vector'));
happy = 0;
while ~happy
    imgcrop = round(2048/4);
    fh = figure('Position', [100, 100, 900, 900]);
    imagesc(imgcrop+(1:1024), imgcrop+(1:1024), img_stack(imgcrop+(1:1024),imgcrop+(1:1024),1)); % 669.071106502805
    title('Select two points along a unique vector, press Enter when done');
    %     [xi,yi] = getpts(fh);
    [xi,yi] = ginput(2);
    close(fh);
    xn = inputdlg('How many points between the selection (inclusive)?');
    
    xv = (xi(2)-xi(1))/(str2double(xn{1})-1);
    yv = (yi(2)-yi(1))/(str2double(xn{1})-1);
    
    answer = questdlg(sprintf('Vector is: %.2f, %.2f. OK?', [xv, yv]), ...
        '', ...
        'yes', 'no', 'yes');
    
    if strcmp(answer, 'yes')
        happy = 1;
    end
end

basis_in{end+1} = [xv, yv];

basis_vector = [basis_in{1}; basis_in{2}];

x0 = [1024, 1024];


% Pinhole coordinates
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
basis_xy = basis_vector(1:2, :);

% pinhole coordinates
img_width = 2048;
coord_max_n = 50;
[m, n] = meshgrid(-coord_max_n:coord_max_n, -coord_max_n:coord_max_n);
n = n(:);
m = m(:);
coords_xy = [n, m] * basis_xy;

% filter out of image rage coords
coords_xy = coords_xy(all((abs(coords_xy)<img_width/2)'), :);
% coords_xy = fliplr(coords_xy); % matlab is dumb

% offset by centroid
coords_xy(:, 1) = coords_xy(:, 1) + x0(1);
coords_xy(:, 2) = coords_xy(:, 2) + x0(2);



% Select centre offset
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
n_images = ceil(size(img_stack, 3));
central_img = ceil(size(img_stack, 3)/2);

waitfor(msgbox('Select a single coordinate point and then the closest point in the image'));

imgsize = 256;
imgcrop = round(2048/2 - 512/2);
fh = figure('Position', [100, 100, 900, 900]);
imagesc(imgcrop+(1:imgsize), imgcrop+(1:imgsize), img_stack(imgcrop+(1:imgsize),imgcrop+(1:imgsize), central_img)); % 669.071106502805
hold on
scatter(coords_xy(:,1), coords_xy(:,2), '.k');
title('Select two points');
[xi,yi] = ginput(2);
close(fh);
xv = (xi(2)-xi(1));
yv = (yi(2)-yi(1));
x0 = [1024, 1024] + [xv, yv];

% figure;
% imagesc(1:2047, 1:2047, log10(double(img_stack(:,:,central_img)))); % 669.071106502805
% hold on
% scatter(coords_xy(:,1)+xv, coords_xy(:,2)+yv, '.k');



% Pinhole coordinates
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
basis_xy = basis_vector(1:2, :);

% pinhole coordinates
img_width = 2048;
coord_max_n = 50;
[m, n] = meshgrid(-coord_max_n:coord_max_n, -coord_max_n:coord_max_n);
n = n(:);
m = m(:);
coords_xy = [n, m] * basis_xy;

% filter out of image rage coords
coords_xy = coords_xy(all((abs(coords_xy)<img_width/2)'), :);
% coords_xy = fliplr(coords_xy); % matlab is dumb

% offset by centroid
coords_xy(:, 1) = coords_xy(:, 1) + x0(1);
coords_xy(:, 2) = coords_xy(:, 2) + x0(2);



% Find dlambda
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
img_lower = central_img-1;
img_higher = central_img+1;
m = double(0.25*max(img_stack(:)))/256^2;
img_mixed = cat(3, img_stack(:,:,img_lower)/m, img_stack(:,:,central_img)/m, img_stack(:,:,img_higher)/m);

waitfor(msgbox('Select two points, first to the left and right of central green point'));

imgsize = 256;
imgcrop = round(2048/2 - imgsize/2);
fh = figure('Position', [100, 100, 900, 900]);
imagesc(imgcrop+(1:imgsize), imgcrop+(1:imgsize), img_mixed(imgcrop+(1:imgsize), imgcrop+(1:imgsize), :)); % 669.071106502805
hold on
line(x0(1)+[-imgsize, imgsize], x0(2)+[0, 0]);
scatter(coords_xy(:,1), coords_xy(:,2), '.k');
[xi,yi] = ginput(2);
close(fh);
xv = (xi(2)-xi(1));
yv = (yi(2)-yi(1));
dlambda_pix = xv;

file_lower = fullfile(img_files(img_lower).folder, img_files(img_lower).name);
file_lower = [file_lower(1:end-4), '.sif'];
file_centre = fullfile(img_files(img_lower).folder, img_files(central_img).name);
file_centre = [file_centre(1:end-4), '.sif'];
file_higher = fullfile(img_files(img_lower).folder, img_files(img_higher).name);
file_higher = [file_higher(1:end-4), '.sif'];

spec = io.sifreadnk(file_lower);
[~, ind] = max(spec.imageData);
spec_lower = spec.axisWavelength(ind);
spec = io.sifreadnk(file_centre);
[~, ind] = max(spec.imageData);
spec_centre = spec.axisWavelength(ind);
spec = io.sifreadnk(file_higher);
[~, ind] = max(spec.imageData);
spec_higher = spec.axisWavelength(ind);

dlambda = (spec_higher - spec_lower)*1e-9/dlambda_pix;
lambda0 = spec_centre*1e-9;


% OUTPUTS
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
basis_vector_p = basis_vector';
fprintf('\nCopy-Paste for manual processing:\n\n');
fprintf('basis_vector = [\n');
fprintf('%f, %f;\n %f, %f\n];\n', basis_vector_p(:));
fprintf('x0 = [%e, %e];\n', x0(:));
fprintf('dlambda = %e;\n', dlambda);
fprintf('lambda0 = %e;\n', lambda0);
fprintf('\n\n');

end

