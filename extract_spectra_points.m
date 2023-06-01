function [locs, spectra, spectra_max, spectra_index, spectra_centre] = extract_spectra_points(hypercube, varargin)

p = inputParser;
addRequired(p, 'hypercube');
addParameter(p, 'ExcludePix', 10);
addParameter(p, 'MinVal', 10);
addParameter(p, 'MaxPoints', 10);
parse(p, hypercube, varargin{:});

exclusion_pix = p.Results.ExcludePix;
min_value = p.Results.MinVal;
max_points = p.Results.MaxPoints;

locs = {};
spectra = {};

hyper_max = max(hypercube, [], 3);
hyper_size = size(hyper_max);
[X, Y] = meshgrid(1:hyper_size(1), 1:hyper_size(2));


n_ = 0;
while n_ < max_points
    % find next max position
    [max_val, linear_idx] = max(hyper_max(:));
    [x1, x2] = ind2sub(size(hyper_max), linear_idx);

    if max_val < min_value
        break
    end

    % retrieve coordinates and spectrum
    spectra{end+1} = squeeze(hypercube(x1, x2, :));
    locs{end+1} = [x1, x2];

%         figure; imagesc(hyper_max)
%         hold on; scatter(x2, x1, 'r')

    % mask hyper to find next max
    hyper_max(((X-x2).^2 + (Y-x1).^2) < exclusion_pix^2) = 0;

    n_ = n_ + 1;
end
    
fprintf('Found %i points\n', n_)

if ~isempty(locs)
    locs = reshape([locs{:}], 2, n_);
end

spectra_max = zeros([numel(spectra), 1]);
spectra_index = zeros([numel(spectra), 1]);
spectra_centre = zeros([numel(spectra), 1]);
for s_ = 1:numel(spectra)
    [spectra_max(s_), spectra_index(s_)] = max(spectra{s_});
    spectra_centre(s_) = sum(double(spectra{s_}) .* (1:length(spectra{s_}))') ./ (sum(double(spectra{s_})));
end

end

