% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This is a reference document for interfacing with the SSHI Code -
% Single Shot Hyperspectral Imager
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Changelog:
%   - 20220131 - first version

% DO NOT RUN THIS SCRIPT AS IS - this is a collection of examples

% Description
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% There are three main Classes: SSHIController, SSHIProcessor and
% SSHIViewer (based loosely on the model-view-adapter architecture).
% The User should mostly interface with the Controller and Viewer Classes.

% The Controller Class is responsible for data management, configuration
% loading and the control of the processing chain.
% The Processor Class is reponsible solely for the processing of data.
% The Viewer Class is responsible for loading and manipulating the data for
% visualisation.


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1. Data Organisation
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% EXAMPLE DATASETS are in the TESTDATA folder (OneDrive)

% Raw hyperspectral data must be arranged in a particular folder structure
% that corresponds to the acquisition. Supported modes of acquision are:
%     'Single' - a single hyperspectral image with optional bf and lasing
%     images.
%     'Widefield' - a series of hyperspectral images with optional bf and
%     lasing images that are to be tiled together into one single widefield
%     image.
%     'Timelapse' - a series of Widefield images taken over several time
%     points.
%     'ZStack' - a series of hyperspectral images with optional bf and
%     lasing images that represents a z stack - sequence of single images
%     in depth.

% The following folder organisation must be observed:

% All Acquisitions:

% There should be a Parent folder for each set of experiments (optionally:
% <date>-<description>)
% e.g.,
%   20220131_cells / 

% Under each Parent folder, there should be an Experiment folder that
% contains data for only ONE acquisition. Multiple Experiment folders may
% be present for multiple acquisitions on the same type of sample/same day.
% e.g.,
%   20220131_cells / dish1_timelapse /
%                    dish2_zstack /

% For each Experiment, there should be a 'processing_config.yml' file
% (template in /config_templates/ folder) that contains acquisition
% properties.
% The hyperspectral, brightfield and lasing data should be located in
% respective folders with names correpsonding to those in the
% 'processing_config.yml'[directories][hyper, bf, lasing]
% e.g.,
%   20220131_cells / dish1_timelapse / processing_config.yml
%                                      hyper /
%                                      bf /
%                                      lasing /
% IMPORTANT:
% Directories for hyper, bf, lasing must correspond to the actual names in
% 'processing_config.yml'.
% If the data is not included for a particular experiment, the
% corresponding folder should be left blank.
% e.g., if no lasing  data is available, in .yml:
%   directories: 
%       hyper: hyper
%       bf: bf
%       lasing:

% The processed data will be saved automatically as:
%   <Parentfolder>-Processed-Date / <Experiment> / ...
% With identical subfolder names, and a 'processed.yml' config that will
% contain all processing parameters for reference.

% In 'processing_config.yml', the [scantype] should be set to: 
% single, widefield, zstack, or timelapse, depending on Acquisition.

% For all Acquision types:
% 'hyper' folder should contain a sequence of .tif files from the
% hyperspectral camera.

% The following should be used for individual Acquisition types:

% 'Single'
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The 'bf' and 'lasing' folders should contain a single (or sequence) of
% .tif images, which will be processed and saved individually.
% The [stitch][hyper, bf][n_x] and [n_y] should be set to 1.
% e.g.,
%   20220131_cells / dish1_timelapse / processing_config.yml
%                                      hyper /  img_0001.tif
%                                      bf /     img_0001.tif
%                                      lasing / img_0001.tif

% 'Widefield'
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The 'bf' and 'lasing' folders should contain a single sequence of
% .tif images corresponding to ONE widefield FOV.
% The [stitch][hyper, bf][n_x] and [n_y] should be set to the number of
% tiles in x and y. Other stitching parameters must be calibrated for
% manually.
% e.g.,
%   20220131_cells / dish1_timelapse / processing_config.yml
%                                      hyper /  img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif
%                                      bf /     img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif
%                                      lasing / img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif

% 'Timelapse'
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Identical to 'Widefield' but each widefield scan should have its own
% folder in the bf and lasing subfolders.
% e.g.,
%   20220131_cells / dish1_timelapse / processing_config.yml
%                                      hyper /  img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif
%                                      bf /     scan_0001 / img_0001.tif
%                                                           img_0002.tif
%                                                         ..img_000N.tif
%                                               scan_0002 / img_0001.tif
%                                                           img_0002.tif
%                                                         ..img_000N.tif
%                                               ...
%                                      lasing / scan_0001 / img_0001.tif
%                                                           img_0002.tif
%                                                         ..img_000N.tif


% 'ZStack'
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The folder structure is identical to 'Widefield' but the [stitch][hyper,
% bf][n_x] and [n_y] should be set to 1, just like in 'Single'
% e.g.,
%   20220131_cells / dish1_timelapse / processing_config.yml
%                                      hyper /  img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif
%                                      bf /     img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif
%                                      lasing / img_0001.tif
%                                               img_0002.tif
%                                             ..img_000N.tif


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2. Calibration
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% All 'processing_config.yml' must include path to a Calibration
% directory.

% The Calibration directory must contain a 'calibration_<date>.yml' file
% that may be generated using the Calibration code.

% Calibration may be performed in a folder that contains at least three raw
% hyperspectral images (.tif) and corresponding specral (.sif) files,
% corresponding to a narrow known wavelength.
% e.g.,
%   20220131 / calibration / 660.sif
%                            660.tif
%                            670.sif
%                            670.tif
%                            680.sif
%                            680.tif

% Calibration code:
H = SSHIController();
H.Calibrate(path_to_calibration_folder);

% This will open a user-interactive process and save a calibration file if
% successful.


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3. Processing
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Once data, processing_config and calibration are available, Processing
% may be performed using the Controller Class as follows:

