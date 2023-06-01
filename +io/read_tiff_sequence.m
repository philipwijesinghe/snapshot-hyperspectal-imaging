function tiffStack = read_tiff_sequence(tiffDirectory, varargin)
%   tiffStack = read_tiff_sequence(tiffDirectory)
%   tiffStack = read_tiff_sequence(tiffDirectory, numberOfTiffsToLoad)
%
%   Reads a sequence of tiffs in a folder into a 3D array
%
%   tiffDirectory is the folder directory that holds the .tif sequence
%
%   numberOfTiffsToLoad (optional) specifies the total number of tiffs to
%       read from the sequence
%
% Contributions and Changelog accessed via a private git repository:
% https://github.com/philipwijesinghe/widefield-lsm.git
% philip.wijesinghe@gmail.com
%
% Copyright (c) 2019 Philip Wijesinghe@University of St Andrews (pw64@st-andrews.ac.uk)
% 

% Build index
listOfTiffs = dir([tiffDirectory, filesep, '*.tif']);

% Read the last numerical id from the filename for sorting
listOfTiffIDs = regexp({listOfTiffs.name}, '\d+', 'match', 'all');
listOfTiffIDs = cat(1, listOfTiffIDs{:});
listOfTiffIDs = str2double(listOfTiffIDs(:,end));

% Sort by the id
[~, sortIdx] = sort(listOfTiffIDs);
listOfTiffs = listOfTiffs(sortIdx);

% How many tifs to load?
if nargin>1
    TiffsToLoad = varargin{1};
else
    TiffsToLoad = 1:length(listOfTiffIDs);
end

% Load stack
template = imread(fullfile(listOfTiffs(1).folder, listOfTiffs(1).name));
tiffStack = zeros(cat(2,size(template),length(TiffsToLoad)), class(template));
tiffSeq_ = 0;
for tiffID_ = TiffsToLoad
    tiffSeq_ = tiffSeq_+1;
    tiffStack(:,:,tiffSeq_) = imread(fullfile(listOfTiffs(tiffID_).folder, listOfTiffs(tiffID_).name));
end

end