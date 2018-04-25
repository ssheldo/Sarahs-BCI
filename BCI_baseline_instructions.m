function BCI_baseline_instructions(onScreen,fontsize,centerX,centerY,gray,black,white,instruct)

% #########################################################################
%% Instructions

if strcmpi(instruct,'yes') == 1
    % Screen 1
    Screen('TextSize',onScreen,fontsize);
    Screen('DrawText',onScreen,'The next few screens will briefly explain the task.',...
        (centerX-400),(centerY+20),white);
    Screen('DrawText',onScreen,'To advance to the next screen, press any key on the keyboard.',...
        (centerX-400),(centerY+70),white); %line every +50
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

    % Screen 2
    Screen('TextSize',onScreen,fontsize);
    Screen('DrawText',onScreen,'This part of the experiment is meant to measure the baseline levels of some of your brain waves,',...
        (centerX-700),(centerY+20),white);
    Screen('DrawText',onScreen,'by recording your brain while in a resting state, with eyes open.',...
        (centerX-700),(centerY+70),white);
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

    % Screen 3
    Screen('TextSize',onScreen,fontsize);
    Screen('DrawText',onScreen,'We will ask that you sit quietly with your eyes open for 1 minutes.',...
        (centerX-600),(centerY+20),white);
    Screen('DrawText',onScreen,'staring at the fixation cross on the screen.',...
        (centerX-600),(centerY+70),white);
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

    % Screen 4
    Screen('TextSize',onScreen,fontsize);
    Screen('DrawText',onScreen,'Please let the experimenter know if you have any questions, ',...
        (centerX-600),(centerY+20),white);
    Screen('DrawText',onScreen,'or press the button on the intercom if you need anything during the task.',...
        (centerX-600),(centerY+70),white);
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

end
    
% Screen 5
Screen('TextSize',onScreen,fontsize);
Screen('DrawText',onScreen,'When you are ready, press any key to begin. ',...
    (centerX-500),(centerY+20),white);
Screen('Flip',onScreen,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

