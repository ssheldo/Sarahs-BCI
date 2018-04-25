function BCI_feedback_task_instructions(onScreen,fontsize,centerX,centerY,gray,black,white,instruct,...
    train,trigger_size)

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
    Screen('DrawText',onScreen,'This part of the experiment is meant to train you to control your brain waves.',...
        (centerX-700),(centerY+20),white);
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

    % Screen 3
    Screen('TextSize',onScreen,fontsize);
    Screen('DrawText',onScreen,'We will ask that you watch the bar on the screen for the next 5 mins.',...
        (centerX-600),(centerY+20),white);
    Screen('DrawText',onScreen,'Your goal is to increase the level of the bar.',...
        (centerX-600),(centerY+70),white);
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

    % Screen 4
    Screen('TextSize',onScreen,fontsize);
    Screen('DrawText',onScreen,'There is no right way to do this.',...
        (centerX-600),(centerY+20),white);
    Screen('DrawText',onScreen,'If you have trouble, try relaxing or letting your mind wander.',...
        (centerX-600),(centerY+70),white);
    Screen('DrawText',onScreen,'Once the orange bar changes, try to figure out the mental state',...
        (centerX-600),(centerY+120),white);
    Screen('DrawText',onScreen,'that makes the bar go up.',...
        (centerX-600),(centerY+170),white);
    Screen('Flip',onScreen,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button

    % Screen 5
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
Screen('FillRect',onScreen,Vpixx2Vamp(20+train),trigger_size); %trigger for first block
Screen('Flip',onScreen,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

