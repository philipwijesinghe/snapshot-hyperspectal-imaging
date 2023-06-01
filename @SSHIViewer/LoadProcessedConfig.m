function LoadProcessedConfig(obj, data_path)
try
    obj.YML = obj.Controller.LoadProcessedConfig(data_path);
catch
    fprintf('Error reading processed.yml config');
end
obj.ParseProcessedFolder();
end