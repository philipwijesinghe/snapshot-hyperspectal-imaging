function YML = PostProcessHyperspectral(obj, folder_or_config)
% PostProcessHyperspectral  Processes hypercube sequence and
% widefield images to spatially coregistered outputs
%   Processes a single or sequence of hypercubes and widefield
%   images to spatially coregistered outputs based on a
%   processed.yml file.
%
%   YML = PostProcessHyperspectral(folder_or_config)
%   folder_or_config can be either:
%       a path to a folder that contains a
%       processed.yml file and data in the relevant
%       hyper/bf/lasing folders
%       OR
%       a config structure loaded using the
%       YML = LoadProcessedConfig(data_folder) Method
%
%   YML is a modified configuration with processing parameters

if isstruct(folder_or_config)
    YML = folder_or_config;
elseif ischar(folder_or_config)
    YML = obj.LoadProcessedConfig(folder_or_config);
end

% TODO: Init processor without calibration for postprocess
obj.LoadCalibration(YML.calibration_dir);

% pass to one of the processing methods based on yml
switch lower(YML.scantype)
    case 'single'
        obj.ProcessWidefield(YML)
    case 'widefield'
        obj.ProcessWidefield(YML)
    case 'zstack'
        obj.ProcessZStack(YML)
    case 'timelapse'
        obj.ProcessTimelapse(YML)
end
end