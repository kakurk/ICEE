function [] = SPMContrasts()
%% User Input
% You should ONLY (!!!!!!) need to edit this highlighted section of the
% script.
    
    % User Input Step 1: Subjects
    
    % Please list the subjects to model in a 1 x N cell array.
    
    Subjects       = { 'y102'}; 
   
    % User Input Step 2: Directories
    
    % Please specify the name of the current analysis, the directory the
    % current analysis is in.
    
    Analysis.name      = 'ICEE_encoding_hrf'; % name of analysis to run.             
    Analysis.directory = strcat('R:\DennisLab\Studies\Elon_ICE_Scanner_Summer_2017\master_ICE\Analysis_enc',filesep,Analysis.name);
    
    % User Input Step 3: Options
    
    % Set the following jobman_option to 'interactive' to view in SPM parameters the GUI. 
    % Press any key into the command window to continue to next one sample t test.
    % Set the following jobman option to 'run' to skip the viewing of the
    % SPM parameters in the GUI and go directly to running of the one
    % sample t-tests.
    
    jobman_option = 'run'; % 'run' or 'interactive'.
    
    % Set the following jobman_option to 'interactive' to view in SPM parameters the GUI. 
    % Press any key into the command window to continue to next one sample t test.
    % Set the following jobman option to 'run' to skip the viewing of the
    % SPM parameters in the GUI and go directly to running of the one
    % sample t-tests.    
    
    cons2run   = 'all'; % [1:3 7];
    deletecons = 1; % delete existing contrasts? 1 = yes, 0 = no
    
%% Setting Analysis specifics contrasts

    clc
    fprintf('Analysis: %s\n\n',Analysis.name)
    disp('Analysis Directory:')
    disp(Analysis.directory)


        % ------Example: Contrasts for Indira's 'Relatedness_hrf' ------ %
        % 28 Contrasts Total
            
        % Inialize Number.OfContrasts
            
            Number.OfContrasts = 0;

            % AllTrials
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'AllTrials' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIHits' 'ICHits' 'IIMiss' 'ICMiss' 'Other' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)
            
            % AllHits_v_Baseline
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'AllHits_v_Baseline' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIHits' 'ICHits'  }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)  
            
            % IIHits_v_Baseline
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'IIHits_v_Baseline' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIHits' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)
            
            % ICHits_v_Baseline
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'ICHits_v_Baseline' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'ICHits' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)
            
            % IIMisss_v_Baseline
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'IIMiss_v_Baseline' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIMiss' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)
            
            % ICMisss_v_Baseline
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'ICMiss_v_Baseline' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'ICMiss' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)
            
            % AllHits_v_AllMiss
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'AllHits_v_AllMiss' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIHits' 'ICHits'  }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {'IIMiss' 'ICMiss'}; % TTs to be included in contrast (-)  
          
            % IIHits_v_ICHits
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'IIHits_v_ICHits' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIHits' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = { 'ICHits'}; % TTs to be included in contrast (-) 
            
            % ICHits_v_IIHits
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'ICHits_v_IIHits' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'ICHits' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = { 'IIHits'}; % TTs to be included in contrast (-) 
            
            % IIHits_vs_IIMiss
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'IIHits_vs_IIMiss' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIHits' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = { 'IIMiss' }; % TTs to be included in contrast (-)
            
            % IIMiss_vs_IIHits
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'IIMiss_vs_IIHits' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'IIMiss' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = { 'IIHits' }; % TTs to be included in contrast (-)

            % ICMiss_vs_ICHits
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'ICMiss_vs_ICHits' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'ICMiss' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = { 'ICHits' }; % TTs to be included in contrast (-)
            
            % ICHits_vs_ICMiss
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'ICHits_vs_ICMiss' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'ICHits' }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = { 'ICMiss' }; % TTs to be included in contrast (-)
            
            % Other_v_Baseline
            Number.OfContrasts = Number.OfContrasts+1;
            Contrasts(Number.OfContrasts).names    = { 'Other_v_Baseline' }; % name of contrast
            Contrasts(Number.OfContrasts).positive = { 'Other'  }; % TTs to be included in contrast (+)
            Contrasts(Number.OfContrasts).negative = {}; % TTs to be included in contrast (-)  
            
    
            
%% Routine
% Should not need to be edited

    % Set SPM Defaults

    spm('defaults','FMRI')
    spm_jobman('initcfg')
    Count.ProblemSubjs = 0;
    
    fprintf('\n')
    fprintf('Number of Contrasts Specified: %d \n\n',length(Contrasts))
    
    for indexS = 1:length(Subjects)
        % Build Contrast Vectors

            pathtoSPM = strcat(Analysis.directory,filesep,Subjects{indexS},filesep,'SPM.mat');
            fprintf('Building Contrast Vectors...\n\n')
            Contrasts = BuildContrastVectors(Contrasts,pathtoSPM);
            
        % Run SPM Contrast Manager
            if strcmp(jobman_option,'interactive')
                fprintf('Displaying SPM Job for Subject %s ...\n\n',Subjects{indexS})
            elseif strcmp(jobman_option,'run')
                fprintf('Running SPM Job for Subject %s ...\n\n',Subjects{indexS})                
            end
            matlabbatch = SetContrastManagerParams(Contrasts,pathtoSPM,deletecons,cons2run);
            try
                spm_jobman(jobman_option,matlabbatch)
                if strcmp(jobman_option,'interactive')
                    pause
                end
            catch error %#ok<NASGU>
                display(Subjects{indexS})
                Count.ProblemSubjs=Count.ProblemSubjs+1;
                pause
                problem_subjects{Count.ProblemSubjs} = Subjects{indexS}; %#ok<*AGROW>
            end
        fprintf('\n')
    end
    if exist('problem_subjects','var')    
        fprintf('There was a problem running the contrasts for these subjects:\n\n')
        disp(problem_subjects)
    end

%% Sub Functions

    function matlabbatch = SetContrastManagerParams(Contrasts,pathtoSPM,delete,cons2run)
        % Function for setting the contrast manager parameters for the SPM job
        % manager. Takes in:
        %
        % Contrasts:
        %   .names = {'Contrast Name'}
        %   .positive = { 'Trial' 'Types' 'Included' }
        %   .negative = { 'Trial' 'Types' 'Included' }
        %   .vector = [0 0 .33 .33 0 0 0]
        %
        % pathtoSPM = 's:\nad12\Hybridwords\Analyses\SPM8\EPI_Masked\Encoding_ER_hrf\subjectID\SPM.mat'
        % 
        % delete = 1; 1 = delete existing contrasts, 0 = keep existing contrasts

        if strcmp(cons2run,'all')
            k = length(Contrasts);
        else
            k = cons2run;
        end
        
        matlabbatch{1}.spm.stats.con.spmmat = cellstr(pathtoSPM);
        for curCon = 1:k
            fprintf('Contrast %d: %s\n',curCon,Contrasts(curCon).names{1})
            matlabbatch{1}.spm.stats.con.consess{curCon}.tcon.name = Contrasts(curCon).names{1};
            matlabbatch{1}.spm.stats.con.consess{curCon}.tcon.convec = Contrasts(curCon).vector;
        end
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.delete = delete;

    end

end
