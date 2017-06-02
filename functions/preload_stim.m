function [varargout] = preload_stim(varargin)
% preload_stim  function designed to preload the stimuli contatined in the
%               EMOTICON Encoding, Retrieval, and Find lists

%%
%==========================================================================
%                   Expand Input Arguments
%==========================================================================

global W

TrialList = varargin{1}; % Generic Trial List
FNColumn  = varargin{2}; % Column in Table with the File Names

%%
%==========================================================================
%                   Preload Item Stim
%==========================================================================
% Find all of the unique Item stimuli in this study and preload the images,
% assigning the unique Image ID's to trials that contain that stimuli

% Find all of the unique item stimuli in this study
uniquestim = unique(TrialList.FNColumn);

% Initialize an ItemimID variable for Encoding, Retrieval, and Find Lists
TrialList.([FNColumn 'id']) = zeros(height(TrialList), 1);

% For each unique Item stimuli...
for stim = uniquestim'
    
    % Create a filter for all of the trials in the Encoding, Retrieval, 
    % and Find lists that contain this item stimuli
    filter         = strcmp(TrialList.FNColumn, stim{:});
    
    % Preload Stimuli
    im        = imread(stim{:});
    imID      = Screen('MakeTexture', W, im);
    
    % Assign this image ID to the trials the contain this stimuli in the
    % Encoding and Retrieval lists
    if any(filter)
        TrialList.FNColumn(filter)  = imID;
    end
    
end
    
%% 
%==========================================================================
%                   Expand Out Arguments
%========================================================================== 

varargout{1} = TrialList;

end