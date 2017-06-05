function [] = encoding(EncodingList, iRun, triggerTime)
%% ICEE Encoding:
% Called by icee.m
% Written by Kyle Kurkela, kyleakurkela@gmail.com June 2017

%%
%==========================================================================
%				Settings
%==========================================================================

%-- Establish global variables
    
    % PTB Window Parameters
    global W X Y
    
    % Experiment Parameters
    global Fast Subject TimeStamp

%-- Instructions

    % trial-by-trial instructions
    trial_instructions      = 'How welcoming are the scene and face?';
    response_scale          = '1                2               3               4';
    response_scale_descript = 'not at all                                    very';
    
%-- ICEE Settings

    % Size of the stimuli, in pixels
    FaceSize      = [256 256];
    SceneSize     = [640 480];
    
    % How much to offset the scene image away from the center of the screen
    % in the x-axis (i.e., left and right) in the II condition
    offset        = 200;
    
    % Item-Item Buffer, in pixels
    itemitemBuffer = 50;
    
    % The amount of time the pre-run fixation is displayed (s)
    preFix        = 2;
    
    % The amount of time the post-run fixation is displayed (s)
    postFix       = 2;
    
%-- A vector of the indices of the Encoding List to run
    
    trials2run = find(EncodingList.Run == iRun)';
    
%-- Initialize Response Recorder Variables

    OnsetTime    = zeros(1, length(trials2run));
    resp         = cell(1, length(trials2run));
    resp_time    = zeros(1, length(trials2run));

%-- Create the Keyboard Queue (see KbQueue documentation), restricting
%   responses to the `keylist` keys.
%       rep_device = a number, which corresponds to the device which
%                    corresponds to the button box
%       keys2record = a vector of the Keyboard Keys to record during each
%                     trial
    rep_device           = 1;
    keys2record          = [KbName('1!') KbName('2@') KbName('3#') KbName('4$')];
    
    keylist              = zeros(1, 256);
    keylist(keys2record) = 1;
    KbQueueCreate(rep_device, keylist)

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
Screen('Flip', W);
WaitSecs(preFix * Fast);

%%
%==========================================================================
%				Routine
%==========================================================================
% Encoding Routine

% For each trial to run...
for curTrial = trials2run
    
    %-- Trial Parameters
    
        % timing parameters
        trialTime    = EncodingList.StudyStimulus_Duration(curTrial) / 1000;
        fixationTime = EncodingList.Fixation_Duration(curTrial) / 1000;
        
        % condition parameters
        if strcmp(EncodingList.EncodingCond(curTrial), 'II')
            
            if strcmp(EncodingList.SceneOrFaceLeft(curTrial), 'FaceLeft')
            
                Side     = RectLeft;
                off      = offset;
                IIbuffer = -itemitemBuffer;
                
            elseif strcmp(EncodingList.SceneOrFaceLeft(curTrial), 'SceneLeft')
            
                Side     = RectRight;
                off      = -offset;
                IIbuffer = itemitemBuffer;
                
            end
            
        elseif strcmp(EncodingList.EncodingCond(curTrial), 'IC')
            
            Side   = RectBottom;
            off    = 0;
            
        end
    
    %-- Draw the Context
    
        % Where is the Context Stimuli going?
        SceneRect    = CenterRectOnPoint([0 0 SceneSize], X/2, Y/2);
        SceneRect    = OffsetRect(SceneRect, off, 0);
        
        % Draw Context Stimuli
        Screen('DrawTexture', W, EncodingList.SceneStimid(curTrial), [], SceneRect);              
        
    %-- Draw the Item

        % Where is the Item Stimuli going?
        FaceRect = CenterRectOnPoint([0 0 FaceSize], X/2, Y/2);
        if strcmp(EncodingList.EncodingCond(curTrial), 'IC')
            FaceRect = AlignRect(FaceRect, SceneRect, Side);
        else
            FaceRect = AdjoinRect(FaceRect, SceneRect, Side);
            FaceRect = OffsetRect(FaceRect, IIbuffer, 0);            
        end
        
        % Draw Item Stimuli
        Screen('DrawTexture', W, EncodingList.FaceStimid(curTrial), [], FaceRect);
        
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
        WaitSecs(trialTime * Fast);
        
    %-- Post Trial Fixation
    
        % Draw fixation dot, flip the screen, and wait 1
        Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
        Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);        
        Screen(W, 'Flip');
        WaitSecs(1 * Fast);
        
        % Record Responses
        [resp{curTrial}, resp_time(curTrial)] = record_responses(rep_device);
        
        % Wait the rest of the sceduled fixation time
        WaitSecs((fixationTime - 1) * Fast);
        
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
WaitSecs(postFix * Fast);

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

thisEncRun              = EncodingList(EncodingList.Run == iRun, :);

thisEncRun.Onset        = OnsetTime' - triggerTime;
thisEncRun.Response     = resp';
thisEncRun.ResponseTime = resp_time' - triggerTime;
thisEncRun.rt           = resp_time' - OnsetTime';
thisEncRun.SubjectID    = repmat({Subject}, height(thisEncRun), 1);

% Write the Enc List for this round to a .csv file in the local directory 
% "./data"
writetable(thisEncRun, fullfile('.','data',['icee_encoding_' Subject '_' num2str(iRun) '_' TimeStamp '.csv']));

end