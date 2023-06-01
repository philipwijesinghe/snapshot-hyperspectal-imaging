function obj = UpdateCalibration(obj, varargin)
%   UpdateCalibration(basis_vector, x0, dlambda, lambda0)
%   UpdateCalibration(config_path)

% Input Parser
if nargin == 2 && ...
        (ischar(varargin{1}) || isstring(varargin{1}))
    % Load configuration from YML file
    in = yaml.ReadYaml(varargin{1});
    obj.basis_vector = cell2mat(in.basis_vector(1:2, :));
    obj.x0 = cell2mat(in.x0);
    obj.dlambda = in.dlambda;
    obj.lambda0 = in.lambda0;
elseif nargin == 5
    % Load configuration directly
    P = inputParser;
    addRequired(P, 'basis_vector', ...
        @(x)size(x, 2) == 2 && size(x, 1) >= 2);
    addRequired(P, 'x0', @(x) length(x) == 2);
    addRequired(P, 'dlambda',  @(x)isnumeric(x));
    addRequired(P, 'lambda0',  @(x)isnumeric(x));
    parse(P, varargin{:});
    obj.basis_vector = P.Results.basis_vector(1:2, :);
    obj.x0 = P.Results.x0;
    obj.dlambda = P.Results.dlambda;
    obj.lambda0 = P.Results.lambda0;
else
    error(['Incorrect inputs. Must be in the form of: \n', ...
        'H = SSHIProcessor(basis_vector, x0, dlambda, lambda0);\n', ...
        'H = SSHIProcessor(config_path)'], 0);
end
% Updates basis coordinate vectors
obj.coords_xy = hyperspectral.pinhole_coordinates(obj.basis_vector, obj.x0);
end