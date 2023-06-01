function ProcessHyperSequence(obj, img_list, save_path)
% ProcessHyperSequence(img_list, save_path)
%   img_list
%       is a list of images is a form of a structure returned
%       by the 'dir' function
%   save_path
%       is a path to a .mat file where to save hypercube
%
% Saves a sequence of snapshot tif images to a multidimentional
% hypercube array with dimentions [X,Y,L,S] in the save_path.

obj.isReadyForHyper();

fprintf('\nProcessing hyper sequence\n\n');
n_images = numel(img_list);

% Preallocate onto disk
m = matfile(save_path, 'Writable', true);
m.hypercube(obj.sampling, ...
    obj.sampling, ...
    obj.wavelengths, ...
    n_images) = uint16(0);

% Process sequence
if n_images == 1 % safe for single image
    fprintf('Processing %i of %i snapshots\n', 1, n_images);
    img = imread(fullfile(img_list(1).folder, img_list(1).name));
    if obj.filtw0
        m.hypercube = obj.ProcessSnapshot(img, obj.filtw0);
    else
        m.hypercube = obj.ProcessSnapshot(img);
    end
else
    for img_ = 1:n_images
        fprintf('Processing %i of %i snapshots\n', img_, n_images);
        img = imread(fullfile(img_list(img_).folder, img_list(img_).name));
        if obj.filtw0
            m.hypercube(:, :, :, img_) = obj.ProcessSnapshot(img, obj.filtw0);
        else
            m.hypercube(:, :, :, img_) = obj.ProcessSnapshot(img);
        end
    end
end

% Save parameters
m.sampling = obj.sampling;
m.wavelengths = obj.wavelengths;
m.lambda_vector = obj.lambda_vector;
m.filtw0 = obj.filtw0;

fprintf('\nProcessing image sequence - Done\n\n');
end