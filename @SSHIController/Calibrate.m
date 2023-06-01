function Calibrate(cal_dir)
% Calibrate(calibration_directory)
%
% Calibrate hyperspectral imager parameters using calibration
% data in the folder. Must contain same-named tif and sif
% files, sorted by wavelength.
%
% Calibration data is saved as a calibration YAML file.

try
    % Calibrate
    [basis_vector, x0, dlambda, lambda0] = hyperspectral.calibrate_hyperspectral(cal_dir);
    % Write to calibration file
    s = struct('basis_vector', basis_vector, 'x0', x0, ...
        'dlambda', dlambda, 'lambda0', lambda0);
    yaml_file = fullfile(...
        cal_dir, ...
        sprintf('calibration_%s.yml', datestr(now,'yyyymmdd'))...
        );
    yaml.WriteYaml(yaml_file, s);
    fprintf('Written calibration to:\n%s\n', yaml_file);
catch
    fprintf('Calibration failed, try again.\n');
end
end