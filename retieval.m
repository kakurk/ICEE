%% EMOTICON Retreival:
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
        'Remember Round\n\nMake your memory decisions as quickly and accurately as you can'
    };

%-- Emoticon Specific Settings

    % Size of the item stimuli, in pixels (i.e., as a n x n square)
    ImgSize      = 256;

    % The amount of time post-trial fixations are displayed
    fixTime      = 2;

    % The amount of time the item memory question is displayed
    picTime      = 2.5;

    % The amount of time the emotional association question is displayed
    emoTime      = 2;

%-- Initialize Response Recorder Variables

    % ITEM
    ITEM_OnsetTime = zeros(1, height(thisRetRun));
    ITEM_resp      = cell(1, height(thisRetRun));
    ITEM_RespTime  = zeros(1, height(thisRetRun));

    % EMO
    EMO_OnsetTime  = zeros(1, height(thisRetRun));
    EMO_resp       = cell(1, height(thisRetRun));
    EMO_RespTime   = zeros(1, height(thisRetRun));

%-- Create the Keyboard Queue (see KbQueue documentation), restricting
%   responses
    
    rep_device = -1;
    keylist = zeros(1, 256);
    keylist([KbName('1!') KbName('2@') KbName('3#') KbName('4$')]) = 1;
    KbQueueCreate(rep_device, keylist);
    
% Establish global variables
    
    global W X Y

%%
%==========================================================================
%				Instructions
%==========================================================================
% Display instructions and wait for a one of the instructions keys (i.e.,
% IN_keylist, see init_psychtoolbox). Written in a for loop to display
% multiple instructions screens, if desired.

for i = 1:length(instructions)
    
    instructions_screen(instructions{i}, directions, YN.instructAutoSkip);
    
end

%%
%==========================================================================
%				Pre Run Fixation
%==========================================================================
% Draw a fixation cross to the exact center of the screen. Update the 
% display and record the moment the fixation dot was displayed in the 
% variable "expstart". "expstart" will mark the beginning of the this run.
% Display this fixation cross for 2 seconds

Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);      
expstart = Screen('Flip', W);
WaitSecs(2 * fast);

%%
%==========================================================================
%				Routine
%==========================================================================
% Retreival Routine

% For each trial in thisRetRun...
for curTrial = 1:height(thisRetRun)
    
    %-- Context Preexposure

        % Where is the Context stimuli going?
        ImageRect = CenterRectOnPoint([0 0 1200 800], X/2, Y/2);
        
        % Draw Context
        Screen('DrawTexture', W, thisRetRun.ContextimID(curTrial), [], ImageRect);
        
        % Flip Screen WITHOUT clearing the buffer (see Screen Flip
        % documentation) and wait 1/2 of a second
        Screen(W, 'Flip', [], 1);
        WaitSecs(0.5);
        
    %-- Draw the Item on Top of Context

        % Where is the Item stimuli going?
        ImageRect = CenterRectOnPoint([0 0 ImgSize ImgSize], X/2, Y/2);
        
        % Draw Item
        Screen('DrawTexture', W, thisRetRun.ItemimID(curTrial), [], ImageRect);
        
    %-- Draw ITEM Task Message
        
        % Task Message
        message = 'Remember?\n\n1 = Def New      |     2 = Prob New     |   3 = Prob Old   |   4 = Def Old';
        
        % Draw Task Message
        DrawFormattedText(W, message, 'center', 9*(Y/10));
        
    %-- Start KbQueue and Flip Screen      
        
        % Flush and start the Psychtoolbox Keyboard Queue. See KbQueue*
        % documentation
        KbQueueFlush(rep_device);
        KbQueueStart(rep_device);
        
        % Flip Screen and Record Onset Time
        ITEM_OnsetTime(curTrial) = Screen(W, 'Flip');
        
        % Wait "picTime"
        WaitSecs(picTime * fast);
        
    %-- Record Responses
    
        [ITEM_resp{curTrial}, ITEM_RespTime(curTrial)] = record_responses();
    
    %-- Optional Emotional Source Question
        
        if any(strcmp(ITEM_resp{curTrial}, {'3#' ,'4$'}))

            %--Draw the Context Image

                % Where is the context stimuli going?
                ImageRect = CenterRectOnPoint([0 0 1200 800], X/2, Y/2);

                % Draw Context
                Screen('DrawTexture', W, thisRetRun.ContextimID(curTrial), [], ImageRect);    

            %--Draw the Item on top of Context

                % Where is the Item stimuli going?
                ImageRect = CenterRectOnPoint([0 0 ImgSize ImgSize], X/2, Y/2);

                % Draw Item
                Screen('DrawTexture', W, thisRetRun.ItemimID(curTrial), [], ImageRect);

            %-- Draw Task Message

                % Task Message
                message = 'Safe or Startle?\n\n1 = Def Safe      |     2 = Prob Safe     |   3 = Prob Startle   |   4 = Def Startle';

                % Draw Task Message
                DrawFormattedText(W, message, 'center', 9*(Y/10));
                
            %-- Start KbQueue and Flip Screen

                % Flush and start the Psychtoolbox Keyboard Queue. See KbQueue*
                % documentation
                KbQueueFlush(rep_device);
                KbQueueStart(rep_device);

                % Flip Screen and Record Onset Time
                EMO_OnsetTime(curTrial) = Screen(W, 'Flip');

                % Wait "emoTime"
                WaitSecs(emoTime * fast);

            %-- Record Responses
            
                [EMO_resp{curTrial}, EMO_RespTime(curTrial)] = record_responses();
            
        end
        
    %-- Post Trial Fixation
        
        % Draw Fixation Dot
        Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
        Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);
        
        % Flip Screen
        Screen(W, 'Flip');
        
        % Wait fixTime
        WaitSecs(fixTime * fast);

end

%% 
%==========================================================================
%                       Post Run
%==========================================================================

% Release the KbQueue. See KbQueue* documentation
KbQueueRelease(rep_device);

%%
%==========================================================================
%				Write Out Results
%==========================================================================
% Write out the results of this retrieval run. Add 5 relevant variables to
% the retrieval list:
%
%   Onset:     the moment in time, relative to the start of the run, that
%              this trial began
%
%   resp:      the key that was hit during this trial
%
%   resp_time: the moment in time, relative to the start of the run, 
%                 that a response was made
%
%   rt:        the participants reaction time, calculated as Onset -
%              resp_time
%
%   subj:      the subject's ID

% ITEM
thisRetRun.ITEMOnset     = ITEM_OnsetTime' - expstart;
thisRetRun.ITEMresp      = ITEM_resp';
thisRetRun.ITEMresp_time = ITEM_RespTime' - expstart;
thisRetRun.ITEMrt        = ITEM_RespTime' - ITEM_OnsetTime';

% EMO
thisRetRun.EMOOnset     = EMO_OnsetTime' - expstart;
thisRetRun.EMOresp      = EMO_resp';
thisRetRun.EMOresp_time = EMO_RespTime' - expstart;
thisRetRun.EMOrt        = EMO_RespTime' - EMO_OnsetTime';

thisRetRun.subj         = repmat({subject}, height(thisRetRun), 1);

% Write the ret List for this round to a .csv file in the local directory 
% "./data"
writetable(thisRetRun, fullfile('.','data',['emoticon_retreival_' subject '_' num2str(retcount) '_' TimeStamp '.csv']));