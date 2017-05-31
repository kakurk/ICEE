function [Encoding, Retrieval, FindTheBoop] = generate_lists(StimuliDir)
% generate_lists    function for generating pesudorandomized trial lists
%                   for the encoding, retrieval, and find phases of 
%                   EMOTICON
%
%
% See also 

%%
%==========================================================================
%                   Initalize The Encoding List
%==========================================================================
%%% Initalize the Encoding list with 256 items from the Stimuli Directory

Items    = dir_regexp(StimuliDir, 'item\w*[0-9]{1}\.jpg');
Encoding = table(cell(256,1), cell(256,1), 'VariableNames', {'ID' 'ImageFile'});

for s = 1:256
   Encoding.ID{s}        = Items(s).name;
   Encoding.ImageFile{s} = fullfile('.', 'stim', Items(s).name);
end

%%
%==========================================================================
%             Assign Stimuli Emotional Valences and Contexts
%==========================================================================
%%% Each Item will received an Emotional Valence (netural, negative) and a
%%% context (A, B, C, D), such that contexts A and B will recieve X% of
%%% negative items and contexts C and D will receive 1-X% of negative items

% Hardcode in Valences
Emotions = {'Neutral', 'Negative'};

% Randomly pick 4 contexts
Contexts = dir_regexp(StimuliDir, 'context\w*\.jpg');
Contexts = datasample({Contexts.name}, 4, 'Replace', false);

% Initalize "Emotion" and "Context" Variables in the Encoding Table
Encoding.Emotion          = cell(height(Encoding), 1);
Encoding.Context          = cell(height(Encoding), 1);
Encoding.ContextID        = zeros(height(Encoding), 1);
Encoding.ContextImageFile = cell(height(Encoding), 1);
Encoding.ContextEmoProp   = zeros(height(Encoding), 1);
Encoding.Properties.UserData = table(zeros(4, 1), zeros(4, 1), cell(4,1), 'VariableNames', {'ContextID' 'ContextEmoProp' 'ContextImageFile'});

% Initalize an Already Assigned (AA) filter, which keeps track of which
% trials have already been assigned a condition and context
AAfilter = true(1,height(Encoding));

% Initalize an c (context) Count variable, to keep track of which context
% we are currently on
cCount = 0;

% For each selected Context, randomly permuated...
for c = randperm(length(Contexts))

    % Advance the cCounter
    cCount = cCount + 1;
    
    if (cCount == 1 || cCount == 2)
        index_propor = .75;
        Encoding.Properties.UserData.ContextID(cCount) = cCount;
        Encoding.Properties.UserData.ContextEmoProp(cCount) = index_propor;
    elseif (cCount == 3 || cCount == 4)
        index_propor = .25;
        Encoding.Properties.UserData.ContextID(cCount) = cCount;
        Encoding.Properties.UserData.ContextEmoProp(cCount) = index_propor;
    end    
    
    % For both emotional valences..
    for e = Emotions
        
        % Calculate the number of trials getting a "e" "c" assignment
        if (cCount == 1 || cCount == 2) && strcmp(e, 'Negative') % the first two randomly selected Contexts will receive majority Negative
            proportion = .75;
        elseif (cCount == 3 || cCount == 4) && strcmp(e, 'Neutral') % the last two randomly selected Contexts will receive majority Neutral
            proportion = .75;
        else
            proportion = .25;
        end
        
        % Find all unassigned trials, grab a randomsample of them for
        % assignment, create a filter of those trials selected for 
        % assginemnt
        idxs               = find(AAfilter);
        assignment         = sort(datasample(idxs, 256/4 * proportion, 'Replace', false))';
        filter             = false(height(Encoding),1);
        filter(assignment) = true;
        
        % Assign these trials Emotional Valences, Contexts, Context IDs,
        % and ContextImageFiles
        Encoding.Emotion(filter)          = repmat(e, 256/4 * proportion, 1)';
        Encoding.Context(filter)          = repmat(Contexts(c), 256/4 * proportion, 1);
        relpath                           = repmat({'./stim/'}, 256/4 * proportion, 1);
        Encoding.ContextImageFile(filter) = strcat(relpath, Encoding.Context(filter));
        Encoding.ContextID(filter)        = repmat(cCount, 256/4 * proportion, 1);
        Encoding.ContextEmoProp(filter)   = repmat(index_propor, 256/4 * proportion, 1);
        Encoding.Properties.UserData.ContextImageFile(cCount) = unique(strcat(relpath, Encoding.Context(filter)));
        
        % Remove these trials from the Already Assigned trial filter
        AAfilter(assignment) = false;
        
    end
end

