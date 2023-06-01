function spect = dispspectra(img_hyper, varargin)
%NORMALIZE HYPERSPECTRAL DATA

if nargin > 1
    range = varargin{1};
else
    range = 1;
end

if nargin > 2
    med_size = varargin{2};
else
    med_size = 0;
end
    

if ndims(img_hyper) == 3
    if length(range) == 2
        tmp = mean(mean(img_hyper(range(1), range(2), :),1),2);
        if med_size ~= 0
            mv = (1:med_size) - (med_size + 1) / 2;
%             tmp = median(img_hyper(range(1) + mv, range(2) + mv, :), 1:2);
            tmp = max(img_hyper(range(1) + mv, range(2) + mv, :), [], 1:2);
        end
    else
        tmp = mean(mean(img_hyper(range, range, :),1),2);
    end
else
    tmp = img_hyper;
end

spect = normalize(squeeze(tmp), 'range');

end

