function save_tiff_sequence(saveDirectory, tiffStack)
%   save_tiff_sequence(tiffDirectory, tiffStack)
%
%   Saves a 3D image stack into a sequence of .tif images in a specified
%   folder
%
% Contributions and Changelog accessed via a private git repository:
% https://github.com/philipwijesinghe/widefield-lsm.git
% philip.wijesinghe@gmail.com
%
% Copyright (c) 2019 Philip Wijesinghe@University of St Andrews (pw64@st-andrews.ac.uk)
% 

% Overwrite all files
if exist(saveDirectory,'Dir')
    %     io.cmd_rmdir(saveDirectory);
else
    mkdir(saveDirectory);
end

% Save sequence
for i_ = 1:size(tiffStack,3)
    imwrite(tiffStack(:,:,i_), fullfile(saveDirectory, sprintf('img_%0.8i.tif',i_)));
end

end

