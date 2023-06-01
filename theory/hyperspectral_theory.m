%%  hyperspectral_theory.m
%   Design of a shapshot hyperspectral imager (SHI) parameters
%
%   Description:
%       The hyperspectral imager comprises a microlens array (MRA) that
%       integrates an image plane into a multispot array. This array is
%       imaged through a diffraction grating spreading the sparse spot
%       array into a series of lines. The spectral range, spread,
%       bandwidth, field of view, spatial and spectral resolution are
%       defined by the MRA pitch, the angle of the diffraction grating and
%       the diffraction grating period.


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   shi parameters
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% meters, seconds

% General shi parameters:
% Wavelength
shi.wavelength = 670e-9;

% For the MLA, let the:
% (SUSS Microoptics, 18-00079)
% Spacing between the microlens spots
mla.pitch = 30e-6;
% Numerical aperture of the microlens
mla.NA = 0.16;

% Thus, 
% The size of the spot at focus
mla.spotSize =  0.61 * shi.wavelength / mla.NA;
% The minimal angle between the diffraction grating and the array vector is
% mla.angle = 2 * asin(mla.spotSize / (2 * mla.pitch));
% mla.angle = atan(1 / (2 * sqrt(3) + 1));
mla.angle = atan(sqrt(3) / 5);
% The number of resolvable spots for a hexagonal lattice is
% mla.nSpotsPerSpectrum = sqrt(3) / 2 * (mla.pitch / mla.spotSize)^2;
mla.nSpotsPerSpectrum = sqrt(19) * mla.pitch / mla.spotSize;

% For the Diffraction Grating (DG), let the:
% (Thorlabs GR25-0608 grating)
% The dispersion of the grating (dBeta/dLambda)
% dg.dispersion = 0.657e6; %rad/m
dg.dispersion = 0.3064e6;
% dg.dispersion = 1.43e6;
% (Olympus 20x0.4NA)
% The focal length of the objective imaging the MLA
dg.fObjective = 18e-3;

% Thus,
% The maximal bandwidth is
% shi.bandwidth = mla.pitch^2 / (mla.spotSize * dg.fObjective) * dg.dispersion^-1;
shi.bandwidth = sqrt(19) * mla.pitch / dg.fObjective * dg.dispersion^-1;
% the spectral resolution is
shi.spectralResolution = shi.bandwidth/mla.nSpotsPerSpectrum;

mla
shi




