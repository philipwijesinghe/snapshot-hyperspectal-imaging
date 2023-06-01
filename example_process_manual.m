
% EXAMPLE - Manual Hyperspectral processing

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% User Inputs
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
calibration_folder = 'G:\Hyperspectral\20210212\calibration';

in_hyper = 'G:\Hyperspectral\20210212\laser_1.tif';
out_hyper = 'G:\Hyperspectral\20210212\laser_1_hyper.mat';

in_bf = 'G:\Hyperspectral\20210212\laser3-4_BF\laser3-4_BF_MMStack_Pos0.ome.tif';
out_bf = 'G:\Hyperspectral\20210212\laser3-4_BF\laser3-4_out.tif';

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% MAIN
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
H = SSHIController();

% % Calibrate if needed (needs only 3 wavelengths - pref -10,0,+10 nm)
% H.Calibrate(path_to_calibration_folder);

% Load calibration yml file
H.LoadCalibration(calibration_folder);


% HYPER
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
img = imread(in_hyper);
hypercube = H.Processor.ProcessSnapshot(img);
wavelengths = H.Processor.lambda_vector;

% Stitching/rotation parameters
S = [];
S.rot = 7.92;
S.n_x = 1;
S.n_y = 1;
S.overlap_x = 0;
S.overlap_y = 0;

H.Processor.StitchHypercube(hypercube, out_hyper, S);

% load processed data
m = matfile(out_hyper);
hypercube_out = m.hypercube;


% BF
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
img_bf = imread(in_bf);

% Stitching/rotation parameters
S = [];
S.rot = 0;
S.n_x = 1;
S.n_y = 1;
S.overlap_x = 0;
S.overlap_y = 0;
S.crop_x = 297;
S.crop_y = 383;
S.n_crop = 535;

H.Processor.StitchWidefield(img_bf, out_bf, S)

% load processed data
img_bf_out = imread(out_bf);


% VISUALISE
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
figure
imagesc(img_bf_out)
axis image

figure
imagesc(max(hypercube_out, [], 3))
axis image

% wavelengths;







