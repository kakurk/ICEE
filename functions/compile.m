function compile(datadir)
% function for compiling the retrieval and encoding data into one file

global Subject TimeStamp

%% Encoding

% regular expression
expression        = ['.*encoding.*' Subject '.*' TimeStamp '.csv'];

% build full path to matched files
fileStructure     = dir_regexp(datadir, expression);
fileCellArray     = {fileStructure.name}';
fullfileCellArray = strcat({datadir}, {filesep}, fileCellArray);

% read in an concatenate matched files
AllOfEncoding     = cellfun(@readtable, fullfileCellArray, 'UniformOutput', false);
AllOfEncoding     = vertcat(AllOfEncoding{:});

% write matched files
filename = ['icee_encoding_' Subject '_compiled_' TimeStamp '.csv'];
writetable(AllOfEncoding, fullfile(datadir, filename));

%% Retrieval

% regular expression
expression        = ['.*retrieval.*' Subject '.*' TimeStamp '.csv'];

% build full path to matched files
fileStructure     = dir_regexp(datadir, expression);
fileCellArray     = {fileStructure.name}';
fullfileCellArray = strcat({datadir}, {filesep}, fileCellArray);

% read in an concatenate matched files
AllOfEncoding     = cellfun(@readtable, fullfileCellArray, 'UniformOutput', false);
AllOfEncoding     = vertcat(AllOfEncoding{:});

% write matched files
filename = ['icee_retrieval_' Subject '_compiled_' TimeStamp '.csv'];
writetable(AllOfEncoding, fullfile(datadir, filename));

end