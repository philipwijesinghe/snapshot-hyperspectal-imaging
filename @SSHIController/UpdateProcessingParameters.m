function UpdateProcessingParameters(obj, YML)
S = YML.processing;
if isfield(S, 'sampling_pix')
    obj.Processor.UpdateSamplingVectors(...
        'Sampling', S.sampling_pix);
end
if isfield(S, 'wavelengths_num')
    obj.Processor.UpdateSamplingVectors(...
        'Wavelengths', S.wavelengths_num);
end
if isfield(S, 'bandwidth_nm') && isfield(S, 'lambda_centre_nm')
    obj.Processor.UpdateSamplingVectors(...
        'Bandwidth', S.bandwidth_nm, 'WCentre', S.lambda_centre_nm);
elseif isfield(S, 'lambda_min_nm') && isfield(S, 'lambda_max_nm')
    obj.Processor.UpdateSamplingVectors(...
        'WMin', S.lambda_min_nm, 'WMax', S.lambda_max_nm);
end
if isfield(S, 'filtw0')
    obj.Processor.filtw0 = S.filtw0;
end
end