% Sort the Encoding List by Context and Emotional Valence
Encoding = sortrows(Encoding, {'ContextID' 'Emotion'});

%%
%==========================================================================
%                 Assign Trials to Mini Blocks
%==========================================================================
%%% Now that we have assigned items to Experimental Conditions, 
%%% we now need to assign these trials to Mini Blocks such that mini blocks
%%% are homgenous for context

% Initalize a new table variable "MiniBlock" that is all zeros, a counter
% variable, and an Already Assigned Filter
Encoding.MiniBlock = zeros(height(Encoding), 1);
contextcount       = 0;
AAFilter           = true(height(Encoding),1);

% For each encoding context, build 32 miniblocks such that 2 of the 
% contexts have majority Negative trials and 2 of the contexts of majority
% Neutral trials. Note: 8 miniblocks was formulated based on the following:
%
%   Total Stimuli: 256 (see Encoding Table generate above)
%   Stimuli per Mini Block: 4
%   Total Mini Blocks: 256/4 = 64
%   Total MiniBlocks per Context: 64/4 = 16

for cont = unique(Encoding.ContextID)';
    for mb = 1:16
        contextcount = contextcount + 1;
        for e = Emotions

            % Calculate the number of trials getting a "e" "c" assignment,
            % see above
            if (cont == 1 || cont == 2) && strcmp(e, 'Negative')
                proportion = .75;
            elseif (cont == 3 || cont == 4) && strcmp(e, 'Neutral')
                proportion = .75;
            else
                proportion = .25;
            end

            % filter for stimuli that are assigned this context
            filter   = Encoding.ContextID == cont .* strcmp(Encoding.Emotion, e);

            % filter this filter by the Already Assigned filter, removing
            % rows that were already assigned a MiniBlock
            filter    = filter .* AAFilter;      

            % find the indices of the rows that made it through the filter
            matches   = find(filter);

            % grab a random sample of matched rows for assignment to
            % this MiniBlock, updating the Encoding List's Mini Block
            % variable
            selfilter                     = sort(datasample(matches, proportion * 4, 'Replace', false))';
            Encoding.MiniBlock(selfilter) = repmat(contextcount, proportion * 4, 1);

            % Adjust a second filter to prevent selection of already
            % assigned rows            
            AAFilter(selfilter) = false;
            
        end
    end
end 

% Sort the rows of the Encoding List by MiniBlock
Encoding = sortrows(Encoding, 'MiniBlock');

%%
%==========================================================================
%              Assigning Mini Blocks to Encoding Rounds
%==========================================================================
%%% Now that we have assigned trials to Mini Blocks, we now need to assign 
%%% Mini Blocks to different encoding runs such that there is a 3 mini
%%% blocks of each context in each round

% Initalize an RunID variable in the Encoding List
Encoding.RunID = zeros(height(Encoding), 1);

% For each of 4 hardcorded encoding runs...
for r = 1:4
    for con = Contexts

        % Build a filter of MiniBlocks that have NOT already been
        % assgined an encoding run
        NAfilter        = Encoding.RunID == 0;

        % filter for stimuli that are assigned this Context
        filter          = strcmp(Encoding.Context, con);

        % Remove rows that have been already assgined rows from this
        % filter
        filter          = filter .* NAfilter;

        % Randomly select three Mini Blocks that survived the above
        % filtering process and assign them to this run
        MBpossibilities = unique(Encoding.MiniBlock(logical(filter)));
        MBselection     = datasample(MBpossibilities, 3, 'Replace', false);
        MBfilter        = false(height(Encoding), 1);
        for mmbb = 1:length(MBselection)
            MBfilter = MBfilter + (Encoding.MiniBlock == MBselection(mmbb));
        end
        Encoding.RunID(logical(MBfilter)) = repmat(r, 12, 1);

    end
end

% Seperate out the unused Trials
Extras   = Encoding(Encoding.RunID == 0, :);
Encoding = Encoding(Encoding.RunID ~= 0, :);

% Sort by Encoding Run
Encoding = sortrows(Encoding, 'RunID');

%%
%==========================================================================
%                 Randomize Trial Order within MiniBlocks
%==========================================================================

for mb = unique(Encoding.MiniBlock)'
    
    % Filter for this mini block
    filter              = Encoding.MiniBlock == mb;
    
    % Randomize the order of the trials of this Mini Block
    Encoding(filter, :) = RandomizeRows(Encoding(filter,:));
    
end

%%
%==========================================================================
%                 Randomize MiniBlock Order within Runs
%==========================================================================

