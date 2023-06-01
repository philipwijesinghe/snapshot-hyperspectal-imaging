

process_dirs = {};
% 
% process_dirs{end+1} = 'F:\Hyperspectral\20210322\laser1';
% process_dirs{end+1} = 'F:\Hyperspectral\20210322\laser2-dish4';
% process_dirs{end+1} = 'F:\Hyperspectral\20210322\laser3and4';
% process_dirs{end+1} = 'F:\Hyperspectral\20210322\laser6-dish4';
% process_dirs{end+1} = 'F:\Hyperspectral\20210317\Dish2wdscan';
% process_dirs{end+1} = 'F:\Hyperspectral\20210317\Dish3wdscan';
% process_dirs{end+1} = 'F:\Hyperspectral\20210317\Dish4wdscan';
% process_dirs{end+1} = 'F:\Hyperspectral\20210316\dish2_single';
% process_dirs{end+1} = 'F:\Hyperspectral\20210316\dish2_single_200';
% process_dirs{end+1} = 'F:\Hyperspectral\20210312\zstack1';
% process_dirs{end+1} = 'F:\Hyperspectral\20210312\zstack2';
% process_dirs{end+1} = 'F:\Hyperspectral\20210312\zstack3';
% process_dirs{end+1} = 'F:\Hyperspectral\20210312\zstack3_1';
% process_dirs{end+1} = 'F:\Hyperspectral\20210324\20210324-dish2_macro_timelapse-manydiskshort';
% process_dirs{end+1} = 'F:\Hyperspectral\20210324\20210325-dish7-fibroblasttime';

process_dirs{end+1} = 'F:\Hyperspectral\20210331_Dish9\20210331_Dish9_macrofage_timelapsse';
process_dirs{end+1} = 'F:\Hyperspectral\20210323-Dish1Macrophage_180um_25min\Dish1_macrotimelapse1';
process_dirs{end+1} = 'F:\Hyperspectral\20210324\20210324-dish2_macro_timelapse-manydiskshort';
process_dirs{end+1} = 'F:\Hyperspectral\20210324\20210325-dish7-fibroblasttime';
% 
% process_dirs{end+1} = 'F:\Hyperspectral\20210421_zstack\zone1_disksinagrose_500_1um';
% process_dirs{end+1} = 'F:\Hyperspectral\20210421_zstack\zone2_diskinagrose_300_2um';
% process_dirs{end+1} = 'F:\Hyperspectral\20210421_zstack\zone3_diskinagrose_400_2um';
% process_dirs{end+1} = 'F:\Hyperspectral\20210421_zstack\zone4-5_diskinagrose_300_2um';
% process_dirs{end+1} = 'F:\Hyperspectral\20210421_zstack\zone6_diskinagrose_200_2um';
% process_dirs{end+1} = 'F:\Hyperspectral\20210421_zstack\zone7_diskinagrose_300_2-5um';

% process_dirs = {};


% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk1';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk2_6';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk2_7';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk2_8';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk3';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk7_25Hz';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk7_50Hz';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper\disk9';
% process_dirs{end+1} = 'F:\Hyperspectral\20210316\dish1_timelapse1overnight_200_refocus';
% process_dirs{end+1} = 'F:\Hyperspectral\20210316\dish2_timelapse2_200um_20m';
% process_dirs{end+1} = 'F:\Hyperspectral\20210316\dish1_timelapse1overnight_200'; %big


% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk1';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk2_6';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk2_7';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk2_8';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk3';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk7_25Hz';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk7_50Hz';
% process_dirs{end+1} = 'F:\Hyperspectral\cardiomyocyte test hyper-Processed-20220207\disk9';

H = SSHIController();

fail = {};
for ni = 1:numel(process_dirs)
   try
       H.ProcessHyperspectral(process_dirs{ni});
   catch
       fail{end+1} = process_dirs{ni};
   end
end


% fail2 = {};
% for ni = 1:numel(fail)
%    try
%        H.ProcessHyperspectral(fail{ni});
%    catch
%        fail2{end+1} = fail{ni};
%    end
% end

% fail = {};
% for ni = 1:numel(process_dirs)
%    try
%        H.PostProcessHyperspectral(process_dirs{ni});
%    catch
%        fail{end+1} = process_dirs{ni};
%    end
% end