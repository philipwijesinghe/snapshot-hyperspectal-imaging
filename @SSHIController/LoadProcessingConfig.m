function YML = LoadProcessingConfig(obj, data_folder)
% Load processing_config.yml in the raw data folder and output
% YML config structure

% formats fileseps
data_folder = fullfile(data_folder);

% search for yaml in folder
yml_path = fullfile(data_folder , 'processing_config.yml');
if exist(yml_path, 'file')
    YML = yaml.ReadYaml(yml_path);
else
    error('Cannot find <processing_config.yml> in %s\n', data_folder);
end

% format save strings
pathparts = strsplit(data_folder, filesep);
YML.sample_name = pathparts{end};
YML.experiment_date = pathparts{end-1};
YML.data_folder = data_folder;
YML.save_folder = fullfile(...
    data_folder, '../../', ...
    sprintf('%s-Processed-%s', YML.experiment_date, datestr(now, 'yyyymmdd')), ...
    YML.sample_name ...
    );
% resolve
YML.save_folder = obj.ResolvePath(YML.save_folder);

end