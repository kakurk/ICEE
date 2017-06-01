function [Encoding] = generate_lists(StimuliDir)
% generate_lists    function for generating pesudorandomized trial lists
%                   for the encoding, retrieval tasks.
%
%
% Written by Kyle Kurkela, kyleakurkela@gmail.com
%
% See also 

%%
%==========================================================================
%                   Initalize The Encoding List
%==========================================================================
%%% Initalize the Encoding list with 256 items from the Stimuli Directory

% Context File Names
ContextFNs   = dir_regexp(StimuliDir, '\.jpg$'); % grab the ones that start with "A_"
ContextFNs   = {ContextFNs.name};

% Contexts Table
ContextsTable = table(ContextFNs', 'VariableNames', {'FileNames'});

% Face File Names
FaceFNs     = dir_regexp(StimuliDir, '\.png$'); % Assume all the .pngs are faces
FaceFNs     = {FaceFNs.name};

% Faces Table:
%   Initalize columns:
%       FileNames = names of the files
%       Sex       = M/F, determined from the file names
%       AgeGroup  = YA/OA, determined from the file names

FacesTable          = table(FaceFNs', 'VariableNames', {'FileNames'});
FacesTable.Sex      = cell(height(FacesTable), 1);
FacesTable.AgeGroup = cell(height(FacesTable), 1);

% Figure out which faces are male and female.
MaleFilter = regexpi(FacesTable.FileNames, '[^fe]{1,2}male', 'start');
MaleFilter = ~cellfun(@isempty, MaleFilter);

FemaleFilter = regexpi(FacesTable.FileNames, 'female', 'start');
FemaleFilter = ~cellfun(@isempty, FemaleFilter);

FacesTable.Sex(MaleFilter)   = {'Male'};
FacesTable.Sex(FemaleFilter) = {'Female'};

% Figure out which faces are young and old. Assume face is young IFF there
% is no 'OA' in the file name.
OAFilter = regexp(FacesTable.FileNames, 'OA', 'start');
OAFilter = ~cellfun(@isempty, OAFilter);

FacesTable.AgeGroup(OAFilter)  = {'OA'};
FacesTable.AgeGroup(~OAFilter) = {'YA'};

% Filter out all of the Faces that did NOT receive a Male/Female Assignment
FacesTable = FacesTable(~cellfun(@isempty, FacesTable.Sex), :);

%%
%==========================================================================
%             Create the Encoding Study List
%==========================================================================

% Initialize Encoding Trial List
Encoding    = table();

% Hardcoded Study Parameters
nencoding_sessions        = 6;
ntrials_per_encoding_sess = 34;
nencoding_trials          = nencoding_sessions * ntrials_per_encoding_sess;
EncConds                  = {'II', 'IC'};
IIpositions               = {'FaceLeft', 'SceneLeft'};

% Initalize Columns of the Encoding Trial List
Encoding.EncodingCond          = cell(nencoding_trials, 1);
Encoding.SceneOrFaceLeft       = cell(nencoding_trials, 1);
Encoding.FaceStim              = cell(nencoding_trials, 1);
Encoding.SceneStim             = cell(nencoding_trials, 1);
Encoding.StudyStimulusDuration = repmat(4000, nencoding_trials, 1);
Encoding.FixationDuration      = zeros(nencoding_trials, 1);
Encoding.SessionNumber         = repelem(1:nencoding_sessions,ntrials_per_encoding_sess)';

% FixationLengths are set according to the ICE jitter method:
%   6 trials each of 2000 2500 3000 and 3500 ms jitter
%   5 trials each of 4000 6000 ms jitter
FixLengths                     = horzcat(repelem([2000 2500 3000 3500], 6), repelem([4000 6000], 5));

% For each encoding session...
for cSess = 1:nencoding_sessions
    
    % The indices of this session
    thisSessionIdxs = find(Encoding.SessionNumber == cSess);

    % Randomly Pick `ntrials_per_encoding_sess` face stimuli
    selections = datasample(FacesTable.FileNames, ntrials_per_encoding_sess, 'Replace', false);
    Encoding.FaceStim(thisSessionIdxs) = selections;

    % Randomly Pick `ntrials_per_encoding_sess` context stimuli
    selections = datasample(ContextsTable.FileNames, ntrials_per_encoding_sess, 'Replace', false);
    Encoding.SceneStim(thisSessionIdxs) = selections;

    % Randomly Assign half of the trials in this session to each of the
    % encoding conditions
    selections       = datasample(thisSessionIdxs, length(thisSessionIdxs)/2, 'Replace', false);
    other_selections = thisSessionIdxs(~ismember(thisSessionIdxs, selections));
    Encoding.EncodingCond(selections)       = EncConds(1);
    Encoding.EncodingCond(other_selections) = EncConds(2);

    % Shuffle the possible Fixation Lengths and Assign them to Encoding trials
    Encoding.FixationDuration(thisSessionIdxs) = Shuffle(FixLengths);

    % Randomly Assign half of the 'II' EncCond trials to be SceneLeft and
    % Half to be FaceLeft. Note, since there is an odd number of II trials
    % per session, we will need to alternate the which condition gets the
    % extra trial
    
    if rem(cSess, 2) == 0
        
        curIIorder = IIpositions(2:-1:1);
        
    else
       
        curIIorder = IIpositions;
        
    end

    % The indices of this session's 'II' trials
    IItrialIdxs = find(strcmp(Encoding.EncodingCond, 'II') & Encoding.SessionNumber == cSess);

    % Pick half (rounded down) of these trials to be one condition
    selections       = datasample(IItrialIdxs, floor(length(IItrialIdxs)/2), 'Replace', false);
    other_selections = IItrialIdxs(~ismember(IItrialIdxs, selections));

    % Assign what's left to be the other condition. Note: since we rounded
    % down in the previous command, this condition will be the one with one
    % extra trial for this session
    Encoding.SceneOrFaceLeft(selections)       = curIIorder(1);
    Encoding.SceneOrFaceLeft(other_selections) = curIIorder(2);
    
end

end