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
nRuns    = 5;
rep_device = 0;

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
    Fast = .1; % .5 = 2x as fast, .1 = 10x as fast, 1 = real time, ect.
else
    Fast = .05;
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
        
 
        %Screen 2
        instructions = 'You will see scenes and faces together on the screen.\n\nLook at both the scene and face in each slide and rate how\n\nwelcoming both the scene and face are using the four button box.' ;
        directions   = ' ' ; 
        instructions_screen(instructions, directions);  
        
        %-- Screen 3
        %instructions = 'Please take a moment and explain to\n\nthe researcher what you are going to do.';
        %directions   = ' ';
        %instructions_screen(instructions, directions);  
        
        %-- Trigger Screen
        % looks for a lowercase 't' as the trigger
        instructions = 'Waiting for the scanner...';
        directions   = ' ';
        KeyboardKeys = [KbName('t') KbName('escape')];
        triggerTime  = instructions_screen(instructions, directions, [], KeyboardKeys);
     tic
        %-- Run Encoding
        if strcmp(YN.enc, 'y')
            encoding(Encoding, iRun, triggerTime);
        end
    toc 
     %-- Retrieval Instructions Screens   
    %-- Screen 1   %nancy changed this to add moredirections line
               
        instructions = 'You will again see faces and scenes appear together on the screen.\n\nPlease look at each face and scene and rate whether you REMEMBER\n\n the pairing, KNOW the pairing (if it looks familiar,)\n\n or if the pairing is NEW to you, regardless of the layout.\n\n Use the first three buttons on the button box to make your decision.';
        directions   = ' ';
        instructions_screen(instructions, directions);
        
        %--  Screen 2
        %instructions = 'Please take a moment and explain to\n\nthe researcher what you are going to do.';
        %directions   = ' ';
        %instructions_screen(instructions, directions);  
        
        %-- Trigger Screen
        instructions = 'Waiting for the scanner...';
        directions   = ' ';
        KeyboardKeys = [KbName('t') KbName('escape')];
        triggerTime  = instructions_screen(instructions, directions, [], KeyboardKeys);        
     tic
        %-- Run Retrieval
        if strcmp(YN.ret, 'y')
            retrieval(Retrieval, iRun, triggerTime);
        end
     toc
    end
  
        
    %% Finish up
    
    % Close all PTB screens (sca) and show the cursor again (ShowCursor)
    sca;
    ShowCursor;
    
    % Close all files that are currently open in MATLAB, set the priority
    % back to zero, and allow keystrokes to enter MATLAB's Command Window
    fclose('all');
    Priority(0);
    %ListenChar(0);
    
    % Compile Data
    compile('./data')
        
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
   % ListenChar(0);
    
    % Output the error message that describes the error
    psychrethrow(psychlasterror);
    
end