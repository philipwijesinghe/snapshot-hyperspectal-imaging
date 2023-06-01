classdef TiffLoader < imageloader.ImageClass
    %HYPERLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Dir % directory object should be iterable for each scan No
        ROI % defines desired ROI with absolute coordinates
        pix_shift
        n_scans
        data_size
                
        isInitialised
    end
    
    methods
        function img = ReadRaw(obj, scan_id, varargin)
            %Read
            data_path = obj.GetPath(scan_id, varargin{:});
            
            img = double(imread(data_path));
           
            
            if isstruct(obj.ROI)
                img_size = size(img);
                clip_v = round([(img_size(1) - 1) * obj.ROI.v(1) + 1, ...
                    (img_size(1) - 1) * obj.ROI.v(2) + 1]);
                clip_h = round([(img_size(2) - 1) * obj.ROI.h(1) + 1, ...
                    (img_size(2) - 1) * obj.ROI.h(2) + 1]);
                
                img = img(clip_v(1):clip_v(2), clip_h(1):clip_h(2));
            end
        end
        function img_size = GetSize(obj)
            % Reads data size without loading
            data_path = obj.GetPath(1);
            img_info = imfinfo(data_path);
            img_size = [img_info.Height, img_info.Width];
        end
        function [data_path, img_no] = GetPath(obj, scan_id, varargin)
            p = inputParser;
            addParameter(p, 'LR', 0);
            parse(p, varargin{:});

            % Get scan path and image no for loading
            if scan_id > obj.n_scans  % in case there are fewer widefields than hyper images taken
                scan_id = obj.n_scans;
                if obj.n_scans > 1
                    fprintf('Requested image out of sequence range\n');
                end
            end

            img_no = 1;
            if length(obj.data_size) == 4
                if obj.data_size(4) > 1
                    img_no = mod(scan_id - 1, obj.data_size(4)) + 1; % [1, size]
                    scan_id = ceil(scan_id / obj.data_size(4)); % data is a hyper image stack
                end
            end

            if p.Results.LR(1) ~= 0 % convert to LR
                lr_dir = fullfile(obj.Dir(scan_id).folder, sprintf('LR_%i_%i', p.Results.LR(1), p.Results.LR(2)));
                if ~exist(lr_dir, 'dir')
                    % Generate LR
                    obj.ConvertToLowRes(obj.Dir(scan_id).folder, lr_dir, p.Results.LR);
                end

                % Load LR
                data_path = fullfile(lr_dir, obj.Dir(scan_id).name);
            else
                data_path = fullfile(obj.Dir(scan_id).folder, obj.Dir(scan_id).name);
            end
        end
        function ConvertToLowRes(obj, dir_from, dir_to, lr_size)
            fprintf('Resizing tiff images\n');

            dir_list = dir(fullfile(dir_from, '*.tif'));
            if ~exist(dir_to, 'dir')
                mkdir(dir_to);
            end

            f = waitbar(0, 'Generating low-resolution images for fast visualisation');
            for ni = 1:numel(dir_list)
                data_path = fullfile(dir_list(ni).folder, dir_list(ni).name);
                img = imread(data_path);
                img = imresize(img, lr_size);
                imwrite(img, fullfile(dir_to, dir_list(ni).name));
                waitbar(ni/numel(dir_list), f, 'Generating low-resolution images for fast visualisation');
            end
        end
    end
end

