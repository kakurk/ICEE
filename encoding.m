function [] = encoding(Encoding, run)
%% ICEE Encoding:
% Called by icee.m
% Written by Kyle Kurkela, kyleakurkela@gmail.com June 2017

%%
%==========================================================================
%				Settings
%==========================================================================

%-- Instructions
    
    % Instructions Message
    instructions = {
        'View Round\n\nAnswer the questions as quickly and accurately as you can'
    };

    % trial-by-trial instructions
    trial_instructions      = 'How welcoming are the scene and face?';
    response_scale          = '1                2               3               4';
    response_scale_descript = 'not at all                                    very';
    
%-- ICEE Settings

    % Size of the stimuli, in pixels
    FaceSize      = [256 256];
    SceneSize     = [640 480];
    
    % How much to offset the scene image away from the center.
    offset        = 200;
    
    % The amount of time the pre run fixation is displayed (s)
    preFix        = 2;
    
    % The amount of time the post run fixation is displayed (s)
    postFix       = 2;
    
%-- Define trials to run
    
    trials2run = find(Encoding.Run == run)';
    
%-- Initialize Response Recorder Variables

    OnsetTime    = zeros(1, length(trials2run));
    resp         = cell(1, length(trials2run));
    resp_time    = zeros(1, length(trials2run));

%-- Create the Keyboard Queue (see KbQueue documentation), restricting
%   responses to the ENC_keylist keys (see init_psychtoolbox)
    rep_device                           = -1;
    keylist                              = zeros(1, 256);
    keylist([KbName('1!') KbName('2@') KbName('3#') KbName('4$')]) = 1;
    KbQueueCreate(rep_device, keylist)
    
%-- Establish global variables

    global W X Y fast

%%
%==========================================================================
%				Instructions
%==========================================================================
% Display instructions and wait for a participant's response before 
% continuing. Please see instructions_screen documentation for more 
% details. Written in a for loop to display multiple instructions screens,
% if desired.

for i = 1:length(instructions)
    
    instructions_screen(instructions{i}, ' ', 'n', [KbName('1!')]);
    
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

% For each trial to run...
for curTrial = trials2run
    
    %-- Trial Parameters
    
        trialTime    = Encoding.StudyStimulus_Duration(curTrial) / 1000;
        fixationTime = Encoding.Fixation_Duration(curTrial) / 1000;
        
        if strcmp(Encoding.EncodingCond(curTrial), 'II')
            
            if strcmp(Encoding.SceneOrFaceLeft(curTrial), 'FaceLeft')
            
                Side = RectLeft;
                off  = offset;
                
            elseif strcmp(Encoding.SceneOrFaceLeft(curTrial), 'SceneLeft')
            
                Side   = RectRight;
                off    = -offset;
                
            end
            
        elseif strcmp(Encoding.EncodingCond(curTrial), 'IC')
            
            Side   = RectBottom;
            off    = 0;
            
        end
    
    %-- Draw the Context
    
        % Where is the Context Stimuli going?
        SceneRect    = CenterRectOnPoint([0 0 SceneSize], X/2, Y/2);
        SceneRect    = OffsetRect(SceneRect, off, 0);
        
        % Draw Context Stimuli
        Screen('DrawTexture', W, Encoding.SceneStimid(curTrial), [], SceneRect);              
        
    %-- Draw the Item

        % Where is the Item Stimuli going?
        FaceRect = CenterRectOnPoint([0 0 FaceSize], X/2, Y/2);
        if strcmp(Encoding.EncodingCond(curTrial), 'IC')
            FaceRect = AlignRect(FaceRect, SceneRect, Side);
        else
            FaceRect = AdjoinRect(FaceRect, SceneRect, Side);
        end
        
        % Draw Item Stimuli
        Screen('DrawTexture', W, Encoding.FaceStimid(curTrial), [], FaceRect);
        
    %-- Draw the Text
    
        % Trial Instructions
        [~, ny, bbox] = DrawFormattedText(W, trial_instructions, 'center', SceneRect(RectBottom) + 100);
        bboxH = RectHeight(bbox); % height of the text box
        
        % Scale
        [~, ny, ~] = DrawFormattedText(W, response_scale, 'center', ny + bboxH + 10);
        
        % Scale Description
        DrawFormattedText(W, response_scale_descript, 'center', ny + bboxH + 10);
        
        % Flush and start the Psychtoolbox Keyboard Queue. See KbQueue*
        % documentation
        KbQueueFlush(rep_device);
        KbQueueStart(rep_device);
        
        % Flip Screen and Record the Onset Time
        OnsetTime(curTrial) = Screen(W, 'Flip');
        
        % Wait "trialTime"
        WaitSecs(trialTime * fast);
        
    %-- Post Trial Fixation
    
        % Draw fixation dot, flip the screen, and wait 1
        Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
        Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);        
        Screen(W, 'Flip');
        WaitSecs(1 * fast);
        
        % Record Responses
        [resp{curTrial}, resp_time(curTrial)] = record_responses();
        
        % Wait the rest of the sceduled fixation time
        WaitSecs((fixationTime - 1) * fast);
        
    %-- Post Trial Cleanup
        
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

thisEncRun              = Encoding(Encoding.Run == run, :);

thisEncRun.Onset        = OnsetTime' - expstart;
thisEncRun.Response     = resp';
thisEncRun.ResponseTime = resp_time' - expstart;
thisEncRun.rt           = resp_time' - OnsetTime';
thisEncRun.SubjectID    = repmat({subject}, height(thisEncRun), 1);

% Write the Enc List for this round to a .csv file in the local directory 
% "./data"
writetable(thisEncRun, fullfile('.','data',['icee_encoding_' subject '_' num2str(run) '_' TimeStamp '.csv']));

end