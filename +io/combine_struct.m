function res = combine_struct(x, y)
%% res = COMBINE_STRUCT(x, y)
% Helper function for merging two structs together. Fields in 'y' will overwrite
% fields in 'x'. Called recursively, so should merge all fields correctly.
%
% SOURCE: https://stackoverflow.com/a/6271161

import io.*

if isstruct(x) && isstruct(y)
    % Take all the fields from 'x', and see if anything in 'y' overwrites them
    res = x;
    names = fieldnames(y);
    for fnum = 1:numel(names)
        if isfield(x, names{fnum})
            % Field already exists in 'x', merge it with the field in 'y'
            res.(names{fnum}) = combine_struct(x.(names{fnum}), y.(names{fnum}));
        else
            % Just take the field from 'y'
            res.(names{fnum}) = y.(names{fnum});
        end
    end
else
    res = y;
end
