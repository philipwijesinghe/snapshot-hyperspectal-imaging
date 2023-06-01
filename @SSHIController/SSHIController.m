classdef SSHIController < handle
    %SSHICONTROLLER Controller Class for SnapShot Hyperspectral Imager
    %   The purpose of this Class is to serve as a Data Controller that
    %   controls the data organisation, folder partitioning, configuration
    %   files, reading and saving of hyperspectral data.
    %   The Controller Class should be capable of reading sequences of
    %   hyperspectral data, processing it using the Processor Class, and
    %   saving processed data, including configurations, into a unified
    %   file/folder structure based on experiment type.
    
    properties
        Processor  % SSHI Processor Class
    end
    
    methods
        function obj = SSHIController(varargin)
            %SSHICONTROLLER Construct an instance of this class
            %   H = SSHIController()
            %       Contructs Class. Calibration MUST be performed using
            %       <INSERT FUNCTION NAME> before processing can be done.
            %   H = SSHIController(basis_vector, x0, dlambda, lambda0)
            %   H = SSHIController(config_path)
            %       Contructs Class using explicit calibration values or a
            %       calibration file.
            
            obj.Processor = SSHIProcessor(varargin{:});
        end
        

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % CALIBRATION HANDLING
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LoadCalibration(obj, cal_dir, varargin);
        YML = LoadProcessingConfig(obj, data_folder);
        UpdateProcessingParameters(obj, YML)

        function YML = LoadConfiguration(obj, data_folder)
            % YML = PrepareConfiguration(data_folder)
            %   Loads the configuration from the data_folder and
            %   initialises the processor with the relevant parameters for
            %   processing
            
            YML = obj.LoadProcessingConfig(data_folder);
            obj.LoadCalibration(YML.calibration_dir);
            obj.UpdateProcessingParameters(YML);
        end


        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % PROCESSING
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        YML = PreProcessHyperspectral(obj, folder_or_config)
        YML = PostProcessHyperspectral(obj, folder_or_config)

        function YML = ProcessHyperspectral(obj, folder_or_config)
            % ProcessHyperspectral  Processes hyperspectral camera
            % images and widefield scans and stiches outputs
            %   Processes a single or sequence of hyperspectral raw camera
            %   images into a sequence or hypercube data based on a
            %   configuration loaded from a processing_config.yml file.
            %   Then arranges, transforms and stitches the hyperspectral
            %   data and widefield images into spatially coregistered
            %   outputs
            %
            %   YML = ProcessHyperspectral(obj, folder_or_config)
            %   folder_or_config can be either: 
            %       a path to a folder that contains a
            %       processing_config.yml file and data in the relevant
            %       hyper folder
            %       OR
            %       a config structure loaded using the 
            %       YML = LoadProcessingConfig(data_folder) Method
            %
            %   YML is a modified configuration with processing parameters

            % Process to hypercube sequence
            YML = obj.PreProcessHyperspectral(folder_or_config);
            % Perform postprocessing - rotate, stitch, etc
            YML = obj.PostProcessHyperspectral(YML.save_folder);
        end


        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % POSTPROCESSORS
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ProcessWidefield(obj, YML)
        ProcessTimelapse(obj, YML)
        ProcessZStack(obj, YML)

    end


    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % STATIC METHODS
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    methods (Static)
        YML = LoadProcessedConfig(data_folder)
        Calibrate(cal_dir)

        function p = ResolvePath(p)
            p = io.GetFullPath(p);
        end
    end
end

