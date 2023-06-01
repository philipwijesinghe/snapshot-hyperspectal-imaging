function YML = LoadProcessedConfig(data_folder)
% Load processed.yml in the processed data folder and output
% YML config structure

% formats fileseps
data_folder = fullfile(data_folder);

% search for yaml in folder
yml_path = fullfile(data_folder , 'processed.yml');
if exist(yml_path, 'file')
    YML = yaml.ReadYaml(yml_path);
    YML.save_folder = data_folder; % update with current folder path
else
    error('Cannot find <processed.yml> in %s\n', data_folder);
end

% overwrite parameters using values in overwrite.yml
overwrite_path = fullfile(data_folder , 'overwrite.yml');
if exist(overwrite_path, 'file')
    YML_OVERWRITE = yaml.ReadYaml(overwrite_path);
    YML = io.combine_struct(YML, YML_OVERWRITE);
end

YML.lambda_vector = cell2mat(YML.lambda_vector);
end