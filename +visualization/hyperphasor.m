function [G, S, Irgb] = hyperphasor(hypercube, wavelengths, varargin)

hypercube = double(hypercube);

M = double(max(hypercube, [], 3));

% hypercube = medfilt3(hypercube, [5, 5, 1]);
% hypercube = imboxfilt3(hypercube, [3, 3, 1]);

% M = double(max(hypercube, [], 3));

hyper_size = size(hypercube);

n = 1;
w = 2 * pi; % * hyper_size(3);
dl = wavelengths(end) - wavelengths(1);

wavecube = repmat(permute(wavelengths(:), [3, 2, 1]), [hyper_size(1), hyper_size(2), 1]);

% N = sum(hypercube .* dl, 3);

% G = sum(hypercube .* cos(n * w * wavecube) * dl, 3) ./ N;
%
% S = sum(hypercube .* sin(n * w * wavecube) * dl, 3) ./ N;

N = sum(hypercube, 3);

% G = sum(hypercube .* cos(n * w * wavecube / dl), 3) ./ N;

% S = sum(hypercube .* sin(n * w * wavecube / dl), 3) ./ N;

C = sum(hypercube .* exp(1i * n * w * wavecube / dl), 3) ./ N;

% C = G + 1i * S;
C = C .* exp(-1i * pi);
G = real(C);
S = imag(C);


%% Averaging
if nargin > 2 && varargin{1} ~= 0
    fit_size = varargin{1};

    amplitude = abs(C);
    phasor_angle = angle(C);
    weight = M - min(M(:));
    % weight = weight - imgaussfilt(weight, fit_size);

    amplitude_w = imgaussfilt(amplitude, fit_size);

    weighted_angle = weight .* exp(1i * phasor_angle);
    rC = imgaussfilt(real(weighted_angle), fit_size);
    iC = imgaussfilt(imag(weighted_angle), fit_size);
    weighted_angle = complex(rC, iC);

    C = weighted_angle;
    % C = C * exp(-1i * pi);

    C_w = amplitude_w .* exp(1i * angle(C));
    G = real(C_w);
    S = imag(C_w);
end

%%
% cmap = jet(256);
cmap = visualization.pmkmp(256, 'CubicL');
% cmap = flip(cmap, 1);
% cmap = visualization.cbrewer.cbrewer('div', 'Spectral', 256);
I = uint8(round((angle(C) + pi) / (2 * pi) * 255));  % [0, 255]
% I = uint8(round((mod(angle(C), 2*pi)) / (2 * pi) * 255));  % [0, 255]
% M = double(max(hypercube, [], 3));
% M = abs(C);
% Mbg = imgaussfilt(M,'FilterSize',55);
% M = M - Mbg;
%

M = M - min(M(:));
M = M ./ max(M(:));
M(M<0.01) = 0.01;

M = M - min(M(:));
M = M ./ max(M(:));
M = M.^(1/2);
% Irgb = ind2rgb(I, cmap) .* M;
Irgb = ind2rgb(I, cmap);

Ihsv = rgb2hsv(Irgb);
Ihsv(:, :, 3) = Ihsv(:, :, 3) .* M;
Irgb = hsv2rgb(Ihsv);

end

