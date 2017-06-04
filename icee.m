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

% Establish Global Variables that will span this script, init_psychtoolbox.m,
% encoding.m, and retrieval.m
global Subject TimeStamp Fast

% Ask the user for input
% DBmode   = Debugging Mode (smaller screen)
% subject  = subject number

DBmode   = input('Debug mode? y/n: ','s');
Subject  = input('Enter subject ID: ','s');
nRuns    = 4;
rep_device = -1;

% Hard coded yes/no variables:
% y = yes
% n = no
YN.enc  = 'y';              % run encoding
YN.ret  = 'y';              % run retrieval
YN.instructAutoSkip = 'n';  % autoskip instruction screens

% Initalize Psychtoolbox, see init_psychtoolbox
init_psychtoolbox(DBmode);

% Time Stamp
TimeStamp = [datestr(clock,'yyyy-mm-dd-HHMM') datestr(clock,'ss')];

% if running debug mode, make the experiment go faster
if strcmp(DBmode, 'y')
    Fast = .5; % .5 = 2x as fast, .1 = 10x as fast, 1 = real time, ect.
else
    Fast = 1;
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
    
    % For each run...
    for iRun = 1:nRuns
        
        %-- Encoding Instructions Screen
        instructions = 'Encoding\n\nMake your welcoming decision as quickly and accurately as you can';
        directions   = ' ';
        instructions_screen(instructions, directions);
        
        %-- Trigger Screen
        % looks for a lowercase 't' as the trigger
        instructions = 'Waiting for the scanner...';
        directions   = ' ';
        KeyboardKeys = [KbName('t') KbName('escape')];
        triggerTime  = instructions_screen(instructions, directions, [], KeyboardKeys);
        
        %-- Run Encoding
        if strcmp(YN.enc, 'y')
            encoding(Encoding, iRun, triggerTime);
        end
        
        %-- Retrieval Instructions Screen
        instructions = 'Retrieval\n\nMake your memory decision as quickly and accurately as you can';
        directions   = ' ';
        instructions_screen(instructions, directions);
        
        %-- Trigger Screen
        instructions = 'Waiting for the scanner...';
        directions   = ' ';
        KeyboardKeys = [KbName('t') KbName('escape')];
        triggerTime  = instructions_screen(instructions, directions, [], KeyboardKeys);        
        
        %-- Run Retrieval
        if strcmp(YN.ret, 'y')
            retrieval(Retrieval, iRun, triggerTime);
        end

    end
        
    %% Finish up
    
    % Close all PTB screens (sca) and show the cursor again (ShowCursor)
    sca;
    ShowCursor;
    
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
    
    % Close all files that are currently open in MATLAB, set the priority
    % back to zero, and allow keystrokes to enter MATLAB's Command Window
    fclose('all');
    Priority(0);
    ListenChar(0);
    
    % Output the error message that describes the error
    psychrethrow(psychlasterror);
    
end