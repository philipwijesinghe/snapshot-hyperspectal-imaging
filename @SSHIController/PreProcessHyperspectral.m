function YML = PreProcessHyperspectral(obj, folder_or_config)
% PreProcessHyperspectral  Processes raw hyperspectral camera
% images.
%   Processes a single or sequence of hyperspectral raw camera
%   images into a sequence or hypercube data based on a
%   configuration loaded from a processing_config.yml file.
%
%   YML = PreProcessHyperspectral(folder_or_config)
%   folder_or_config can be either:
%       a path to a folder that contains a
%       processing_config.yml file and data in the relevant
%       hyper folder
%       OR
%       a config structure loaded using the
%       YML = LoadProcessingConfig(data_folder) Method
%
%   YML is a modified configuration with processing parameters

if isstruct(folder_or_config)
    YML = folder_or_config;
elseif ischar(folder_or_config)
    YML = obj.LoadConfiguration(folder_or_config);
end

% Make folders
% - hyper
save_dir = fullfile(YML.save_folder, YML.directories.hyper);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
% - bf
save_dir = fullfile(YML.save_folder, YML.directories.bf);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
% - lasing
save_dir = fullfile(YML.save_folder, YML.directories.lasing);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

% Process Hyper
img_list = dir(fullfile(YML.data_folder, YML.directories.hyper ,'/*.tif'));
save_path = fullfile(YML.save_folder, YML.directories.hyper, 'hypercube_sequence.mat');

% TODO: select specific locations to process, or total
% widefields
if isfield(YML, 'hyper_to_process')
    img_list = img_list(1:YML.hyper_to_process);
end

obj.Processor.ProcessHyperSequence(img_list, save_path);

% Save YML
YML.sampling = obj.Processor.sampling;
YML.wavelengths = obj.Processor.wavelengths;
YML.lambda_vector = obj.Processor.lambda_vector;
YML.filtw0 = obj.Processor.filtw0;
config_path = fullfile(YML.save_folder, 'processed.yml');
yaml.WriteYaml(config_path, YML);
end