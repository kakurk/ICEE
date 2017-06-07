clear all;
Study.studyDir = 'R:\DennisLab\Studies\Elon_ICE_Scanner_Summer_2017\ICEE_master\data';
subj = {'y102'};

for s = 1:length(subj)
    
    retfile = strcat(Study.studyDir,filesep, subj{s},filesep,  subj{s}, '_retALL.xls');
    encfile = strcat(Study.studyDir,filesep, subj{s},filesep,  subj{s}, '_encALL.xls');
    %[path,name,ext,versn] = fileparts(retfile);
    %[path2,name2,ext2,versn2] = fileparts(encfile);
    [num,text,ret] = xlsread(retfile); 
    [num2,text2,enc] = xlsread(encfile);
    
    %Accuracy info from RET file
    for i = 2:length(ret)
        test(i)  = {char(ret{i,3})}; %face img
        on(i)    = ret(i,2);        %type (only care about targets)
        response(i) = ret(i,14);    %response
    end

    %Image info from ENC file
    for i = 2:length(enc)
        test2(i) = {char(enc{i,4})}; %face img
    end

    for k = 2:length(ret); %ret is RET xls
        if on{k} == 0 || on{k} == 1 || on{k} == 2 || on{k} == 3 %Should this be where we tell it to pull rows with Target?
            filematch = find(strcmp(test(1,k),test2)==1);  %match on face img
            DMscore(filematch) = response(k); %match on face img
       end
    end

    if length(DMscore) ~= length(enc) %enc is ENC xls
        DMscore(length(enc)) = {0};
    end

    enc(:,15) = DMscore;
    enc(1,15) = {'DMscore'};

    filename = [strcat(subj{s}) 'enc_DM.xls']

    oldpath=pwd;
    cd(path2);
    xlswrite(filename, enc);
    cd(oldpath);

    %oldpath=pwd;
    %cd(path2);
    %xlswrite(strcat(subj(s), 'enc_DM.xls'), enc);
    %cd(oldpath);
end
