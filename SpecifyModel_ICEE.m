%modified by Nancy for ICEE 6/6/17

function [] = SpecifyModel()
%% User Input
% You should ONLY (!!!!!!) need to edit this highlighted section of the
% script.
    %pause off
    % User Input Step 1: Directories
    
    % Please specify the name of the current analysis, the directory the
    % current analysis is in, and the directoy which houses the behavioral
    % data.
    
    Analysis.name             = 'ICEE_encoding_hrf';  %defines targets/lures/new items
    Analysis.directory        = fullfile('S:\nad12\ICE\Analysis_enc\', Analysis.name);  %should the slasshes go the other way?
    Analysis.behav.directory  = 'S:\nad12\ICE\data\';
    
    
    % User Input Step 2: Subjects
    
    % Please list the subjects to model in a 1 x N cell array.
    
    % One Subs
    Subjects = {'y102'};%
    
    % User Input Step 3: Model Specifics
    
    % Each model is unique, with a different number of trial types, a
    % different behavioral excel sheet identifier, and whether or not there
    % are any parametric modulators. In this section, please specify the
    % following parameters for you model:
    % -Number of Trial Types
    % -Behavioral File Identifier
    % -Number of ParametricModulators
    
    % A note on switch..case. Switch..case is essenatially a more elagant
    % if...else statement. It evaluates the lines of code that when the
    % switch variable matches the case variable.
    
    switch Analysis.name

        % -------- Encoding Models ----------
        
        % Basic Model
        case 'ICEE_encoding_hrf'
            Number.OfTrialTypes           = 5;
            Analysis.behav.FileIdentifier = '_encALL.xls';

        % -------- Retrieval Models ---------
        
                           % Parametric Models
        case 'AnalysisName3'
            Number.OfTrialTypes           = 1;
            Analysis.behav.FileIdentifier = '_RET1.xls';
            ParametricMods = 3;
            
        case 'MORF_Analysis_Example: Relatedness_hrf'
            Number.OfTrialTypes           = 7;
            Analysis.behav.FileIdentifier = '_ret.xls';
            ParametricMods                = 1;
    end

    %% Routine
    % In this highlighted section of code, you should NOT need to make any
    % edits unless specifically directed to do so. Look for the sections
    % that have a:
    % =================USER INPUT REQUIRED=================================
    
    clc
    fprintf('Model: %s\n\n', Analysis.name)
    fprintf('Model Directory: \n')
    disp(Analysis.directory)
    fprintf('\n')
    fprintf('Behavioral Data Directory: \n')
    disp(Analysis.behav.directory)
    fprintf('\n')
    
    for indexS = 1:length(Subjects)
        %% Build Path to this Subject's Behavioral Data
        % This section builds a path to the current subjects behavioral
        % file using the stract function.

        curSubj.name      = Subjects{indexS};
        curSubj.behavFile = fullfile(Analysis.behav.directory, curSubj.name, [curSubj.name Analysis.behav.FileIdentifier]);

        %% Read in this Subject's Behavioral Data
        % This section of the code reads in the subjects behavioral data.
        
        fprintf('Reading in Subject %s ''s Behav Data ...\n\n\n\n',curSubj.name)
       % [~,~,BehavData]   = xlsread(curSubj.behavFile, 'Sheet1');  %orrginal from Kyle
         [~,~,BehavData]   = xlsread(curSubj.behavFile); %nancy changed from xlsread to see if this command worked (NOPE)..
         [Number.OfRows,~] = size(BehavData);

        %% Build path to this subjects analysis directory
        % This section builds a path to this subjects analysis directory,
        % and creates that directory if it does not already exist.
        
        curSubj.directory = strcat(Analysis.directory,filesep,curSubj.name);
        if isdir(curSubj.directory)
        else
            mkdir(curSubj.directory)
        end

        %% Initalize the counter cell array
        % ============USER INPUT REQUIRED==================================
        % The counter cell array will keep track of how many trials occur in
        % each trial type in each functional run

        Number.OfRuns = HowManyRuns(BehavData,19); % <---- Input which column keeps track of the current run in the behavioral data
        counter       = zeros(Number.OfRuns,Number.OfTrialTypes);

        %% Build the multiple conditions *.mat file for each subject
        
        fprintf('Sorting Behavioral Data...\n\n\n\n')
        
        for indexRun = 1:Number.OfRuns
            %% Initialize the names, onsets, durations, and pmods structure arrays
            % This section inilaized the names, onsets, and durations
            % structure arrays, which will be filled in with the
            % approrpiate information in a nested for loop.
            
            names     = cell(1,Number.OfTrialTypes); % initalizing TT names
            onsets    = cell(1,Number.OfTrialTypes); % initalizing TT onset vector
            durations = cell(1,Number.OfTrialTypes); % intializing TT durations vector
            
            % Only initialize the pmod structure array if this model
            % contains a parametric modulator
           
            %%ICT commented out below 
            if exist('ParametricMods','var')
                for indexP = 1:Number.OfTrialTypes
                    pmod(indexP).name  = cell(1,ParametricMods);
                    pmod(indexP).param = cell(1,ParametricMods);
                    pmod(indexP).poly  = cell(1,ParametricMods);
                end
            end
            
            for indexRow = 2:Number.OfRows
                %% Identify Relevant Variables from this Row
                
                Variables.trialRun  = BehavData{indexRow,10}; %change based on column tracking runs

                %% Sort this trial into a "bin" or trial type
                % Sort the trial types one functional run at a time

                if indexRun == Variables.trialRun
                    
                    clc
                    fprintf('Sorting Run %d...\n\n',indexRun)                    
                    fprintf('Sorting Trial %d...\n\n',(indexRow-1))
                    
                    switch Analysis.name
                            
                        case 'ICEE_encoding_hrf' 
                            
                            Variables.rawonset    = BehavData{indexRow,11};
                            Variables.score       = BehavData{indexRow,16};
                            Variables.type        = BehavData{indexRow,2};
                           % Variables.relatedness = BehavData{indexRow,15};
                            
                            
                            % Sort Trials into Trial Types
                            indexTT = 0;
                            
                            % Trial Type: IIHit
                            indexTT = indexTT+1;
                            if  strcmp(Variables.type, 'II') 
                                if  strcmp(Variables.score, '1!') 
                                counter(indexRun,indexTT) = counter(indexRun,indexTT)+1;
                                names{indexTT}                                = 'IIHits';
                                onsets{indexTT}(counter(indexRun,indexTT))    = Variables.rawonset/1000;
                                durations{indexTT}(counter(indexRun,indexTT)) = 0;
                                end
                            end
                            
                            % Trial Type: ICHit
                            indexTT = indexTT+1;                            
                           if  strcmp(Variables.type, 'IC') 
                                if  strcmp(Variables.score, '1!')
                                counter(indexRun,indexTT) = counter(indexRun,indexTT)+1; 
                                names{indexTT}                                = 'ICHit';
                                onsets{indexTT}(counter(indexRun,indexTT))    = Variables.rawonset/1000;
                                durations{indexTT}(counter(indexRun,indexTT)) = 0;
                               end 
                            end
                            
                            % Trial Type: IIMiss
                            indexTT = indexTT+1;                            
                           if  strcmp(Variables.type, 'II') 
                                if  strcmp(Variables.score, '2@') 
                                counter(indexRun,indexTT) = counter(indexRun,indexTT)+1; 
                                names{indexTT}                                = 'IIMiss';
                                onsets{indexTT}(counter(indexRun,indexTT))    = Variables.rawonset/1000;
                                durations{indexTT}(counter(indexRun,indexTT)) = 0;
                                end
                            end
                            
                            % Trial Type: ICMiss
                            indexTT = indexTT+1;                            
                            if  strcmp(Variables.type, 'IC') 
                                if  strcmp(Variables.score, '2@')  
                                counter(indexRun,indexTT) = counter(indexRun,indexTT)+1; 
                                names{indexTT}                                = 'ICMiss';
                                onsets{indexTT}(counter(indexRun,indexTT))    = Variables.rawonset/1000;
                                durations{indexTT}(counter(indexRun,indexTT)) = 0;
                                end
                            end
                            
                                                       
                            % Trial Type: Other   %MAKE THIS AN ELSE STATETMENT
                            indexTT = indexTT+1;                            
                           % if  Variables.type == 'II' || Variables.score == 'IC' 
                           if  strcmp(Variables.score, '3#')   %CREATE IN DM SCRIPT  
                                counter(indexRun,indexTT) = counter(indexRun,indexTT)+1; 
                                names{indexTT}                                = 'Other';
                                onsets{indexTT}(counter(indexRun,indexTT))    = Variables.rawonset/1000;
                                durations{indexTT}(counter(indexRun,indexTT)) = 0;
                           %     end
                            end
                            
                            
                        
                            
                    end
                    fprintf('\n')
                    disp('Names:')
                    disp(names')
                    disp('Onsets:')
                    disp(onsets')
                    disp('Durations:')
                    disp(durations')
                    if exist('pmod','var')
                        disp('Parametic Modulators')
                        for indexPmod = 1:length(pmod)
                            disp(pmod(indexPmod))
                        end
                    end
                    fprintf('\n')
                    pause(.1)
                end
                
            end

            %% Check to see if all trial types occured in this run. If any did
            % not, remove them from the names/onsets/durations cell array
            
            fprintf('\nPruning Non-existant Trial Types...\n\n')
            if exist('pmod','var')
                [names,onsets,durations,pmod] = prune_nonexistent_trialtypes(names,onsets,durations,pmod); %#ok<*NASGU,*ASGLU>   
            else
                [names,onsets,durations] = prune_nonexistent_trialtypes(names,onsets,durations); %#ok<*NASGU,*ASGLU>
            end
            fprintf('\n')
            disp('Names:')
            disp(names')
            disp('Onsets:')
            disp(onsets')
            disp('Durations:')
            disp(durations')
            if exist('pmod','var')
                disp('Parametic Modulators')
                disp(pmod)
            end
            fprintf('\n')
            
            %% Save the Multiple Conditions *.mat file in this subjects' analysis
            % directory

            %ICT% matfilename = fullfile(curSubj.directory, curSubj.name, ['Run', num2str(indexRun), '.mat']);
             matfilename = fullfile(curSubj.directory, ['Run', num2str(indexRun), '.mat']);
            fprintf('Saving Subject %s''s Run %d multiple conditions file...\n\n\n', curSubj.name, indexRun)
            pause(3)
            if exist('ParametricMods','var')
                save(matfilename,'names','onsets','durations','pmod');
            else
                save(matfilename,'names','onsets','durations');
            end

        end
    end
    
    disp('Finished!!')
    
    %% Sub Functions
    
    function NumOfRuns = HowManyRuns(BehavData,CurRunColumn)
        %%% Function to determine how many runs occur in this set of behav
        %%% data.
        [Number.OfRows,~] = size(BehavData); 
        NumOfRuns = 0;
        for j = 2:Number.OfRows
           NumOfRuns = max(NumOfRuns, BehavData{j,CurRunColumn});
        end
    end

    function [varargout] = prune_nonexistent_trialtypes(varargin)
        innames     = varargin{1};
        inonsets    = varargin{2};
        indurations = varargin{3};
        if nargin == 4
            inpmod = varargin{4};
        end
        
        ncount = 0;
        for n = 1:length(innames)
            if ~isempty(innames{n})
                ncount = ncount+1;
                outnames{ncount} = innames{n};
            end
        end

        ocount = 0;
        for o = 1:length(inonsets)
            if ~isempty(inonsets{o})
                ocount = ocount+1;
                outonsets{ocount} = inonsets{o};             
            end
        end

        dcount = 0;
        for d = 1:length(indurations)
            if ~isempty(indurations{d})
                dcount = dcount + 1;
                outdurations{dcount} = indurations{d};
            else
                pmod_ind = d;
            end
        end
        
        if nargin == 4
            pcount = 0;
            for p = 1:length(inpmod)
                if p ~= pmod_ind
                    pcount = pcount + 1;
                    outpmod(pcount) = inpmod(p);
                end
            end
        end
        
        varargout{1} = outnames;
        varargout{2} = outonsets;
        varargout{3} = outdurations;
        if nargin == 4
            varargout{4} = outpmod;
        end
    end

end

    