% For each run...
for r = unique(Encoding.RunID)'
    
    % Initalize Variables
    thisRun      = Encoding(Encoding.RunID == r, :);           % this Run of the table
    contextcount = 0;                                          % counter variable keeping track of Mini Blocks 
    thisRunCell  = cell(length(unique(thisRun.MiniBlock)), 1); % a cell array to temporarily house the mini blocks

    % Cycle through mini blocks, putting them into temporary cell array
    for mb = unique(thisRun.MiniBlock)'
        contextcount = contextcount + 1;
        filter  = thisRun.MiniBlock == mb;
        thisRunCell{contextcount} = thisRun(filter, :);
    end
    
    % Randomize the order of this cell array
    thisRunCell = RandomizeRows(thisRunCell);
    
    % Reconcatenate the now randomized MiniBlocks and reassign it to the
    % Encoding List
    Encoding(Encoding.RunID == r, :) = vertcat(thisRunCell{:});
    
end

%%
%==========================================================================
%                       Add Noise Trials
%==========================================================================
%%% The Valence manipulation in EMOT-I-CON is the threat of a white noise
%%% burst on Negative trials and the possibility of a neutral tone on
%%% Neutral trials. To make this threat/saftey maniupluation successful, we
%%% need to assign trials that actually follow through with the threat.
%%% Following the lead of the MICE study, we assigned 1/8 of the trials to
%%% be noise trials, such that a noise trial occurs once in every context
%%% presented during the course of an encoding run

% Initalize a True/False Noise variable in the Encoding List
Encoding.Noise = false(height(Encoding), 1);

% For each Encoding Run..
for r = unique(Encoding.RunID)'
    
    % Initalize a run filter, a list of the emotional valences in the
    % study, and an empty selections vector
    rfilter = Encoding.RunID == r;
    emo     = unique(Encoding.Emotion(rfilter))';
    selections = [];
    
    % Pick 3 neutral trials and 3 negative trials to serve as noise trials,
    % making sure that participants CANNOT hear 2 noise trials within the
    % same mini block
    while isempty(selections) || length(Encoding.MiniBlock(selections)) < length(unique(Encoding.MiniBlock(selections)))
        selections = [];
        for e = emo
            efilter    = strcmp(Encoding.Emotion, e{:});
            grandfilt  = logical(efilter .* rfilter);
            poss       = find(grandfilt);
            selections = sort(vertcat(selections, datasample(poss, 3, 'Replace', false)));
            Encoding.Noise(selections) = true;
            
        end
    end
    
end

%%
%==========================================================================
%                   Initalize The Retrieval List
%==========================================================================
%%% Initalize the Retrieval list

Retrieval = Encoding(:, {'ID' 'ImageFile' 'Emotion' 'Context' 'ContextID' 'ContextEmoProp' 'ContextImageFile' 'RunID' 'Noise'});

%%
%==========================================================================
%            Assign Trials to Fine Grained Retrieval Conditions
%==========================================================================
%%% Assign all Retrieval trials within each run to the context shift 
%%% direction retrieval conditions

Retrieval.ShiftDirection = cell(height(Retrieval), 1);
Retrieval.Catch          = false(height(Retrieval), 1);
rcount = 0;

