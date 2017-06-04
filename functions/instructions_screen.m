function [secs] = instructions_screen(varargin)
% instructions_screen  draw an instructions screen to the current PTB window
%
%   intructions_screen(instructions, directions, [,autoSkip], [,keys], [,resp_device], [,buffer], [autoskipWait])
%
% Written by Kyle Kurkela, kyleakurkela@gmail.com. June, 2017
%% Parse Input Arguments
    
    global W Y

    % Defaults
    settings = ...
        {'Please answer the questions as quickly and accurately as you can';
         'Press spacebar to continue';
         'n';
         [KbName('space') KbName('escape')];
         -1;
         .050;
         2};
     
     % User Specified Settings
     filter = ~cellfun('isempty', varargin);
     settings(filter) = varargin(filter);
     [instructions, directions, autoskip, keys, resp_device, buffer, autoskipWait] = settings{:};
    
%% Instructions Screen

    DrawFormattedText(W, instructions, 'center', 'center');
    DrawFormattedText(W, directions, 'center', 4*(Y/5));
    Screen('Flip', W);
    WaitSecs(buffer);
    
    if strcmp(autoskip, 'n')
        
        RestrictKeysForKbCheck(keys);
        [secs, keycode, ~] = KbStrokeWait(resp_device);
        
        if keycode(KbName('escape')) == 1
            error('Experiment Quit')
        end
        
        RestrictKeysForKbCheck([]);
        
    elseif strcmp(autoskip, 'y')
        
        WaitSecs(autoskipWait);
        
    end

end