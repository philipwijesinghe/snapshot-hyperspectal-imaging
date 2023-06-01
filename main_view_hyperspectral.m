% main_process_hyperspectral.m
%
% Hyperspectral data is processed using SingleShot Hyperspectral Imager
% (SSHI) Classes.
% 
% User requests processing using the Controller Class and visualisation
% using the Viewer Class. 
%
% Configuration for the processing is set using a YAML config file that
% should be located in the raw data folder, structured as follows:
%
%   -> <YYYYMMDD> /
%       -> <SampleName>
%           -> processing_config.yml
%           -> <Hyper> /
%               -> img_0_00001.tif
%               -> img_0_00002.tif
%               -> ...
%               -> img_0_00XXX.tif
%
% YAML (.yml) temlates are located in ./config_templates/
%
%
% Contributions and Changelog accessed via a private git repository:
% https://github.com/philipwijesinghe/hyperspectral.git
% philip.wijesinghe@gmail.com
%
% Copyright (c) 2021 Philip Wijesinghe@University of St Andrews (pw64@st-andrews.ac.uk)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% USER INPUT
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
in_folder = 'G:\Hyperspectral\20210323-Dish1Macrophage_180um_25min-Processed-20220127\Dish1_test';

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% MAIN
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% H = SSHIViewer(in_folder);
hyperviewer_timelapse(in_folder);