% 
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% %   Verification
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% fname530 = 'calibration_results/191014_Laser_hyperspectral_530.tif';
% 
% im530 = double(imread(fname530));
% 
% figure;
% imagesc(im530);
% colormap(gray(256));
% axis image
% 
% 
% % Manual measure
% im.pitch = sqrt(315^2+224^2)/5; %px
% im.spotSize = 6; %px
% % im.angle = atan(15/136); %rad
% % im.angle = atan(1 / (2 * sqrt(3) + 1));
% im.angle = atan(sqrt(3) / 5);
% 
% % thus
% % im.nSpotsPerSpectrum = sqrt(3)/2*(im.pitch/im.spotSize)^2;
% % im.nSpotsPerSpectrum = 2.5 * im.pitch * cos(im.angle) / im.spotSize;
% im.nSpotsPerSpectrum = sqrt(19) * im.pitch / im.spotSize;
% 
% % but, in this orientation
% % the distance between laterally overlaping points 
% im.pitchOverlap = 330; %px
% % thus
% im.nSpotsPerSpectrumActual = im.pitchOverlap/im.spotSize;
% 
% % so if we want a bandwidth of 
% % desired.bandwidth = 40e-9;
% % desired.bandwidth = 61e-9; % for a 300 grating 
% % desired.bandwidth = 31e-9; % for a 600 grating 
% desired.bandwidth = 23e-9; 
% % the best case
% im.spectralResolution = desired.bandwidth/im.nSpotsPerSpectrumActual;
% 
% 
% % Camera properties:
% cam.size = 2048;
% % thus, if we want to Nyquist sample the spectral resolution:
% % cam.maxSpotsPerFOV = cam.size / (2*im.nSpotsPerSpectrumActual);
% cam.maxSpotsPerFOV = cam.size / (im.pitch/(im.spotSize/2));
% % so for a desired FOV
% desired.FOV = 100e-6;
% % the best case spatial resolution is
% im.spatialResolution = desired.FOV / cam.maxSpotsPerFOV;
% 
% 
% % Summary
% fprintf('Bandwidth %.1f nm\nSpectral res %.1f nm\nFOV %.1f um\nSpatial res %.1f um\n',...
%     desired.bandwidth*1e9, im.spectralResolution*1e9, desired.FOV*1e6, im.spatialResolution*1e6);
% 
% 
% 
% 
% 
% 
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% %   Verification of diffraction grating
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% fname530 = 'calibration_results/191014_Laser_hyperspectral_530.tif';
% fname539 = 'calibration_results/191014_Laser_hyperspectral_539.tif';
% im530 = double(imread(fname530));
% im539 = double(imread(fname539));
% 
% imRGB = cat(3,im539/max(im539(:)),zeros(size(im530)),im530/max(im530(:)));
% 
% figure;
% imagesc(imRGB);
% colormap(gray(256));
% axis image
% 
% % Number of pixels between a nm step
% % im.pixPerWavelength = sqrt(246^2+4^2)/9; %px/nm
% im.pixPerWavelength = 6.93;
% % leads to the max bandwidth in the current setup of
% im.maxCurrentBandwidth = im.pitchOverlap/im.pixPerWavelength*1e-9; %nm
% 
% % Ideally, we know that shi.bandwidth = mla.pitch^2/(mla.spotSize*dg.fObjective)*dg.dispersion^-1;
% % thus
% im.dispersion = mla.pitch^2/(mla.spotSize*dg.fObjective)/im.maxCurrentBandwidth; %rad/m
% 
% % thus, we have a dispersion of:
% im.gratingDispersionNmPerMrad = 1/(im.dispersion*1e-6);
% 
% 
% % For the desired bandwidth
% desired.dispersion = mla.pitch^2/(mla.spotSize*dg.fObjective)/desired.bandwidth; %rad/m
% desired.gratingDispersionNmPerMrad = 1/(desired.dispersion*1e-6);
% 
% % grating.dispersion = 0.3e+6;
% % grating.dispersion = 0.6e+6;
% % desired_gr.bandwidth = mla.pitch^2/(mla.spotSize*dg.fObjective)/grating.dispersion;
% 
% 
% 
% desired
% shi
% mla
% dg
% cam
% im



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Calculate real pitch and resolution
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dir_data = 'F:\Hyperspectral\20201008_hyperspectral_calibration1\data';
dir_cal = 'F:\Hyperspectral\20201008_hyperspectral_calibration1\calibration';
dir_hyper = dir([dir_data, '/*.tif']);
dir_sif = dir([dir_data, '/*.sif']);

ii = 5;
hyper_raw = imread(fullfile(dir_hyper(ii).folder, dir_hyper(ii).name));
spect_all = io.sifreadnk(fullfile(dir_sif(ii).folder, dir_sif(ii).name));
sif_plot = spect_all.imageData;
sif_plot = sif_plot - min(sif_plot(:));
sif_plot = sif_plot / max(sif_plot(:));

plot(spect_all.axisWavelength, sif_plot, ':k');

figure;
imagesc(hyper_raw);
colormap(gray(256));
axis image

% measure manually
im.pitch = 339.5/9;
im.spotSize = 3.5; % pix
im.pixPerWavelength = 6.93;

% thus
% im.nSpotsPerSpectrum = sqrt(3)/2*(im.pitch/im.spotSize)^2;
% im.nSpotsPerSpectrum = 2.5 * im.pitch * cos(im.angle) / im.spotSize;
im.nSpotsPerSpectrum = sqrt(19) * im.pitch / im.spotSize;

im.bandwidth = sqrt(19) * im.pitch / im.pixPerWavelength;

im.spectralResolution = im.bandwidth / im.nSpotsPerSpectrum;


% Camera properties:
cam.size = 2048;
% thus, if we want to Nyquist sample the spectral resolution:
% cam.maxSpotsPerFOV = cam.size / (2*im.nSpotsPerSpectrumActual);
cam.maxSpotsPerFOV = cam.size / (im.pitch/(im.spotSize/2));
% so for a desired FOV
desired.FOV = 250e-6;
% the best case spatial resolution is
im.spatialResolution = desired.FOV / cam.maxSpotsPerFOV;



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   FOV
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% 20210421

im.fov = 2048  / 1228 * 150; % um
im.hyperPixSize = im.fov / 50;  %um
im.hyperRawSize = im.fov / 2058;
im.pitch = 422/10;
im.pitchSample = im.pitch * im.hyperRawSize;
im.pitchMLA = im.pitchSample * 300 / 10 * 50 / 250;








