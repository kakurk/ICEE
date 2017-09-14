# Functions

This directory contains custom sub-functions for running the ICEE scanner task

All subfunctions are custom and written by Kyle Kurkela, kyleakurkela@gmail.com

## Descriptions

1. `compile.m`

    **Description:**  
    Concatenates the encoding and retrieval run files into a single csv file.

    **Usage:**  
    `compile(datadir);`

    where:

    + *datadir* = full or relative path to the directory where the data are saved. E.g., './data'.

2. `dir_regexp.m`

    **Description:**  
    using MATLAB's `dir` command, identifies files in a target directory whose filenames match a regular expression.

    **Usage:**  
    `matched = dir_regexp(targetDir, expression);`

    where:

    + *targetDir*  = full or relative path to the directory to be searched.
    + *expression* = regular expression to select files within the target directory
    + *matched*    = a `dir` output structure with fields containing relevant information about identified files. See `dir` documentation.

3. `init_psychtoolbox.m`

    **Description:**  
    Custom initialization of pyschtoolbox.

    **Usage:**  
    `init_psychtoolbox(debugMode);`

    where:

    + *debugMode*  = a string that takes on the value `'y'` or `'n'`. When set to the value `'y'`, the psychtoolbox screen is set to be small  


4. `instructions_screen.m`

    **Description:**  
    Create an instructions screen

    **Usage:**  
    `[,TriggerTime] = instructions_screen([,instructions], [,directions], [,autoskip], [,keys], [,resp_device], [,buffer], [,autoskipWait]);`

    where:

    + *instructions*  = a formatted string. This string is displayed in the center of the screen. Default = `'Please answer the questions as quickly and accurately as you can'`
    + *directions*    = a formatted string. This string is displayed in the center of the screen, below the instructions. Default = `'Press spacebar to continue'`
    + *autoskip*      = a string that takes on the value `'y'` or `'n'`. When set to `'y'`, the instructions screen waits `autoskipWait` before continuing. When set to `'n'`, waits for one of the `keys` before continuing. Default = `'n'`.
    + *keys*          = a vector of psychtoolbox keycodes that the function will wait for before continuing. Psychtoolbox keycodes can be returned by the `KbName` function. Default = [KbName('space') KbName('escape')].
    + *resp_device*   = a single number, corresponding to the response device code for the device you would like to record from (typically, this is a keyboard). See psychtoolbox documentation. Default = -1, which seems to work on most computers, particularly Mac OSX.
    + *buffer*        = a number, indicating the amount of time to wait before starting to record keystrokes from the response device. This prevents auto-advancement of the screen when a participant holds down the key. Default = .05.
    + *autoskipWait* = a number, the amount of time to wait for when in autoskip mode before advancing the screen. Default = 2.
    + *TriggerTime*  = the exact time at which the instruction screen was triggered.

5. `preload_stimuli.m`

    **Description:**  
    Preload trial stimuli. Takes in a Trial List in the form of a MATLAB table and outputs an updated Trial List with a new column of preloaded psycthoolbox image IDs

    **Usage:**  
    `UpdatedTrialList = preload_stimuli(TrialList, stimdir, FNcolumn);`

    where:

    + *TrialList*         = a MATLAB table, which described the trials in the experiment. Each row represents a trial and each column a variable.
    + *stimdir*           = a string of the full or relative path to the directory where the stimuli are held.
    + *FNcolumn*          = a string of the variable name that holds the file names of the images to be preloaded.
    + *UpdatedTrialList*  = a MATLAB table that is identical to the input Trial List, except with an additional column of the preloaded, psychtoolbox image IDs

6. `record_responses.m`

    **Description:**  
    Record responses from an already established KbQueue. See KbQueue documentation for more information.

    **Usage:**  
    `[response, response_time, isEsc] = record_responses([,resp_device], [,NR_resp], [,NR_time]);`

    where:

    + *resp_device*         = a number, indicating which device to record from. Default = -1, which seems to work on most computers, particularly Mac OSX.
    + *NR_resp*             = a string, which tells the function what to output when no response is detected. Default = `'NR'`.
    + *NR_time*             = a number, which tells the function what to output when no response if detected. Default = `NaN`.
    + *response*            = a string, indicating the **last key** recorded during the time interval since the last call to KbQueueStart. See KbName, KbQueue documentation.
    + *response_time*       = a number, indicating the exact time the the last response was made.
    + *isEsc*               = a boolean, true if the escape key was the last recorded response and false if any other key was the last recorded response.
