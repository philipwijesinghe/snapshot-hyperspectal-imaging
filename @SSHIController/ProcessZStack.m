function ProcessZStack(obj, YML)
% Process data organised as
%   -> <YYYYMMDD> /
%       -> <SampleName>
%           -> processing_config.yml
%           -> <Hyper> /
%               -> img_0_00001.tif
%               -> img_0_00002.tif
%               -> ...
%               -> img_0_00XXX.tif
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
% For now we leave the stitching to the view methods*

in_path = fullfile(YML.save_folder, YML.directories.hyper, 'hypercube_sequence.mat');
out_path = fullfile(YML.save_folder, YML.directories.hyper, 'hypercube_wide.mat');
obj.Processor.StitchHypercube(in_path, out_path, YML.stitch.hyper);

if ~isempty(YML.directories.bf)
    in_bf = fullfile(YML.data_folder, YML.directories.bf);
    out_bf = fullfile(YML.save_folder, YML.directories.bf);
    obj.Processor.StitchWidefield(in_bf, out_bf, YML.stitch.bf);
end

if ~isempty(YML.directories.lasing)
    in_bf = fullfile(YML.data_folder, YML.directories.lasing);
    out_bf = fullfile(YML.save_folder, YML.directories.lasing);
    obj.Processor.StitchWidefield(in_bf, out_bf, YML.stitch.bf);
end

end