% Initialises the Class:
H = SSHIController();

% Full processing
H.ProcessHyperspectral(path_to_data_folder);

% 3.1 Intermediate processing
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Alternatively:
% Processing may be broken down into three parts:
YML = H.LoadConfiguration(path_to_data_folder);
YML = H.PreProcessHyperspectral(YML);
YML = H.PostProcessHyperspectral(path_to_output_folder);

% Specifically:
YML = H.LoadConfiguration(path_to_data_folder);
%   - Loads the processing_config.yml into the workspace. You may examine
%   the YML structure and make modifications as needed.
%   - Also, once LoadConfiguration is called, the internal H.Processor
%   (nested Class) becomes available to the User. See Processor Methods
%   docstrings for more details.
% e.g., 
hypercube = H.Processor.ProcessSnapshot(img); % img is a matlab array, eg from imread()

YML = H.PreProcessHyperspectral(YML);
%   - Processes raw hyper images to a hypercube_sequence.mat file according
%   to the config in the YML structure.
YML = H.PreProcessHyperspectral(path_to_data_folder);
%   - Alternatively may be called with a path to the data folder with
%   processing_config.yml file
%   - The YML output is a modified YML structure with parameters from the
%   processing
%   - The path to output folder may be read from the YML as 
path_to_output_folder = YML.save_folder;

YML = H.PostProcessHyperspectral(path_to_output_folder);
%   - Processes the data according to the Acquisition type, including
%   stitching, rotation, cropping, etc. The input argument is the path to
%   the output folder from PreProcessHyperspectral Method that holds the
%   'processed.yml' and the 'hyper / hypercube_sequence.mat' folder.
%   - The YML output is a modified YML structure with parameters from the
%   processing


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 4. Viewing
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The Viewer Class enables viewing and interfacing with the processed data.
% It is initialised as follows:
V = SSHIViewer(path_to_output_folder);

% Corresponding hyper, bf, lasing images may be accessed using the Read
% Method, as follows:

% Image # from the sequence 
% (if timelapse or zstack; set to 1 if single or widefield)
frame_number = 1; 

% Read images
img_hyper = V.Hyper.Read(frame_number);
img_bf = V.BF.Read(frame_number);
img_lasing = V.Lasing.Read(frame_number);
%   - The outputs are all matlab image arrays

% The total number of frames can be read as:
n_frames = V.Hyper.n_scans;
%   - If frame_number > n_frames, then the last frame will be output.

% The relevant spectral parameters may be read from the YML configuration
% structure:
wavelengths = V.YML.lambda_vector; % in metres


% 4.1 Alignment and spatial shifts
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The images may be re-aligned by manually shifting them by a certain
% number of pixels (integers) in x and y

% This can be done globally for all scans of a certain type using the
% 'SetPixShift' Method
% e.g.,
pix_shift_vh = [-1, 3]; % pix shift [vertically, horizontally]
V.Hyper.SetPixShift(pix_shift_vh);

% This method will now read a shifted version of the image for all frames
img_hyper = V.Hyper.Read(frame_number); 


% 4.2 Region of interest
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Further, image reading may be restricted to a particular region of
% interest (ROI) for all scans using the SetROI Method as follows:

% Select ROI
roi = [];
roi.h = [0, 0.5];
roi.v = [0.5, 1];
%   - where h and v are the horizontal and vertical bounds for the ROI. The
%   coordinates are relative to the image size, thus are between 0 and 1.
%   Here, roi.h = [0, 0.5] selects the left half of the image in the
%   horizontal direction.

% Set ROI
V.SetROI(roi);

% Read images
img_hyper = V.Hyper.Read(frame_number);
img_bf = V.BF.Read(frame_number);
img_lasing = V.Lasing.Read(frame_number);
%   - The outputs will now correspond to the selected ROI.


% 4.3 Subsampling and projections (for faster visualisation)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Data in a 'Processed' folder may be subsampled to a lower resolution to
% increase the speed of visualisation (BF and Lasing ONLY)

% This is done using the optional 'LR' parameter, followed by a specified
% resolution in the vertical and horizontal directions
% e.g.,
lr_size_vh = [100, 100];
img_bf_lowres = V.BF.Read(frame_number, 'LR', lr_size_vh);

% This process generates a subsampled image ONCE, and stores it in a new
% subfolder called 'LR_<v>_<h>' where v and h are the sizes in the vertical
% and horizontal directions. 

% LR calls are slow the first time but fast for subsequent calls. 

% The LR images are generated on demand for each call. ALL images in the
% dataset may be pre-subsampled using the 'ConvertAll()' Method, with the
% appropriate argument
V.BF.ConvertAll('LR', lr_size_vh);

% Hyperspectral data in a 'Processed' folder may be similarly reduced by
% pre-calculating the MAX and SUM values of all wavelengths

% This is done using the optional 'Max' or 'Sum' arguments of 'Read'
% e.g.,
img_hyper_max = V.Hyper.Read(frame_number, 'Max');
img_hyper_sum = V.Hyper.Read(frame_number, 'Sum');

% Similarly, this process generates Projections in a separate 'Projections'
% subfolder ONCE and on demand.

% All data in the series may be pre-processed using the 'ConvertAll'
% Method. 
% IMPORTANT: Both 'Max' and 'Sum' projections are generated automatically
V.Hyper.ConvertAll('Max');


% 4.4 Save hyper stack
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% An image stack of projections (Max or Sum) may be saved with the
% 'ExportToStack' method (Hyper ONLY)
V.Hyper.ExportToStack(output_folder, 'Max');
% OR
V.Hyper.ExportToStack(output_folder, 'Sum');







