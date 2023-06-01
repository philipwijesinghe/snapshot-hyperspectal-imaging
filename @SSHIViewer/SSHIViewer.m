classdef SSHIViewer < handle
    %SSHIVIEWER Viewer Class for SnapShot Hyperspectral Imager
    %   The purpose of this Class is to collect information describing
    %   processed hyperspectral data and to provide methods for
    %   visualisation
    
    properties
        Controller
        YML
        
        % ImageLoaders
        Hyper
        BF
        Lasing
        
        % Flags/status
        isParsed = 0
        
    end
    
    methods
        function obj = SSHIViewer(varargin)
            %SSHIPROCESSOR Construct an instance of this class
            %   H = SSHIViewer()
            %   H = SSHIViewer(data_path)
            %
            % How to load hyperspectral experiment images:
            % H = SSHIViewer(data_path)
            % img_h = H.Hyper.Read(scan_no)
            % img_bf = H.BF.Read(scan_no)
            % img_lasing = H.Lasing.Read(scan_no)
            %
            % View and load roi (roi relative to image size [0, 1])
            % roi.h = [0, 0.5];
            % roi.v = [0.5, 1];
            % H.Hyper.SetROI(roi)
            % H.BF.SetROI(roi)
            % H.Lasing.SetROI(roi)
            % Once set, _.Read methods will return ROI only
            
            obj.Controller = SSHIController();
            
            if ~isempty(varargin)
                obj.LoadProcessedConfig(varargin{1});
            end
        end
    end
    
    methods (Access = public)
        LoadProcessedConfig(obj, data_path)
        SetROI(obj, roi)
    end
    
    methods (Access = private)
        ParseProcessedFolder(obj)
    end
end

