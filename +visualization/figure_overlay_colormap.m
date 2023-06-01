function [ imageC ] = figure_overlay_colormap( imageA, cmapA, limA, imageB, cmapB, limB, varargin )
%FIGURE_OVERLAY_COLORMAP Overlays 2 image arrays with 2 colormaps
%
%   Multiplicative overlays are useful for visualising multiparameter
%   images on one colorscale.
%
%   It is particularly useful in two cases:
%       1.
%       Where the intensity of the first image (e.g., OCT) is a good 
%       approximation to the noise in the second, such that it can be used
%       to attenuate the color of the second image to emphasise regions
%       with good signal.
%       In this case a linear colormap should be used for the first image,
%       and a isoluminant for the second.
%       2.
%       Where both images show two equivalent and mostly independent
%       parameters with low complexity.
%       In this case, linear or binary colormaps should be used
%
%   For both cases, the colormaps should not overlap in their color space,
%   such that no two or more combinations of parameters produce the same
%   color. 
%      
%   Inputs:
%       imageA
%           A 2D array with values representing the intensity of the image
%       cmapA
%           A [Nx3] array colormap associated with imageA N in (1,256]; can
%           be generated by inbuilt MATLAB colormaps, e.g., cmapA =
%           gray(256);
%       limA
%           Length 2 1D array corresponding to value limits on imageA;
%           colormap colors will be from lim(1) to lim(2)
%       (Same for imageB)
%       (options:)
%       beta
%           A variable in [0,1]; (default 0); determines proportion of
%           imageB that is not multiplied by A, i.e., 
%           imageC = (1-beta)*imageA*imageB + beta*imageB
%
%   Outputs:
%       imageC
%           A 3D array of size [M,N,3]; first 2 dimensions are the image,
%           the last dimension is RGB values. Can be displayed via
%           image(imageC); size(imageC) = size(imageA);
%
%   Example Use:
%
%
%   20180226 PW
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Input validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO


% Options
if nargin==7
    beta = varargin{1};
elseif nargin>7
    error('Too many input arguments\n');
else
    beta = 0;
end

% Make sure it is in double to be sure (uint8/16 behaves differently with
% ind2rgb)
imageA = double(imageA);
imageB = double(imageB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Apply image limits and shift to 1 to 256
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageA(imageA>limA(2)) = limA(2);
imageA(imageA<limA(1)) = limA(1);
imageA = 1+size(cmapA,1)*(imageA-limA(1))/(limA(2)-limA(1));

imageB(imageB>limB(2)) = limB(2);
imageB(imageB<limB(1)) = limB(1);
imageB = 1+size(cmapB,1)*(imageB-limB(1))/(limB(2)-limB(1));

% Make sure images are of the same size
if size(imageB)~=size(imageA)
    imageB = imresize(imageB,size(imageA));
end

% Make integers
imageA = round(imageA);
imageB = round(imageB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Multiply in RGB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageArgb = ind2rgb(imageA,cmapA);
imageBrgb = ind2rgb(imageB,cmapB);

imageC = (1-beta)*imageArgb.*imageBrgb + beta*imageBrgb;

end
