function LoadCalibration(obj, cal_dir, varargin)
% LoadCalibration(calibration_directory)
% LoadCalibration(calibration_directory, 'Date', date)
%
% Loads the most recent calibration yml file from the
% calibration data directory.
% If a calibration date is given, it fill first search for a
% calibration yml matching the date.

P = inputParser;
addParameter(P, 'Date', 0);
parse(P, varargin{:});

% Search for existing calibration.yml
dir_ = [dir([cal_dir, '\*.yml'])];
if isempty(dir_)
    % No calibration found
    %TODO: generate cal?
    fprintf('No calibration file found in folder. Run Calibrate(dir) first.\n');
else
    cal_found = 0;
    if P.Results.Date ~= 0
        % Load specified config date
        for f = 1:numel(dir_)
            if strcmpi(dir_(f).name(1:end-4), ['calibration_', P.Results.Date])
                cal_found = dir_(f).name;
            end
        end
    else
        % Load most recent
        cal_found = dir_(end).name;
    end
    % Load calibration
    config_path = fullfile(cal_dir, cal_found);
    if obj.Processor == 0
        obj.Processor = SSHIProcessor(config_path);
    else
        obj.Processor.UpdateCalibration(config_path);
    end
    fprintf('Calibration loaded:\n%s\n', config_path);
end

end