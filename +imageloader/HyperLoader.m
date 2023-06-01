classdef HyperLoader < imageloader.ImageClass
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
            %Read a single frame from data
            [data_path, img_no] = obj.GetPath(scan_id, varargin{:});
            
            m = matfile(data_path);
            
            if isstruct(obj.ROI)
                clip_v = round([(obj.data_size(1) - 1) * obj.ROI.v(1) + 1, ...
                    (obj.data_size(1) - 1) * obj.ROI.v(2) + 1]);
                clip_h = round([(obj.data_size(2) - 1) * obj.ROI.h(1) + 1, ...
                    (obj.data_size(2) - 1) * obj.ROI.h(2) + 1]);
            end
            
            if nargin == 2
                if ~isstruct(obj.ROI)
                    img = m.hypercube(:,:,:,img_no);
                else
                    img = m.hypercube(clip_v(1):clip_v(2), clip_h(1):clip_h(2), :, img_no);
                end
            elseif nargin == 3
                if ~isstruct(obj.ROI)
                    img = m.hypercube(:,:,img_no);
                else
                    img = m.hypercube(clip_v(1):clip_v(2), clip_h(1):clip_h(2), img_no);
                end
            end
        end
        function img_size = GetSize(obj)
            % Reads data size without loading
            data_path = obj.GetPath(1);
            m = matfile(data_path);
            img_size = size(m, 'hypercube');
        end
        function [data_path, img_no] = GetPath(obj, scan_id, varargin)

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

            if nargin == 3 % convert to LR
                lr_dir = fullfile(obj.Dir(scan_id).folder, 'Projections');
                if ~exist(lr_dir, 'dir')
                    % Generate LR
                    obj.ConvertToProj(obj.Dir(scan_id).folder, lr_dir);
                end
                
                file_name = obj.Dir(scan_id).name;
                file_name = file_name(1:end - 4);

                if strcmpi(varargin{1}, 'Max')
                    data_path = fullfile(lr_dir, [file_name, '_max.mat']);
                else
                    data_path = fullfile(lr_dir, [file_name, '_sum.mat']);
                end
            else
                data_path = fullfile(obj.Dir(scan_id).folder, obj.Dir(scan_id).name);
            end
        end
        function ConvertToProj(obj, dir_from, dir_to)
            fprintf('Calculating hyper projections\n');

            dir_list = dir(fullfile(dir_from, '*wide.mat'));
            if ~exist(dir_to, 'dir')
                mkdir(dir_to);
            end

            for ni = 1:numel(dir_list)
                data_path = fullfile(dir_list(ni).folder, dir_list(ni).name);
                m = matfile(data_path);
                img = m.hypercube;

                file_name = obj.Dir(ni).name;
                file_name = file_name(1:end - 4);
                save_path_max = fullfile(dir_to, [file_name, '_max.mat']);
                save_path_sum = fullfile(dir_to, [file_name, '_sum.mat']);
                
                s1 = matfile(save_path_max, "Writable", true);
                s1.hypercube = uint16(max(img, [], 3));
                s2 = matfile(save_path_sum, "Writable", true);
                s2.hypercube = uint16(sum(img, 3));

                if size(s1.hypercube, 4) ~=1
                    for si = 1:size(s1.hypercube, 4)
                        file_name_i = sprintf([file_name, '_%04i'], si);
                        imwrite(uint16(s1.hypercube), fullfile(dir_to, [file_name_i, '_max.tif']));
                        imwrite(uint16(s2.hypercube), fullfile(dir_to, [file_name_i, '_sum.tif']));
                    end
                else
                    imwrite(uint16(s1.hypercube), fullfile(dir_to, [file_name, '_max.tif']));
                    imwrite(uint16(s2.hypercube), fullfile(dir_to, [file_name, '_sum.tif']));
                end
            end
        end
        function ExportToStack(obj, filename, max_or_sum)
            img_stack = zeros([obj.data_size(1), obj.data_size(2), obj.n_scans], 'uint16');
            for ii = 1:obj.n_scans
                img_stack(:,:,ii) = obj.Read(ii, max_or_sum);
            end
            io.save_tiff_sequence(filename, img_stack);
        end
    end
end

