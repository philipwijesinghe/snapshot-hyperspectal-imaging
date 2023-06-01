function StitchHypercubeSequence(obj, data_path, save_path, S, varargin)
% StitchHypercubeSequence Stitches a sequence or timelapse of
% hypercubes
%
%   StitchHypercubeSequence(data_path, save_path, S)
%   StitchHypercubeSequence(data_path, save_path, S, nthreads)
%
%   data_path path to a .mat file containing a sequence of
%   hypercubes
%
%   save_path is a folder used to output individual widefield
%   hypercubes from the timelapse sequence (in individual
%   folders)
%
%   S is a stiching config structure
%       S.n_x
%       S.n_y
%       S.overlap_x
%       S.overlap_y
%       S.rot
%
%   nthreads (optional) number of max threads for processing

% Stitching parameters
imgs_in_widefield = S.n_x * S.n_y;

m = matfile(data_path, 'Writable', false);
hc_size = size(m, 'hypercube');
n_scans = floor(hc_size(4) / imgs_in_widefield);

% Evaluate in parallel threads
% F = parallel.FevalFuture;
F(n_scans) = parallel.FevalFuture;
if nargin == 5
    max_threads = varargin{1};
else
    max_threads = 4;
end

for scan_id = 1:n_scans
    start_img = (scan_id - 1) * imgs_in_widefield + 1;
    end_img = scan_id * imgs_in_widefield;
    hypercube = m.hypercube(:, :, :, start_img:end_img);

    save_path_scan = fullfile(save_path, sprintf('scan_%04i', scan_id));
    if ~exist(save_path_scan, 'dir')
        mkdir(save_path_scan);
    end

    if scan_id ~= 1
        state = strcmpi({F.State},  'running');
        if sum(state) >= max_threads
            idx = find(state, 1);
            if ~isempty(idx)
                wait(F(idx), 'finished');
            end
        end
    end

    save_path_mat = fullfile(save_path_scan, 'hypercube_wide.mat');
    F(scan_id) = parfeval(@obj.StitchHypercube, 0, hypercube, save_path_mat, S);
    fprintf('Starting hyper stitch scan %i of %i\n', scan_id, n_scans);
end

state = strcmpi({F.State},  'running');
idx = find(state);
if ~isempty(idx)
    for i = idx
        wait(F(idx), 'finished');
    end
end
end