% For each run...
for run = Shuffle(unique(Retrieval.RunID)')
    rcount  = rcount + 1;
    rfilter = Retrieval.RunID == run;
    for emoprop = unique(Retrieval.ContextEmoProp)'
       emopropfilter = Retrieval.ContextEmoProp == emoprop;
        for emo = unique(Retrieval.Emotion)'
            emofilter = strcmp(Retrieval.Emotion, emo);
            
            % Calculate Filter
            filter    = logical(rfilter .* emopropfilter .* emofilter);
            idxs      = find(filter);
            numFound  = length(idxs);
            
            % Determine Appropriate Ret Conditions
            if strcmp(emo, 'Negative') && emoprop == .25
                
                RetConditions = {'NoShift Neutral', 'Neutral --> Negative', 'Neutral --> Neutral'};
                
            elseif strcmp(emo, 'Negative') && emoprop == .75
                
                RetConditions = {'NoShift Negative', 'Negative --> Neutral', 'Negative --> Negative'};
                
            elseif strcmp(emo, 'Neutral') && emoprop == .25
                
                RetConditions = {'NoShift Neutral', 'Neutral --> Negative', 'Neutral --> Neutral'};
                
            elseif strcmp(emo, 'Neutral') && emoprop == .75
                
                RetConditions = {'NoShift Negative', 'Negative --> Neutral', 'Negative --> Negative'};
                
            end
            
            % Assign Trials Retrieval Conditions
            retcount = 0;
            for ret = RetConditions
                
                retcount = retcount + 1;
                
                if rem(rcount, 2) > 0
                    if retcount == 3
                        continue
                    end
                else
                    if retcount == 2
                        continue
                    end
                end
                
                [selection, I] = datasample(idxs, numFound * 2/6 , 'Replace', false);
                Retrieval.ShiftDirection(selection) = ret;
                
                idxs = idxs(setdiff(1:end, I));
                
                [selection, I] = datasample(idxs, numFound * 1/6, 'Replace', false);
                Retrieval.ShiftDirection(selection) = ret;
                Retrieval.Catch(selection)        = true;
                
                idxs = idxs(setdiff(1:end, I));
                
            end
            
        end
    end
end

%%
%==========================================================================
%           Define Coarser Grained Shift Conditions
%==========================================================================
%%% Find grained Retrieval Conditions are contained within more coarse
%%% grained conditions. Here we want to define those coarse grained
%%% conditions

Retrieval.Condition        = cell(height(Retrieval), 1);
Retrieval.ContextSwitch    = cell(height(Retrieval), 1);

% for each trial...
for trial = 1:height(Retrieval)
    
    % Define Condition
    if strcmp(Retrieval.ShiftDirection(trial), 'NoShift Neutral') || strcmp(Retrieval.ShiftDirection(trial), 'NoShift Negative')
        Retrieval.Condition(trial) = {'Same'};
    else
        Retrieval.Condition(trial) = {'Different'};
    end
    
    % Define ContextSwitch
    if strcmp(Retrieval.Condition(trial), 'Different') 
        if strcmp(Retrieval.ShiftDirection(trial), 'Neutral --> Neutral') || strcmp(Retrieval.ShiftDirection(trial), 'Negative --> Negative')
            Retrieval.ContextSwitch(trial) = {'Within'};
        else
            Retrieval.ContextSwitch(trial) = {'Across'};
        end
    else
        Retrieval.ContextSwitch(trial) = {'NoShift'};
    end  
    
end

%%
%==========================================================================
%           Update Different Trials
%==========================================================================
%%% Trials in the different condition must be assigned a context that is
%%% different from the one that they were originally presented on

Retrieval.RetContext        = Retrieval.ContextImageFile;
Retrieval.RetContextEmoProp = Retrieval.ContextEmoProp;

% Define different trials, otherContexts, and a blank count variable
difftrials    = find(strcmp(Retrieval.Condition, 'Different'));
otherContexts = Retrieval.Properties.UserData;
    
% for different trial...
for trial = difftrials'
    if strcmp(Retrieval.ContextSwitch(trial), 'Across')
        
        otheremopropfilt = otherContexts.ContextEmoProp ~= Retrieval.ContextEmoProp(trial);
        
        poss             = find(otheremopropfilt);
        
        selection        = datasample(poss, 1, 'Replace', false);
        
        Retrieval.RetContext(trial)        = otherContexts.ContextImageFile(selection);
        Retrieval.RetContextEmoProp(trial) = otherContexts.ContextEmoProp(selection);
        
    elseif strcmp(Retrieval.ContextSwitch(trial), 'Within')
        
        emopropfilt        = otherContexts.ContextEmoProp == Retrieval.ContextEmoProp(trial);
        
        NOTthiscontextfilt = otherContexts.ContextID ~= Retrieval.ContextID(trial);
        
        selectionfilt = logical(emopropfilt .* NOTthiscontextfilt);
        
        Retrieval.RetContext(trial)        = otherContexts.ContextImageFile(selectionfilt);
        Retrieval.RetContextEmoProp(trial) = otherContexts.ContextEmoProp(selectionfilt);
        
    end
end

%%
%==========================================================================
%           Update Catch Trials
%==========================================================================
%%% Edit the image ID's of the catch trials so that the corresponding
%%% related lure is displayed at Retrieval

for image = unique(Retrieval.ID(Retrieval.Catch))'
    
    % Image Filter
    imagefilter = strcmp(Retrieval.ID, image);
    
    % Edit image ID
    [~, name, ext] = fileparts(image{:});
    Retrieval.ID(imagefilter) = {[name 'L' ext]};
    
    % Edit ImageFile
    ImageFile = Retrieval.ImageFile(imagefilter);
    [path, name, ext] = fileparts(ImageFile{:});
    Retrieval.ImageFile(imagefilter) = {[path filesep name 'L' ext]};

end

%%
%==========================================================================
%                 Add Unrelated Lures
%==========================================================================

% Update Extras Variables
Extras.Emotion(:)          = {'Unrelated Lure'};
Extras.MiniBlock           = [];
Extras.Context(:)          = {''};
Extras.ContextImageFile(:) = {''};
Extras.ContextID(:)        = 0;
Extras.ContextEmoProp(:)   = 0;

% Add New Ret Variables
Extras.Noise             = repmat(-1, height(Extras), 1);
Extras.ShiftDirection    = repmat({'Unrelated Lure'}, height(Extras), 1);
Extras.Catch             = repmat(-1, height(Extras), 1);
Extras.Condition         = repmat({'Unrelated Lure'}, height(Extras), 1);
Extras.ContextSwitch     = repmat({'Unrelated Lure'}, height(Extras), 1);
Extras.RetContext        = repmat({''}, height(Extras), 1);
Extras.RetContextEmoProp = zeros(height(Extras), 1);

% Add 5 Unrelated Lures to Each Run
for run = unique(Retrieval.RunID)'
    
   % Select
   [selection, idxs] = datasample(Extras, 5, 'Replace', false);
   
   % Update Extras
   Extras = Extras(setdiff(1:height(Extras), idxs)', :);
   
   % Update RunID Variable
   selection.RunID(:) = run;
   
   % Add to Retrieval
   Retrieval = vertcat(Retrieval, selection);
    
end

% Randomly Assign Each Unrelated lure a context at retrieval
idxs = find(strcmp(Retrieval.Condition, 'Unrelated Lure'));

for ii = idxs
    
    % Pick a context at random
    selectionIDX = randsample(1:4, 1);
    
    % Update RetContext Variable
    Retrieval.RetContext(ii)    = Encoding.Properties.UserData.ContextImageFile(selectionIDX);
    
end

% Sort By Run
Retrieval = sortrows(Retrieval, 'RunID');

%%
%==========================================================================
%                 Randomize Trial Order within Runs
%==========================================================================
%%%

for run = unique(Retrieval.RunID)'
    
    % Filter for this mini block
    filter              = Retrieval.RunID == run;
    
    % Randomize the order of the trials of this Mini Block
    Retrieval(filter, :) = RandomizeRows(Retrieval(filter,:));
    
end

%%
%==========================================================================
%                   Create The Find The Boop List
%==========================================================================
%%% Initalize the Find List

% Encoding(:, {'ID' 'ImageFile' 'Emotion' 'RunID'})

goldenRatio = 1/4;

FindTheBoop                = table;
FindTheBoop.item1ID        = cell(height(Encoding)* goldenRatio, 1);
FindTheBoop.item1ImageFile = cell(height(Encoding)* goldenRatio, 1);
FindTheBoop.item1Emotion   = cell(height(Encoding)* goldenRatio, 1);

FindTheBoop.item2ID        = cell(height(Encoding)* goldenRatio, 1);
FindTheBoop.item2ImageFile = cell(height(Encoding)* goldenRatio, 1);
FindTheBoop.item2Emotion   = cell(height(Encoding)* goldenRatio, 1);
FindTheBoop.RunID          = zeros(height(Encoding)* goldenRatio, 1);

for r = unique(Encoding.RunID)'

   EncRunFilter = Encoding.RunID == r;
   AAfilter     = true(height(Encoding), 1);
   y            = length(find(EncRunFilter)) * goldenRatio;
   for k = 1:y
       
        Emotions        = unique(Encoding.Emotion);
        [FirstEmo, idx] = datasample(Emotions, 1);
        SecondEmo       = Emotions(1:length(Emotions) ~= idx);
       
        FirstEmoFilter  = strcmp(Encoding.Emotion, FirstEmo);
        filter          = EncRunFilter & AAfilter & FirstEmoFilter;
        idxs            = datasample(find(filter), 1);
        AAfilter(idxs)  = false;

        FindTheBoop.item1ID(k+(r-1)*y)         = Encoding.ID(idxs);
        FindTheBoop.item1ImageFile(k+(r-1)*y)  = Encoding.ImageFile(idxs);
        FindTheBoop.item1Emotion(k+(r-1)*y)    = Encoding.Emotion(idxs);
        
        SecondEmoFilter = strcmp(Encoding.Emotion, SecondEmo);
        filter          = EncRunFilter & AAfilter & SecondEmoFilter;
        idxs            = datasample(find(filter), 1);
        AAfilter(idxs)  = false;

        FindTheBoop.item2ID(k+(r-1)*y)         = Encoding.ID(idxs);
        FindTheBoop.item2ImageFile(k+(r-1)*y)  = Encoding.ImageFile(idxs);
        FindTheBoop.item2Emotion(k+(r-1)*y)    = Encoding.Emotion(idxs);
        
        FindTheBoop.RunID(k+(r-1)*y) = r;

   end

end

end