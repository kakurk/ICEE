function retrieval(RetrievalList, iRun, triggerTime)
%% ICEE Retreival:
% Called by icee.m
% Written by Kyle Kurkela, kyleakurkela@gmail.com June 2017

%%
%==========================================================================
%				Settings
%==========================================================================

% Establish global variables
    
    global W X Y 
    global Fast Subject TimeStamp

%-- Instructions

    % trial-by-trial instructions
    trial_instructions      = 'Did this face and scene appear together previously?';
    response_scale          = 'Yes                                                No';

%-- Emoticon Specific Settings

    % Size of the stimuli, in pixels
    FaceSize      = [256 256];
    SceneSize     = [640 480];
    
    % How much to offset the scene image away from the center.
    offset        = 200;
    
    % The amount of time the pre run fixation is displayed (s)
    preFix        = 2;
    
    % The amount of time the post run fixation is displayed (s)
    postFix       = 2;
    
%-- a vector of the trial indices to run in RetrievalList
    
    trials2run = find(RetrievalList.Run == iRun)';    

%-- Initialize Response Recorder Variables

    % ITEM
    OnsetTime = zeros(1, length(trials2run));
    Response  = cell(1, length(trials2run));
    RespTime  = zeros(1, length(trials2run));

%-- Create the Keyboard Queue (see KbQueue documentation), restricting
%   responses
    
    rep_device           = 1;
    keylist              = zeros(1, 256);
    keys2record          = [KbName('1!') KbName('2@') KbName('escape')];
    keylist(keys2record) = 1;
    KbQueueCreate(rep_device, keylist);

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
Screen('Flip', W);
WaitSecs(preFix * Fast);

%%
%==========================================================================
%				Routine
%==========================================================================
% Retreival Routine

count = 0;
% For each trial in thisRetRun...
for curTrial = trials2run
    
    count = count + 1;
        
    %-- Trial Parameters
    
        trialTime    = RetrievalList.StimulusDuration(curTrial)/1000;
        fixationTime = RetrievalList.FixationDuration(curTrial)/1000;
        
        if strcmp(RetrievalList.Present(curTrial), 'SideBySide')
            
            if strcmp(RetrievalList.SceneOrFaceLeft(curTrial), 'FaceLeft')
            
                Side = RectLeft;
                off  = offset;
                
            elseif strcmp(RetrievalList.SceneOrFaceLeft(curTrial), 'SceneLeft')
            
                Side   = RectRight;
                off    = -offset;
                
            end
            
        elseif strcmp(RetrievalList.Present(curTrial), 'Superimposed')
            
            Side   = RectBottom;
            off    = 0;
            
        end
    
    %-- Draw the Context
    
        % Where is the Context Stimuli going?
        SceneRect    = CenterRectOnPoint([0 0 SceneSize], X/2, Y/2);
        SceneRect    = OffsetRect(SceneRect, off, 0);
        
        % Draw Context Stimuli
        Screen('DrawTexture', W, RetrievalList.Sceneid(curTrial), [], SceneRect);              
        
    %-- Draw the Item

        % Where is the Item Stimuli going?
        FaceRect = CenterRectOnPoint([0 0 FaceSize], X/2, Y/2);
        if strcmp(RetrievalList.Present(curTrial), 'Superimposed')
            FaceRect = AlignRect(FaceRect, SceneRect, Side);
        else
            FaceRect = AdjoinRect(FaceRect, SceneRect, Side);
        end
        
        % Draw Item Stimuli
        Screen('DrawTexture', W, RetrievalList.Faceid(curTrial), [], FaceRect);
        
    %-- Draw the Text
    
        % Trial Instructions
        [~, ny, bbox] = DrawFormattedText(W, trial_instructions, 'center', SceneRect(RectBottom) + 100);
        bboxH = RectHeight(bbox); % height of the text box
        
        % Scale
        DrawFormattedText(W, response_scale, 'center', ny + bboxH + 10);     
        
    %-- Start KbQueue and Flip Screen      
        
        % Flush and start the Psychtoolbox Keyboard Queue. See KbQueue*
        % documentation
        KbQueueFlush(rep_device);
        KbQueueStart(rep_device);
        
        % Flip Screen and Record Onset Time
        OnsetTime(count) = Screen(W, 'Flip');
        
        % Wait "picTime"
        WaitSecs(trialTime * Fast);      
        
    %-- Post Trial Fixation
        
        % Draw Fixation Dot
        Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
        Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);
        
        % Flip Screen
        Screen(W, 'Flip');
        
        % Wait fixTime
        WaitSecs(1 * Fast);
        
    %-- Record Responses
    
        [Response{count}, RespTime(count)] = record_responses(rep_device);
        
        % Wait rest of fixationTime
        WaitSecs(fixationTime - 1 * Fast);

end

%% 
%==========================================================================
%                       Post Run
%==========================================================================

Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);      
Screen('Flip', W);
WaitSecs(postFix * Fast);

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

thisRetRun = RetrievalList(RetrievalList.Run == iRun, :);

% ITEM
thisRetRun.Onset        = OnsetTime' - triggerTime;
thisRetRun.Response     = Response';
thisRetRun.ResponseTime = RespTime' - triggerTime;
thisRetRun.rt           = RespTime' - OnsetTime';

thisRetRun.subj         = repmat({Subject}, height(thisRetRun), 1);

% Write the ret List for this round to a .csv file in the local directory 
% "./data"
writetable(thisRetRun, fullfile('.','data',['icee_retrieval_' Subject '_' num2str(iRun) '_' TimeStamp '.csv']));

end