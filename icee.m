%% Behavioral Experiment: EMOTICON
%
% Usage: emoticon;
% At start, will prompt for the following required inputs:
%   Enter Debug Mode.
%   Subject Number.
%
% Written by Kyle Kurkela, October 2016
% See https://github.com/memobc/EMOTICON for more information

%% Initialize experiment-specific settings

% clear the workspace and add the ./functions directory to the MATLAB 
% search path
clear
addpath(genpath([fileparts(mfilename('fullpath')) filesep 'functions']))

% Ask the user for input
% DBmode   = Debugging Mode (smaller screen)
% subject  = subject number

DBmode   = input('Debug mode? y/n: ','s');
subject  = input('Enter subject ID: ','s');

% Hard coded yes/no variables:
% y = yes
% n = no
YN.enc  = 'y';              % run encoding
YN.ret  = 'n';              % run retrieval
YN.instructAutoSkip = 'n';  % autoskip instruction screens

% Initalize Psychtoolbox
init_psychtoolbox(DBmode);

% Time Stamp
TimeStamp = [datestr(clock,'yyyy-mm-dd-HHMM') datestr(clock,'ss')];

% if running debug mode, make the experiment go faster
global fast
if strcmp(DBmode, 'y')
    fast = .5; % .5 = 2x as fast, .1 = 10x as fast, 1 = real time, ect.
else
    fast = 1;
end

%% Run Experiment

try
    %% Try Running Experiment
    
    % specify directory paths
    stimdir    = fullfile(fileparts(mfilename('fullpath')), 'stim');
    listsdir   = fullfile(fileparts(mfilename('fullpath')), 'lists');
    
    % read in encoding trial list
    Encoding   = readtable(fullfile(listsdir, 'encoding_list.csv'));
    
    % read in retrieval trial list
    Retrieval  = readtable(fullfile(listsdir, 'retrieval_list.csv'));
    
    % preload stimuli
    Encoding  = preload_stim(Encoding, stimdir, 'FaceStim');
    Encoding  = preload_stim(Encoding, stimdir, 'SceneStim');
    Retrieval = preload_stim(Retrieval, stimdir, 'Face');
    Retrieval = preload_stim(Retrieval, stimdir, 'Scene');
  
    % number of runs
    nruns = 4;
    
    % For each run...
    for crun = 1:nruns
        
        %-- Trigger Screen
        instructions = 'Waiting for the scanner...';
        directions   = ' ';
        triggerTime  = instructions_screen(instructions, directions, YN.instructAutoSkip, KbName('t'), -1, 0);
        
        %-- Run Encoding
        if strcmp(YN.enc, 'y')              
            encoding(Encoding, crun);
        end

        %-- Trigger Screen
        instructions = 'Waiting for the scanner...';
        directions   = ' ';
        triggerTime  = instructions_screen(instructions, directions, YN.instructAutoSkip, KbName('t'), -1, 0);        
        
        %-- Run Retrieval
        if strcmp(YN.ret, 'y')
            retreival(Retrieval, crun);
        end

    end
        
    %% Finish up
    
    % Close all PTB screens (sca) and show the cursor again (ShowCursor)
    sca;
    ShowCursor;
    
    % If we are using a PC, show the task bar at the bottom
    if strcmp(computer,'PCWIN')
        ShowHideWinTaskbarMex(1);
    end
    
    % Close all files that are currently open in MATLAB, set the priority
    % back to zero, and allow keystrokes to enter MATLAB's Command Window
    fclose('all');
    Priority(0);
    ListenChar(0);
        
catch
 %% If something goes wrong..
 
    % catch error in case something goes wrong in the 'try' part
    % Do same cleanup as at the end of a regular session

    % Close all PTB screens (sca) and show the cursor again (ShowCursor) 
    sca;
    ShowCursor;
    
    % If we are using a PC, show the task bar at the bottom    
    if strcmp(computer,'PCWIN')
        ShowHideWinTaskbarMex(1);
    end
    
    % Close all files that are currently open in MATLAB, set the priority
    % back to zero, and allow keystrokes to enter MATLAB's Command Window
    fclose('all');
    Priority(0);
    ListenChar(0);
    
    % Output the error message that describes the error
    psychrethrow(psychlasterror);
    
end