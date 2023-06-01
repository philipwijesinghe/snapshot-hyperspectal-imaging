function SetROI(obj, roi)

if any(roi.h > 1)   
    if obj.Hyper.isInitialised
        ROI = struct;
        
        ROI.v = ([(roi.v(1) - 1) / (obj.Hyper.data_size(1) - 1), ...
            (roi.v(2) - 1) / (obj.Hyper.data_size(1) - 1)]);
        ROI.h = ([(roi.h(1) - 1) / (obj.Hyper.data_size(2) - 1), ...
            (roi.h(2) - 1) / (obj.Hyper.data_size(2) - 1)]);     
    
        roi = ROI;
    end
end

if obj.Hyper.isInitialised
    obj.Hyper.SetROI(roi);
end
if obj.BF.isInitialised
    obj.BF.SetROI(roi);
end
if obj.Lasing.isInitialised
    obj.Lasing.SetROI(roi);
end
end

