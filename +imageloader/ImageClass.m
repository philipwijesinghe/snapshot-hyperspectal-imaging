classdef (Abstract) ImageClass < handle
    %IMAGECLASS This is an abstract class that should provide the template
    %for image loader classes for Hyper, BF and Lasing images
    
    properties (Abstract)
        Dir % directory object should be iterable for each scan No
        ROI % defines desired ROI with absolute coordinates
        pix_shift
        n_scans
        data_size
        
        isInitialised
    end
    
    methods
        function obj = ImageClass(varargin)
            %IMAGECLASS Construct an instance of this class
            obj.isInitialised = 0;
            if nargin == 1
                obj.isInitialised = 1;
                obj.Dir = varargin{1};
                obj.SetROI(0);
                obj.n_scans = length(obj.Dir);
                obj.data_size = obj.GetSize;
                if length(obj.data_size) == 4
                    if obj.data_size(4) > 1
                       obj.n_scans = obj.n_scans * obj.data_size(4);
                    end
                end
            end
        end
        function SetROI(obj, roi)
            % roi.h = [0, 1];
            % roi.v = [0, 1];
            if isstruct(roi) && obj.isInitialised
                obj.ROI = roi;
            else
                obj.ROI = 0;
            end
        end
        function SetPixShift(obj, pix_shift)
            obj.pix_shift = pix_shift;
        end
        function img = Read(obj, scan_id, varargin)
            if obj.isInitialised
                img = obj.ReadRaw(scan_id, varargin{:});
            else
                img = zeros(32);
            end

            if ~isempty(obj.pix_shift)
                img = circshift(img, obj.pix_shift);
            end
        end
        function ConvertAll(obj, varargin)
            fprintf('Converting images\n');
            for ni = 1:obj.n_scans
                fprintf('%i of %i\n', ni, obj.n_scans);
                obj.GetPath(ni, varargin{:});
            end
        end
    end
    
    methods (Abstract)
        img = ReadRaw(obj, scan_id, varargin)
        img_size = GetSize(obj)
        [data_path, img_no] = GetPath(obj, scan_id, varargin)
    end
    
end
    
