clear all;
Study.studyDir = 'S:\nad12\MORF\Behav';
subj = {'63o397'}; % '63o395' '64o405' '63o408' '61o388' '71o153' '68o334' '81o346' '69o418' '70o421' '68o401' '63o413' '65o425' '75o264' '65o426' '75o372' '60o422' '62o432' '61o429'};
% {'21y2108' '23y2107' '21y2122' '21y2115' '21y2136' '31y2150' '28y2152'
% '21y2153' '21y2160' '20y2161' '20y2162' '19y2159' '27y2163' '25y2164' '31y2165' '30y2174' '26y2175' '25y2176' '25y2177' '28y2178' '19y2184' '22y2189' '22y2195' '22y2196' '21y2197'}; 
% YAs '21y2108' '23y2107' '21y2122' '21y2115' '21y2136' '31y2150' '28y2152' '21y2153' '21y2160' '20y2161' '20y2162' '19y2159' '27y2163' '25y2164' '31y2165' '30y2174' '26y2175' '25y2176' '25y2177' '28y2178' '19y2184' '22y2189' '22y2195' '22y2196' '21y2197'
for s = 1:length(subj)
    
    datafile = strcat(Study.studyDir,filesep, subj{s},filesep,  subj{s}, '_rett.xlsx');
    datafile2 = strcat(Study.studyDir,filesep, subj{s},filesep,  subj{s}, '_enc.xls');
    [path,name,ext,versn] = fileparts(datafile);
    [path2,name2,ext2,versn2] = fileparts(datafile2);
    data2 = ReadFromExcel(datafile,'ALL');
    data3 = ReadFromExcel(datafile2,'ALL');

    %Accuracy info from RET file
    for i = 2:length(data2)
        test(i)  = {char(data2{i,8})}; %images
        on(i)    = data2(i,11);        %type
        score(i) = data2(i,6);         %score
    end

    %Image info from ENC file
    for i = 2:length(data3)
        test2(i) = {char(data3{i,7})}; %images
        % type (i) = (data3(i,10));
    end

    for k = 2:length(data2); %Data2 is RET xls
        if on{k} == 0 || on{k} == 1 || on{k} == 2 || on{k} == 3
            filematch = find(strcmp(test(1,k),test2)==1);
            DMscore(filematch) = score(k);
       end
    end

    if length(DMscore) ~= length(data3) %Data3 is ENC xls
        DMscore(length(data3)) = {0};
    end

    data3(:,15) = DMscore;
    data3(1,15) = {'DMscore'};

    filename = [strcat(subj{s}) 'enc_DM.xls']

    oldpath=pwd;
    cd(path2);
    xlswrite(filename, data3);
    cd(oldpath);

    %oldpath=pwd;
    %cd(path2);
    %xlswrite(strcat(subj(s), 'enc_DM.xls'), data3);
    %cd(oldpath);
end
