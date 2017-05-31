function [varargout] = preload_stim(varargin)
% preload_stim  function designed to preload the stimuli contatined in the
%               EMOTICON Encoding, Retrieval, and Find lists

%%
%==========================================================================
%                   Expand Input Arguments
%==========================================================================

global W

Encoding  = varargin{1}; % Enc List
Retrieval = varargin{2}; % Ret List
if nargin > 2
    FindTheBoop = varargin{3}; % If it is inputted, the Find List
end

%%
%==========================================================================
%                   Preload Item Stim
%==========================================================================
% Find all of the unique Item stimuli in this study and preload the images,
% assigning the unique Image ID's to trials that contain that stimuli

% Find all of the unique item stimuli in this study
uniquestim = unique(vertcat(Encoding.ImageFile, Retrieval.ImageFile));

% Initialize an ItemimID variable for Encoding, Retrieval, and Find Lists
Encoding.ItemimID     = zeros(height(Encoding), 1);
Retrieval.ItemimID    = zeros(height(Retrieval), 1);
if nargin > 2
    FindTheBoop.Item1imID = zeros(height(FindTheBoop), 1);
    FindTheBoop.Item2imID = zeros(height(FindTheBoop), 1);
end

% For each unique Item stimuli...
for stim = uniquestim'
    
    % Create a filter for all of the trials in the Encoding, Retrieval, 
    % and Find lists that contain this item stimuli
    Encfilter         = strcmp(Encoding.ImageFile, stim{:});
    Retfilter         = strcmp(Retrieval.ImageFile, stim{:});
    if nargin > 2
        FindTheBoop1filter = strcmp(FindTheBoop.item1ImageFile, stim{:});
        FindTheBoop2filter = strcmp(FindTheBoop.item2ImageFile, stim{:});
    end
    
    % Preload Stimuli
    im        = imread(stim{:});
    imID      = Screen('MakeTexture', W, im);
    
    % Assign this image ID to the trials the contain this stimuli in the
    % Encoding and Retrieval lists
    if any(Encfilter)
        Encoding.ItemimID(Encfilter)  = imID;
    end
    if any(Retfilter)
        Retrieval.ItemimID(Retfilter) = imID;
    end
    if nargin > 2
        if any(FindTheBoop1filter)
            FindTheBoop.Item1imID(FindTheBoop1filter) = imID;
        end
        if any(FindTheBoop2filter)
            FindTheBoop.Item2imID(FindTheBoop2filter) = imID;
        end
    end
    
end

%%
%==========================================================================
%                   Preload Background/Context Stim
%==========================================================================
% Find all of the unique Context stimuli in this study and preload the 
% images, assigning the unique Image ID's to trials that contain that 
% stimuli

% Find all of the unique context stimuli in this study
uniquecontextstim = unique(vertcat(Encoding.ContextImageFile, Retrieval.ContextImageFile));
uniquecontextstim = uniquecontextstim(~cellfun('isempty', uniquecontextstim));

% Initialize an ContextimID variable for Encoding and Retrieval Lists
Encoding.ContextimID  = zeros(height(Encoding), 1);
Retrieval.ContextimID = zeros(height(Retrieval), 1);

% For each unique Context Stimuli...
for stim = uniquecontextstim'
    
    % Create a filter for all of the trials in encoding and Retrieval that
    % contain this Context stimuli
    Encfilter = strcmp(Encoding.ContextImageFile, stim{:});
    Retfilter = strcmp(Retrieval.RetContext, stim{:});
    
    % Preload Stimuli
    im        = imread(stim{:});
    imID      = Screen('MakeTexture', W, im);
    
    % Assign this image ID to the trials in this stimuli in the Encoding 
    % and Retireval lists
    if any(Encfilter)
        Encoding.ContextimID(Encfilter)  = imID;
    end
    if any(Retfilter)
        Retrieval.ContextimID(Retfilter) = imID;
    end
    
end

%% 
%==========================================================================
%                   Preload Sounds
%==========================================================================
% Preload the two sounds (neutral, negative) to be played during the
% encoding phase

    % Aversive
    [E_wavedata, freq]  = audioread('./stim/white_-10dBFS_250ms.wav');      % load .wav file for aversive white noise burst
    E_pahandle          = PsychPortAudio('Open', [], [], 1, freq, 1, 0);    % opens sound buffer
    PsychPortAudio('FillBuffer', E_pahandle, E_wavedata');                  % loads data into buffer
    
    % Neutral
    [N_wavedata, freq]  = audioread('./stim/sin_50Hz_-10dBFS_500ms.wav');   % load .wav file for neutral noise
    N_pahandle          = PsychPortAudio('Open', [], [], 1, freq, 1, 0);    % opens sound buffer
    PsychPortAudio('FillBuffer', N_pahandle, N_wavedata');                  % loads data into buffer
    
%% 
%==========================================================================
%                   Expand Out Arguments
%========================================================================== 

varargout{1} = Encoding;
varargout{2} = Retrieval;
if nargin > 2
    varargout{3} = FindTheBoop;
    varargout{4} = E_pahandle;
    varargout{5} = N_pahandle;
else
    varargout{3} = E_pahandle;
    varargout{4} = N_pahandle;
end

end