function StitchWidefieldSequence(obj, data_path, save_path, S)
% StitchWidefieldSequence Stitches a sequence of widefield
% images into widefield timelapses stored in individual folders
%
%   StitchWidefieldSequence(data_path, save_path, S)
%
%   data_path is either:
%   path to folder containing a sequence of folders, each
%   containing tif image sequences corresponding to one
%   widefield scan
%   OR
%   path to a folder that contains only a tif image sequence
%   corresponding to one widefield scan
%   OR
%   is a directory structure pointing to folders containing
%   tif image sequences
%
%   save_path is the folder where the widefield tifs will be
%   saved with a name that matches the folder names in
%   data_path
%
%   S is a stiching config structure
%       S.n_x
%       S.n_y
%       S.overlap_x
%       S.overlap_y
%       S.crop_x
%       S.crop_y
%       S.rot

if ischar(data_path)
    % data_path should contain a sequence of folder names
    list_of_dirs = dir(data_path);
    list_of_dirs = list_of_dirs([list_of_dirs.isdir]);
    list_of_dirs = list_of_dirs(3:end); % get rid of '.' '..'
    if isempty(list_of_dirs)
        % Look one higher (this is a stack of tiffs)
        list_of_dirs = dir([data_path '*']);
    end
else
    % This is a data struct already
    list_of_dirs = data_path;
end

n_scans = length(list_of_dirs);

F(1:n_scans) = parallel.FevalFuture;
for scan_id = 1:n_scans
    in_dir = fullfile(list_of_dirs(scan_id).folder, list_of_dirs(scan_id).name);
    out_dir = fullfile(save_path, [list_of_dirs(scan_id).name, '.tif']);
    F(scan_id) = parfeval(@obj.StitchWidefield, 0, in_dir, out_dir, S);
    % obj.StitchWidefield(in_dir, out_dir, S);
end
wait(F);
end
