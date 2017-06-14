%test
clear all;
Study.studyDir = '/gpfs/group/nad12/default/nad12/ICEE/Behav'; % R:\DennisLab\Studies\Elon_ICE_Scanner_Summer_2017\ICEE_master\data
subj = {'y106'};

for s = 1:length(subj)
    
    subjDir = fullfile(Study.studyDir, subj{s});
    
    retfile = spm_select('FPList', subjDir, '.*retrieval_compiled.*\.csv');
    encfile = spm_select('FPList', subjDir, '.*encoding_compiled.*\.csv');

    ret   = readtable(retfile); 
    enc   = readtable(encfile);
    
    %Accuracy info from RET file
    for i = 1:height(ret)
        test(i)     = {char(ret{i,3})}; %face img
        on(i)       = ret{i,2};         %type (only care about targets)
        response(i) = ret{i,18};        %Score
    end

    %Image info from ENC file
    for i = 1:height(enc)
        test2(i) = {char(enc{i,4})}; %face img
    end

    for k = 1:height(ret); %ret is RET xls
        if strcmp(on{k}, 'Target') %
            filematch = find(strcmp(test(1,k),test2)==1);  %match on face img
            DMscore(filematch) = response(k); %match on face img
       end
    end

    if length(DMscore) ~= height(enc) %enc is ENC xls
        DMscore(height(enc)) = {0};
    end

    enc.DMscore = DMscore';

    filename = [strcat(subj{s}) 'enc_DM.csv']

    oldpath=pwd;
    path2  = fileparts(encfile);
    cd(path2);
    writetable(enc, filename);
    cd(oldpath);

end
