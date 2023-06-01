function save_png_sequence(saveDirectory, imgStack)
%   save_png_sequence(saveDirectory, imgStack)
%
%   Saves a 3D image stack into a sequence of .png images in a specified
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
    io.cmd_rmdir(saveDirectory);
end
mkdir(saveDirectory);

imgStack = uint8(imgStack);

% Save sequence
for i_ = 1:size(imgStack,3)
    imwrite(imgStack(:,:,i_), fullfile(saveDirectory, sprintf('img_%0.8i.png',i_)));
end

end

