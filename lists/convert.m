function convert(list, filename)
% convert  convert John Huhn's ICE excel sheet(s) to concatenated csv file
%
%   Usage convert(filename);
%
% Written by Kyle Kurkela, kyleakurkela@gmail.com
% June, 2017

switch list
    case 'enc'
        
        % sheet names in John's encoding excel sheet
        sheets   = {'ENCODING1' 'ENCODING2' 'ENCODING3' 'ENCODING4'};
        
        % initalize
        Encoding = table;
        
        for cs = 1:length(sheets)
        
            % current sheet name
            cursheet     = sheets{cs};
            
            % read in cursheet to a temporary table
            tmpTable     = readtable(filename, 'Sheet', cursheet, 'Range', 'A1:G35');
            
            % add a Run column
            tmpTable.Run = repmat(cs, height(tmpTable), 1);
            
            % concatenate to create an Encoding table
            Encoding     = vertcat(Encoding, tmpTable);
            
        end
        
        % write out concatenated table
        writetable(Encoding, 'encoding_list.csv')
        
    case 'ret'
        
        % sheet names in John's retrieval excel sheet
        sheets    = {'Retrieval1' 'Retrieval2' 'Retrieval3' 'Retrieval4'};

        % initalize
        Retrieval = table;
        
        for cs = 1:length(sheets)
        
            % current sheet name
            cursheet     = sheets{cs};
            
            % read in cursheet to a temporary table
            tmpTable     = readtable(filename, 'Sheet', cursheet, 'Range', 'A1:G35');
            
            % add a Run column
            tmpTable.Run = repmat(cs, height(tmpTable), 1);
            
            % concatenate to create a Retrieval table
            Retrieval    = vertcat(Retrieval, tmpTable);
            
        end
        
        % write out concatenated table
        writetable(Retrieval, 'retrieval_list.csv')
        
end

end