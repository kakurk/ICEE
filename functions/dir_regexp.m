function matched = dir_regexp(directory, expression)
% dir_regexp    function that matches directory contents based on a given
%               regular expression, ignoring case
%
%       matched = dir_regexp(directory, expression)
%
%       directory = full path to a directory whose contents you would like
%                   to filter
%
%       expression = a regular expression used to filter the contents of
%                   directory
%
%       matched    = a structure array in the format of the one returned by
%                    MATLAB's dir function, with only the directory 
%                    contents that match the regular expression 
%                    "expression". Will return as empty if no matches.
%
%   See also: dir, regexpi


    Contents = dir(directory);
    matched  = struct('name', '', 'date', [], 'bytes', [], 'isdir', [], 'datenum', []);
    count    = 0;
    
    for c = 1:length(Contents)
       if ~isempty(regexpi(Contents(c).name, expression, 'once'))
           count          = count + 1;
           matched(count) = Contents(c);
       end
    end

end