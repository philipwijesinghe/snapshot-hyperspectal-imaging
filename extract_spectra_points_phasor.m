function [locs, spectra, spectra_max, spectra_index, spectra_centre, spectra_com, phasor] = extract_spectra_points_phasor(hypercube, varargin)

p = inputParser;
addRequired(p, 'hypercube');
addParameter(p, 'ExcludePix', 10);
addParameter(p, 'MinVal', 10);
addParameter(p, 'MaxPoints', 10);
addParameter(p, 'Filt', 3);
parse(p, hypercube, varargin{:});

exclusion_pix = p.Results.ExcludePix;
min_value = p.Results.MinVal;
max_points = p.Results.MaxPoints;
filt_size = p.Results.Filt;

locs = {};
spectra = {};
spectra_com = {};

if filt_size
    [G, S, ~] = visualization.hyperphasor(hypercube, 1:size(hypercube, 3), filt_size);
else
    [G, S, ~] = visualization.hyperphasor(hypercube, 1:size(hypercube, 3));
end
I = G + 1i * S;
% I = I .* exp(1i * pi);
A = abs(I);
% A = max(hypercube, [], 3);

hyper_max = max(hypercube, [], 3);
hyper_size = size(hyper_max);
[X, Y] = meshgrid(1:hyper_size(1), 1:hyper_size(2));


n_ = 0;
while n_ < max_points
    % find next max position
    [max_val, linear_idx] = max(A(:));
    [x1, x2] = ind2sub(size(A), linear_idx);

    if max_val < min_value
        break
    end

    % retrieve coordinates and spectrum
    spectra{end+1} = squeeze(hypercube(x1, x2, :));
    locs{end+1} = [x1, x2];
    spectra_com{end+1} = (round((angle(I(x1, x2)) + pi) / (2 * pi) * 49));
    if spectra_com{end} == 0
        spectra_com{end} = 50;
    end
    phasor(n_ + 1) = I(x1, x2);

%         figure; imagesc(hyper_max)
%         hold on; scatter(x2, x1, 'r')

    % mask hyper to find next max
%     hyper_max(((X-x2).^2 + (Y-x1).^2) < exclusion_pix^2) = 0;
    A(((X-x2).^2 + (Y-x1).^2) < exclusion_pix^2) = 0;

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

