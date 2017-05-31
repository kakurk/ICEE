%% EMOTICON Encoding:
% Called by emoticon.m
% Written by Kyle Kurkela, kyleakurkela@gmail.com October 2016
% See https://github.com/memobc/EMOTICON for more information

%%
%==========================================================================
%				Settings
%==========================================================================

%-- Instructions
    
    % Instructions Message
    instructions = {
        'View Round\n\nAnswer the questions as quickly and accurately as you can'
    };
    
%-- EMOTICON Specific Settings

    % Size of the item stimuli, in pixels (i.e., as a n x n square)
    ImgSize      = 256;
    
    % The amount of time the beginning-of-miniblock instructions are
    % displayed on the screen (s)
    instrScrTime  = 4;
    
    % The amount of time post-trial fixations are displayed (s)
    fixTime       = 1.5;
    
    % Amount of time the context stimuli is displayed prior to the Item
    % stimuli coming onto the screen (s)
    conTime       = 1.5;
    
    % The amount of time the item stimuli is displayed (s)
    picTime       = 2;
    
    % The number of repetitions of the sounds to be played (s)
    repetitions   = 1;
    
    % The amount of time the pre run fixation is displayed (s)
    preFix        = 2;
    
    % The amount of time the post run fixation is displayed (s)
    postFix       = 2;
    
%-- Initialize Response Recorder Variables

    OnsetTime    = zeros(1, height(thisEncRun));
    resp         = cell(1, height(thisEncRun));
    resp_time    = zeros(1, height(thisEncRun));

%-- Create the Keyboard Queue (see KbQueue documentation), restricting
%   responses to the ENC_keylist keys (see init_psychtoolbox)
    rep_device = -1;
    keylist = zeros(1, 256);
    keylist([KbName('1!') KbName('2@')]) = 1;    
    KbQueueCreate(rep_device, keylist)
    
%-- Establish global variables

    global W X Y

%%
%==========================================================================
%				Instructions
%==========================================================================
% Display instructions and wait for a participant's response before 
% continuing. Please see instructions_screen documentation for more 
% details. Written in a for loop to display multiple instructions screens,
% if desired.

for i = 1:length(instructions)
    
    instructions_screen(instructions{i}, [], YN.instructAutoSkip);
    
end

%%
%==========================================================================
%				Pre Run Fixation
%==========================================================================
% Draw a fixation cross to the exact center of the screen. Update the 
% display and record the moment the fixation cross was displayed in the 
% variable "expstart". "expstart" will mark the beginning of the this run.
% Display this fixation cross for 2 seconds.

Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);
expstart = Screen('Flip', W);
WaitSecs(preFix * fast);

%%
%==========================================================================
%				Routine
%==========================================================================
% Encoding Routine

% Initalize a tracker varaible 'prevMiniBlock'. This variable keeps track 
% of the previous trial's Mini Block ID; used in determining when to 
% display the beginning of Mini Block instructions screen
prevMiniBlock = 0;

