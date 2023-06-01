function output = gaussian_smooth(input, g_sigma, varargin)
%% output = gaussian_smooth(input, g_sigma)
%% output = gaussian_smooth(input, g_sigma, g_size)
% Filters a 1-D, 2-D or 3-D dataset with a separable gaussian filter.
%
% Additionally corrects for edge effects, and the influence of NaN values in the
% input. If 'nanout' is specified as a function parameter, then any NaN in the
% input will also appear in the same location in the output.
%
% inputs,
%   INPUT: The 1D, 2D greyscale/color, or 3D input image with
%           data type Single or Double
%
%   G_SIGMA: n-element vector. The sigma used for the Gaussian kernel.
%
%   G_SIZE: (OPTIONAL) n-element vector. Kernel size in pixels (default: sigma*8)
%
%     'nanout'   - The result should have NaNs in the same places as the input.
%
% G_SIGMA and G_SIZE should have the same number of elements as dimensions in INPUT,
% they correspond to the size of the gaussian in each of the input dimensions.
% To smooth only in selected dimensions, set g_sigma and g_size of that dimension to
% zero. E.g., out = gaussian_smooth(in, [0.6, 0, 0.5]), smooths only in the 1st
% and 3rd dimensions.
%
% outputs,
%   OUTPUT: The gaussian filtered image
%
% Author: Lixin Chin
% First Release: 8 February 2016

p = inputParser;
% INPUT must have the same number of dimensions as 'g_sigma'
p.addRequired('input', @(x) ndims(input) == numel(g_sigma))
% g_sigma must be positive-valued
p.addRequired('g_sigma', @(x) all(x >= 0))
% Parse and validate the input arguments
p.parse(input, g_sigma);

%% Process input arguments
nanout = false;
% default g_size is 8*g_sigma in that dimension, note, this will be implicitly
% transformed to 8*g_sigma+1 later to ensure the length of the gaussian is odd
% (simplifies calculations)
g_size = ceil(8 * g_sigma);
error_str = [];
for arg = 1:nargin-2
    if ischar(varargin{arg})
        switch lower(varargin{arg})
          case 'nanout'; nanout = true; % Include original NaNs in the output.
          otherwise; error_str = evalc('disp(varargin{arg})'); break;
        end
    elseif isnumeric(varargin{arg}) && numel(varargin{arg}) == numel(g_sigma)
        g_size = varargin{arg};
    else
        error_str = evalc('disp(varargin{arg})'); break;
    end
end
if ~isempty(error_str)
    error_str = strtrim(error_str);
    error('%s: invalid input: "%s"', mfilename, error_str);
end

g_radius = ceil(g_size/2);
% logical vector, true if we should smooth in that dimension
smooth_dimen = (g_sigma ~= 0 & g_size ~= 0);

% Make the Gaussian kernels
if smooth_dimen(1)
    % Dimension 1
    x1 = -g_radius(1):g_radius(1);
    H1 = exp(-(x1.^2/(2*g_sigma(1)^2)));
    H1 = H1/sum(H1(:));
    H1 = reshape(H1, [], 1);
end

if (numel(smooth_dimen) >= 2 && smooth_dimen(2))
    % Dimension 2
    x2 = -g_radius(2):g_radius(2);
    H2 = exp(-(x2.^2/(2*g_sigma(2)^2)));
    H2 = H2/sum(H2(:));
    H2 = reshape(H2, 1, []);
end

if (numel(smooth_dimen) >= 3 && smooth_dimen(3))
    % Dimension 3
    x3 = -g_radius(3):g_radius(3);
    H3 = exp(-(x3.^2/(2*g_sigma(3)^2)));
    H3 = H3/sum(H3(:));
    H3 = reshape(H3, 1, 1, []);
end

% Find all the NaNs in the input.
n = isnan(input);
% correct for zero-padding at the edges, and for NaN in input
edge_nan_correct_matrix = ones(size(input), class(input));
% Replace NaNs with zero, both in 'a' and 'on'.
input(n) = 0;
edge_nan_correct_matrix(n) = 0;
switch (ndims(input))
  case 1
    temp = input;
    if smooth_dimen(1)
        temp = convn(temp, H1, 'same');
        edge_correct = convn(edge_nan_correct_matrix, H1, 'same');
        temp = temp ./ edge_correct;
    end
    output = temp;

  case 2
    temp = input;
    if smooth_dimen(1)
        % Smooth across the first dimension
        temp = convn(temp, H1, 'same');
        edge_correct = convn(edge_nan_correct_matrix, H1, 'same');
        temp = temp ./ edge_correct;
    end
    if smooth_dimen(2)
        % Smooth across the second dimension
        temp = convn(temp, H2, 'same');
        edge_correct = convn(edge_nan_correct_matrix, H2, 'same');
        temp = temp ./ edge_correct;
    end
    output = temp;

  case 3
    temp = input;
    if smooth_dimen(1)
        % Smooth across the first dimension
        temp = convn(temp, H1, 'same');
        edge_correct = convn(edge_nan_correct_matrix, H1, 'same');
        temp = temp ./ edge_correct;
    end
    if smooth_dimen(2)
        % Smooth across the second dimension
        temp = convn(temp, H2, 'same');
        edge_correct = convn(edge_nan_correct_matrix, H2, 'same');
        temp = temp ./ edge_correct;
    end
    if smooth_dimen(3)
        % Smooth across the third dimension
        temp = convn(temp, H3, 'same');
        edge_correct = convn(edge_nan_correct_matrix, H3, 'same');
        temp = temp ./ edge_correct;
    end
    output = temp;

  otherwise
    error('%s: INPUT has %d dimensions, should be 1, 2 or 3!', mfilename(), ...
          ndims(input));
end

% If requested, replace output values with NaNs corresponding to input.
if(nanout); output(n) = NaN; end

end
