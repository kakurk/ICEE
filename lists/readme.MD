# lists

This directory contains trial lists for the ICEE experiment

## Files

### MATLAB

+ `convert.m` -- MATLAB script outlining the steps taken to convert John's trial lists --> Kyle's trial lists  

### Excel Sheets

+ `ICE Scanner Encoding Trial Order For Kyle (03) 6-1-2017.xlsx` -- excel sheet Kyle recieved from John Huhn, June 1st 2017  
+ `ICE Scanner Retrieval Trial Order For Kyle (03) 6-1-2017.xlsx` -- excel sheet Kyle received from John Huhn, June 1st 2017  

### CSVs

+ `encoding_list.csv` -- comma seperated text file, containing the trial list for encoding. This file was created using the `convert.m` function.
+ `retrieval_list.csv` -- comma seperated text file, containing the trial list for retrieval. This file was created using the `convert.m` function.
    + One additional note, the `StimulusDuration` and `FixationDuration` columns were added manually. I copied the StimulusDuration and Fixation Duration columns from `encoding_list.csv`, making sure I shuffled the `FixationDuration`s using MATLAB's `Shuffle` function.

Please email Kyle at kyleakurkela@gmail.com with questions, comments, or concerns.