% For each trial in thisEncRun...
for curTrial = 1:height(thisEncRun)
    
    %-- Start of a New Mini Block Instructions Screen
    
        % Figure out which context was assigned to this trial and assign 
        % the appropriate question
        if strcmp(thisEncRun.Context(curTrial), 'context_001.jpg')
            message = 'Is the object larger than a basketball?\n\n1 = yes  |  2 = no';
        elseif strcmp(thisEncRun.Context(curTrial), 'context_002.jpg')
            message = 'Would the object be found in a circus?\n\n1 = yes  |  2 = no';
        elseif strcmp(thisEncRun.Context(curTrial), 'context_003.jpg')
            message = 'Would you keep the object in an office?\n\n1 = yes  |  2 = no';
        elseif strcmp(thisEncRun.Context(curTrial), 'context_004.jpg')
            message = 'Does this object float?\n\n1 = yes  |  2 = no';
        end

        % if this is the start of a new mini block..
        if thisEncRun.MiniBlock(curTrial) ~= prevMiniBlock;

            % Display Encoding Message Appropriate to this Context
            DrawFormattedText(W, message, 'center', 'center');
            Screen('Flip', W);
            WaitSecs(instrScrTime * fast);

        end
    
    %-- Figure out the Border Color
    
        % If this is a negative trial, make the border color red. If it 
        % is a neutral trial, make the border color black
        if strcmp(thisEncRun.Emotion(curTrial), 'Negative')
            bordcolor = [255 0 0];
        elseif strcmp(thisEncRun.Emotion(curTrial), 'Neutral')
            bordcolor = [0 0 0];
        end
    
    %-- Draw the Background Context
    
        % Where is the Context Stimuli going?
        ImageRect = CenterRectOnPoint([0 0 1200 800], X/2, Y/2);
        
        % Draw Context Stimuli
        Screen('DrawTexture', W, thisEncRun.ContextimID(curTrial), [], ImageRect);              
        
        % Flip Screen WITHOUT clearing the buffer afterwards (see Screen 
        % Flip documentation) and Wait "conTime"
        Screen(W, 'Flip', [], 1);
        WaitSecs(conTime * fast);
        
    %-- Draw the Item on Top of the Context

        % Where is the Item Stimuli going?
        ImageRect = CenterRectOnPoint([0 0 ImgSize ImgSize], X/2, Y/2);
        
        % Draw Item Stimuli
        Screen('DrawTexture', W, thisEncRun.ItemimID(curTrial), [], ImageRect);
        
        % Flush and start the Psychtoolbox Keyboard Queue. See KbQueue*
        % documentation
        KbQueueFlush(rep_device);
        KbQueueStart(rep_device);
        
        % Flip Screen WITHOUT clearing the buffer afterwards (see Screen 
        % Flip documentation) and Record the Onset Time
        OnsetTime(curTrial) = Screen(W, 'Flip', [], 1);
        
        % Wait "picTime"
        WaitSecs(picTime * fast);
        
    %-- Draw Item Border
        
        % Border
        border = [X/2-ImgSize/2-10 Y/2-ImgSize/2-10 X/2+ImgSize/2+10 Y/2+ImgSize/2+10];
    
        % Draw Item Border
        Screen('FrameRect', W, bordcolor, border, 10);
        
        % Flip Screen and wait 1 second
        Screen(W, 'Flip');
        WaitSecs(1);
        
    %-- Play Sound When Appropriate
        
        % If this is a scheduled noise trial...
        if thisEncRun.Noise(curTrial) && strcmp(thisEncRun.Emotion(curTrial), 'Negative')

            PsychPortAudio('Start', E_pahandle, repetitions, 0);         % play aversive white noise burst

        elseif thisEncRun.Noise(curTrial) && strcmp(thisEncRun.Emotion(curTrial), 'Neutral')

            PsychPortAudio('Start', N_pahandle, repetitions, 0);         % play neutral tone

        end
        
        % Wait 1 Second
        WaitSecs(1);
        
    %-- Record Responses
    
        [resp{curTrial}, resp_time(curTrial)] = record_responses();
                
    %-- Post Trial ISI
    
        % Where is the Context Stimuli going?
        ImageRect = CenterRectOnPoint([0 0 1200 800], X/2, Y/2);
        
        % Draw Context Stimuli
        Screen('DrawTexture', W, thisEncRun.ContextimID(curTrial), [], ImageRect);    
        
        % Draw fixation cross, flip the screen, and wait "fixTime"
        Screen(W, 'Flip');
        WaitSecs(fixTime * fast);
        
    %-- Post Trial Cleanup
        
        % Update the prevMiniBlock tracker
        prevMiniBlock = thisEncRun.MiniBlock(curTrial);
        
        % Flush the KbQueue as a precation (note: this command isn't
        % entirely necessary, as the KbQueue is flushed prior to recording
        % responses
        KbQueueFlush(rep_device);
        
end

%% 
%==========================================================================
%                       Post Run Fixation
%==========================================================================
% Draw a fixation cross to the exact center of the screen. Update the 
% display and wait 2 seconds before advancing

Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);
Screen(W, 'Flip');
WaitSecs(postFix * fast);

% Release the KbQueue. See KbQueue* documentation
KbQueueRelease(rep_device);

%%
%==========================================================================
%				Write Out Results
%==========================================================================
% Write out the results of this encoding run. Add 4 relevant variables to
% the encoding list:
%
%   Onset:     the moment in time, relative to the start of the run, that
%              this trial began
%
%   resp:      the key that was hit during this trial
%
%   resp_time: the moment in time, relative to the start of the run, 
%                 that a response was made
%
%   rt:        the participants reaction time, calculated as resp_time -
%              Onset
%
%   subj:      the subject's ID

thisEncRun.Onset     = OnsetTime' - expstart;
thisEncRun.resp      = resp';
thisEncRun.resp_time = resp_time' - expstart;
thisEncRun.rt        = resp_time' - OnsetTime';
thisEncRun.subj      = repmat({subject}, height(thisEncRun), 1);

% Write the Enc List for this round to a .csv file in the local directory 
% "./data"
writetable(thisEncRun, fullfile('.','data',['emoticon_encoding_' subject '_' num2str(enccount) '_' TimeStamp '.csv']));