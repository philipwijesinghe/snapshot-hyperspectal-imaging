function ProcessTimelapse(obj, YML)
% Process data organised as
%   -> <YYYYMMDD> /
%       -> <SampleName>
%           -> processing_config.yml
%           -> <Hyper> /
%               -> img_0_00001.tif
%               -> img_0_00002.tif
%               -> ...
%               -> img_0_00XXX.tif
%           -> <bf> /
%               -> scan_0001_<datetime> /
%                   -> img_000001.tif
%                   -> img_000002.tif
%                   -> ...
%                   -> img_00XXXX.tif
%               -> scan_0002_<datetime> /
%               -> ...
%               -> scan_XXXX_<datetime> /
%           -> <lasing> /
%               -> scan_0001_<datetime> /
%                   -> img_000001.tif
%                   -> img_000002.tif
%                   -> ...
%                   -> img_00XXXX.tif
%               -> scan_0002_<datetime> /
%               -> ...
%               -> scan_XXXX_<datetime> /
%
%
% Each snapshot image is processed to a hypercube sequence
%
% Save data is organised as
%   -> <YYYYMMDD>-Processed-<YYYYMMDD> /
%       -> <SampleName>
%           -> hyper
%               -> processed.yml
%               -> hypercube_sequence.mat
%
% This function post-processes the hyper sequence to hyper widefield, and
% bf and lasing folders into corresponding widefield images
%   -> <YYYYMMDD>-Processed-<YYYYMMDD> /
%       -> <SampleName>
%           -> hyper
%               -> scan_0001
%                   -> hypercube_sequence.mat
%               -> scan_0002
%                   -> hypercube_sequence.mat
%               -> scan_XXXX
%                   -> hypercube_sequence.mat
%           -> <bf> /
%               -> scan_0001_<datetime> /
%                   -> bf.tif
%               -> scan_0002_<datetime> /
%               -> ...
%               -> scan_XXXX_<datetime> /
%           -> <lasing> /
%               -> scan_0001_<datetime> /
%                   -> lasing.tif
%               -> scan_0002_<datetime> /
%               -> ...
%               -> scan_XXXX_<datetime> /
%

% Post-Process hypercube
in_path = fullfile(YML.save_folder, YML.directories.hyper, 'hypercube_sequence.mat');
out_path = fullfile(YML.save_folder, YML.directories.hyper);
obj.Processor.StitchHypercubeSequence(in_path, out_path, YML.stitch.hyper);

if ~isempty(YML.directories.bf)
    in_bf = fullfile(YML.data_folder, YML.directories.bf);
    out_bf = fullfile(YML.save_folder, YML.directories.bf);
    obj.Processor.StitchWidefieldSequence(in_bf, out_bf, YML.stitch.bf);
end

if ~isempty(YML.directories.lasing)
    in_bf = fullfile(YML.data_folder, YML.directories.lasing);
    out_bf = fullfile(YML.save_folder, YML.directories.lasing);
    obj.Processor.StitchWidefieldSequence(in_bf, out_bf, YML.stitch.bf);
end
end