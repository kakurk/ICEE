function init_psychtoolbox(DBmode)
% Initalize Psychtoolbox. 
% Written by Kyle Kurkela
% kyleakurkela@gmail.com

%%
%==========================================================================
%                               Misc
%==========================================================================

% Global Variables to Set
global X Y W

% Loading Psych HID
LoadPsychHID;

% Check for Opengl compatibility, abort otherwise
AssertOpenGL;

% Shuffle the random-number generator for each experiment
rng('shuffle');

% Turn off the Sync Tests, the visual debugging and warnings and general
% verbosity of PTB
Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);

% Prevent Keystrokes from being entered into MATLAB command and editor 
% windows
ListenChar(2);

% Hide the Mouse Cursor
HideCursor;

% Make sure keyboard mapping is the same on all supported operating 
% systems
KbName('UnifyKeyNames');

%%
%==========================================================================
%							PTB Screen Settings
%==========================================================================

% Get screenNumber of stimulation display, and choose the maximum index, 
% which is usually the right one.
screens      = Screen('Screens');
screenNumber = max(screens);

% Open a double buffered fullscreen window on the stimulation screen
% 'screenNumber' and use background color specified in settings
% 'W' is the handle used to direct all drawing commands to that window
%     W = Screen('OpenWindow', screenNumber, backgroundColor);

if strcmp(DBmode, 'y')
    W = Screen('OpenWindow', screenNumber, 0, [0 0 1200 1200]); % Smaller screen for testing/debugging
else
    W = Screen('OpenWindow', screenNumber, 0); % Fullscreen
end

Screen('BlendFunction', W, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% How large is this window, in pixels?
% X = width of the window, in pixels
% Y = height of the window, in pixels
[X, Y] = Screen(W, 'WindowSize');

% Set Default Text Size for this Window
Screen('TextSize', W, 30);
Screen('TextColor', W, 255);

% Set priority for script execution to realtime priority
Priority(MaxPriority(W));

% Loading Screen
DrawFormattedText(W, 'Loading Experiment...', 'center', 'center');
Screen('Flip', W);

end