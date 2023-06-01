function obj = UpdateSamplingVectors(obj, varargin)
% UpdateSamplingVectors('Sampling', sampling, 'Wavelengths', wavelengths,
%   'Bandwidth', bandwidth, 'WCentre', wcentre);
% UpdateSamplingVectors('Sampling', sampling, 'Wavelengths', wavelengths,
%   'WMin', wmin, 'WMax', wmax);

P = inputParser;
addParameter(P, 'Sampling', obj.sampling);
addParameter(P, 'Wavelengths', obj.wavelengths);
addParameter(P, 'Bandwidth', 0);
addParameter(P, 'WCentre', 0);
addParameter(P, 'WMin', 0);
addParameter(P, 'WMax', 0);
parse(P, varargin{:});
obj.sampling = P.Results.Sampling;
obj.wavelengths = P.Results.Wavelengths;
% Generate wavelength vector
if P.Results.WCentre && P.Results.Bandwidth
    obj.lambda_vector = linspace(...
        P.Results.WCentre - P.Results.Bandwidth/2, ...
        P.Results.WCentre + P.Results.Bandwidth/2, ...
        obj.wavelengths) * 1e-9;
elseif P.Results.WMin && P.Results.WMax
    obj.lambda_vector = linspace(...
        P.Results.WMin, ...
        P.Results.WMax, ...
        obj.wavelengths) * 1e-9;
elseif P.Results.WCentre || P.Results.Bandwidth || P.Results.WMin || P.Results.WMax
    fprintf('Please specify either Bandwidth and WCentre OR WMin and WMax\n')
end
end