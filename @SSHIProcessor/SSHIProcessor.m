classdef SSHIProcessor < handle
    %SSHIPROCESSOR Processor Class for SnapShot Hyperspectral Imager
    %   The purpose of this Class is to serve as a Data Processor that is a
    %   sole entry point for processing raw snapshot data into a hypercube.
    %   This Class holds hyperspectral calibration and processing
    %   parameters.

    properties
        % Calibration parameters
        basis_vector  % basis vectors for microlens placing onto camera img
        x0            % positional offset for central wavelength
        dlambda       % dispersion of spectra, pix/m
        lambda0       % central wavelength
        % Pinhole coordinates
        coords_xy     % coordinate vector array generated from the basis vectors
        % Processing parameters
        sampling = 100      % spatial pixels in hypercube
        wavelengths = 50    % spectral pixels in hypercube
        lambda_vector       % wavelength vector for hypercube
        filtw0 = 0          % spatial filtering for processing
    end

    methods
        function obj = SSHIProcessor(varargin)
            %SSHIPROCESSOR Construct an instance of this class
            %   H = SSHIProcessor(basis_vector, x0, dlambda, lambda0)
            %   H = SSHIProcessor(config_path)

            if ~isempty(varargin)
                obj.UpdateCalibration(varargin{:});
            end
            obj.UpdateSamplingVectors('Bandwidth', 20, 'WCentre', 680);
        end

        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % UPDATE CALIBRATION STATE
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        obj = UpdateCalibration(obj, varargin)
        obj = UpdateSamplingVectors(obj, varargin)


        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % PROCESSING - Hyperspectral
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function flag = isReadyForHyper(obj)
            if isempty(obj.basis_vector)
                error('No calibration loaded. Please run UpdateCalibration().')
            else
                flag = 1;
            end
        end

        hypercube = ProcessSnapshot(obj, img, varargin)
        ProcessHyperSequence(obj, img_list, save_path)


        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % PROCESSING - Stitch
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        StitchHypercube(obj, hypercube, save_path, S)
        StitchHypercubeSequence(obj, data_path, save_path, S, varargin)

        StitchWidefield(obj, img_stack, save_path, S)
        StitchWidefieldSequence(obj, data_path, save_path, S)
    end



    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % SUPERSEDED METHODS
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    methods
        function ProcessBFSequence(obj, img_path, save_path)
            % ProcessImgSequence(img_list, save_path)
            %   img_list
            %       is a list of images is a form of a structure returned
            %       by the 'dir' function
            %   save_path
            %       is a path to a .mat file where to save bf

            fprintf('\nProcessing image sequence\n\n');
            img_stack = io.read_tiff_sequence(img_path);
            % Preallocate onto disk
            m = matfile(save_path, 'Writable', true);
            m.bf = img_stack;

            fprintf('\nProcessing image sequence - Done\n\n');
        end
        function StitchHypercubeSingle(obj, data_path, save_path, S)
            % StitchHypercubeSingle(data_path, save_path, S)

            m = matfile(data_path, 'Writable', false);
            hypercube = m.hypercube;
            obj.StitchHypercube(hypercube, save_path, S);
        end
    end
end

