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
addpath(genpath([pwd filesep 'functions']))

% Ask the user for input
% DBmode   = Debugging Mode (smaller screen)
% subject  = subject number

DBmode  = input('Debug mode? y/n: ','s');
subject = input('Enter subject ID: ','s');

% Hard coded yes/no variables:
% y = yes
% n = no
YN.enc  = 'y';              % run encoding
YN.ret  = 'y';              % run retrieval
YN.FTB  = 'y';              % run find
YN.instructAutoSkip = 'n';  % autoskip instruction screens

% Initalize Psychtoolbox
init_psychtoolbox(DBmode);

% Time Stamp
TimeStamp = [datestr(clock,'yyyy-mm-dd-HHMM') datestr(clock,'ss')];

% if running debug mode, make the experiment go faster
if strcmp(DBmode, 'y')
    fast = 1; % .5 = 2x as fast, .1 = 10x as fast, 1 = real time, ect.
else
    fast = 1;
end

%% Run Experiment

try
    %% Try Running Experiment
    
    % Generate the Encoding, Retrieval, and Find Trial Lists
    [Encoding, Retrieval, Find] = generate_lists(fullfile(pwd, 'stim'));
    
    % Preload the trial stimuli prior to beginning the experiment
    [Encoding, Retrieval, Find, E_pahandle, N_pahandle] = preload_stim(Encoding, Retrieval, Find);    
    
    enccount  = 0;
    retcount  = 0;
    findcount = 0;
    
    % Each experimental run is paired in the following manner:
    % Enc1, Enc2, Ret1, Ret2, Find1, Find2
    % Enc3, Enc4, Ret3, Ret4, Find3, Find4
    
    for outer = 1:length(unique(Encoding.RunID))/2
        
        %-- "Welcome to Run" Screen
        
        instructions = ['Welcome to Run ' num2str(outer)];
        directions   = 'Press spacebar when you are ready to continue';
        instructions_screen(instructions, directions, YN.instructAutoSkip);
        
        %-- Paired Encoding

        for encinner = 1:2
            
            % advance enc counter; grab this Encoding run's trials
            enccount   = enccount + 1;
            thisEncRun = Encoding(Encoding.RunID == enccount,:);
            
            % run encoding phase
            if strcmp(YN.enc, 'y')              
                encoding;
            end
        
        end
        
        %-- View/Remember Buffer Screen
        
        instructions = 'You are finished with the pair View Rounds';
        directions   = 'Press spacebar when you are ready to continue to the Remember Rounds';
        instructions_screen(instructions, directions, YN.instructAutoSkip);
        
        %-- Paired Retrieval
        
        for retinner = 1:2
            
            % advance ret counter; grab this Retrieval run's trials
            retcount   = retcount + 1;
            thisRetRun = Retrieval(Retrieval.RunID == retcount, :);

            % run retrieval phase
            if strcmp(YN.ret, 'y')
                retreival;
            end
            
        end
        
        %-- Retrieval/Find Buffer Screen
        
        instructions = 'You are finished with the pair of Remember Rounds';
        directions   = 'Press spacebar when you are ready to continue to the Find Rounds';
        instructions_screen(instructions, directions, YN.instructAutoSkip);

        %-- Paired Find
        
        for findinner = 1:2
            
            % advance find counter; grab this Find run's trials
            findcount       = findcount + 1;
            thisFindTheBoop = Find(Find.RunID == findcount, :);

            % run find phase
            if strcmp(YN.FTB, 'y')
                find_the_boop;
            end
        
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
    PsychPortAudio('Close');
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