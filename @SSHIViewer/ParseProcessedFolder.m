function ParseProcessedFolder(obj)
% Creates dir() objects for each existing hyper, bf and lasing
% data.

try
    % Hyper
    hyper_folder = fullfile(obj.YML.save_folder, obj.YML.directories.hyper);
    dir_timelapse = dir(fullfile(hyper_folder, 'scan*'));
    dir_single = dir(fullfile(hyper_folder, 'hypercube_wide.mat'));
    if ~isempty(dir_timelapse)
        % Timelapse
        hyper_dir = struct(dir_timelapse);
        for scan_id = 1:length(dir_timelapse)
            scan_path = fullfile(dir_timelapse(scan_id).folder, dir_timelapse(scan_id).name, 'hypercube_wide.mat');
            hyper_dir(scan_id) = dir(scan_path);
        end
    elseif ~isempty(dir_single)
        % Single
        hyper_dir = dir_single;
    end
    obj.Hyper = imageloader.HyperLoader(hyper_dir);
    
    % BF
    if ~isempty(obj.YML.directories.bf)
        bf_folder = fullfile(obj.YML.save_folder, obj.YML.directories.bf);
        bf_dir = dir(fullfile(bf_folder, '*.tif'));
        obj.BF = imageloader.TiffLoader(bf_dir);
    else
        obj.BF = imageloader.TiffLoader();
    end
    
    % Lasing
    if ~isempty(obj.YML.directories.lasing)
        lasing_folder = fullfile(obj.YML.save_folder, obj.YML.directories.lasing);
        lasing_dir = dir(fullfile(lasing_folder, '*.tif'));
        obj.Lasing = imageloader.TiffLoader(lasing_dir);
    else
        obj.Lasing = imageloader.TiffLoader();
    end
    
    obj.isParsed = 1;
catch
    fprintf('Error parsing processed folder contents\n');
    obj.isParsed = 0;
end

end