function VisDetect_NoEntrains()
%% VisEntrainment_quest.m 
% Orginally by Dr. Kyle Mathewson - University of Alberta
% Modified by SSS 03/2018 from tCAS_VisEntrain_central_v5
% 
% Original task was entrainment with repetitive annulus stimulation. This
% version is meant to entrain with tACS instead of repetitive annulus (or
% annuli?). This means that entrainers do not appear. Only targets followed
% by masks.
% 
% _________________________________________________________________________
% 
% **What to know before running this task:
% This task is meant to be run twice. Once to go through practice blocks, 
% and again for experimental blocks. The type of block to be run is 
% determined by the initial input by the experimenter (see line ~137).
% The purpose is to allow the experimenter to check that the staircasing 
% worked (i.e., target detection is not too difficult nor too easy), and the 
% subject is doing the task correctly. 
% 
% **After completing the practice blocks: 
% The RT and detection rate will be displayed in the Command Window. The 
% detection rate should not be above 0.50. Re-run the practice blocks using
% the staircasing procedure, and go over the instructions again.
% The target color will also be displayed in the Command Window. Record
% this for later use.
% 
% **Starting the experimental blocks:
% After statisfactory performance on the practice blocks, run the task again 
% choosing to use experimental blocks. Input the target color recorded at
% the end of the practice blocks when prompted.
% 
% **Running the same subject on a different day (for the same experiment):
% Run the practice blocks without using the staircase procedure. Input
% target color recorded from previous day when prompted.
% 
% _________________________________________________________________________
% 
% 
% Optional to skip the... 
%   N-up-1-down staircase procedure = 
%       If the participant makes the correct response N times in a row, the 
%       stimulus difficulty is increased (darker target) by a step size. If 
%       the participant makes an incorrect response the stimulus difficulty 
%       is decreased (brighter target) by a step size. 
%       There are four sets of up/down step sizes used in this procedure. 
%       This is so that relative change in brightness does not affect outcome 
%       (i.e., big change is brightness makes target easier to detect than 
%       a small change).
% 
%   Instructions (that explain the task)
% 
% 
% Optional inputs:
%   Target color = if not using staircase procedure, input color of target.
% 
% 
% If changing number of trials, double check the staircase case variable
% UpDn.stopRule to make sure there are enough trials for each stair level.
% 
% -------------------------------------------------------------------------
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% -------------------------------------------------------------------------
%% Triggers
% mask = 10
% block = i_block + 70
% entrainers: 41 - 48

%======= Target Triggers =======
% target present: 100
% target: 10
% **staircase target triggers: 
%       110
% target, tSOA: 1 2 3 4 5 6
% 3-digit number from 111 - 118;
% **target triggers: 
%       111, 112, 113, 114, 115, 116, 117, 118

% target missing: 200
% catch trial: 20
% catch trial, tSOA: 1 2 3 4 5 6
% 3-digit number from 221 - 226
% **missing target triggers: 
%       221, 222, 223, 224, 225, 226, 227, 228


%======= Response Triggers =======
% target present: 100
% response, detected: 50
% **staircase target, response triggers:  
%       150
% response, tSOA: 1 2 3 4 5 6 7 8
% 3-digit number from 151 - 158
% **target, response triggers: 
%       151, 152, 153, 154, 155, 156, etc...

% target present: 100
% response, undetected: 60
% **staircase target, no response triggers:  
%       160
% response, tSOA: 1 2 3 4 5 6 7 8
% 3-digit number from 161 - 168
% **target, no response triggers: 
%       161, 162, 163, 164, 165, 166, etc...

% target present: 100
% response, NULL: 90
% **staircase target, response NULL triggers:  
%       190
% response, tSOA: 1 2 3 4 5 6 7 8
% 3-digit number from 191 - 198
% **target, response NULL triggers: 
%       191, 192, 193, 194, 195, 196*


% target missing: 200
% response, detected: 50
% response, tSOA: 1 2 3 4 5 6 7 8
% 3-digit number from 251 - 258
% **missing target, response detected: 
%       251, 252, 253, 254, 255, 256

% target missing: 200
% response, undetected: 60
% response, tSOA: 1 2 3 4 5 6 7 8
% 3-digit number from 261 - 268
% **missing target, no response: 
%       261, 262, 263, 264, 265, 266

% target missing: 200
% response, unknown: 90
% response, tSOA: 1 2 3 4 5 6 7 8
% 3-digit number from 291 - 298
% **missing target, response NULL triggers: 
%       291, 292, 293, 294, 295, 296

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                            CODE FOR TASK
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clear all
close all
% warning off MATLAB:DeprecatedLogicalAPI
Screen('Preference', 'SkipSyncTests', 1); %for test on an LCD
Priority(2);
% rng('shuffle'); %seed the random number generator so that every random number isn't the same for every subject


%% Input participant's number, name, date of testing, preferences
% Output file will be named after the inputs
Info.number = input('Participant Number:','s');
Info.date = datestr(now,30); % 'dd-mmm-yyyy HH:MM:SS' 

% Pre or post testing
Info.order = input('Pre or Post Testing:','s');

% Practice blocks or experimental blocks? 
Info.practice = input('Practice blocks? [y or n]:','s');

% If doing practice blocks, are we also staircasing?
if strncmpi(Info.practice,'y',1)
    % Do you want to estimate threshold with a staircase procedure? 
    Info.stair = input('Use a staircase? [y or n]:','s');

    % Info.entrain_stair = input('Do you want to train the threshold with entrainers? [y or n]:','s');
    Info.entrain_stair = 'y'; %not relevant to this task version 
else
    % If no practice blocks, no staircasing 
    Info.stair = 'n';
end

Info.instruct = input('Instructions? [y or n]:','s'); %skip task instructions

% If not doing staircasing/practice blocks, input target color (0 black to
% 128 background grey)
if strncmpi(Info.stair,'n',1)
    Info.targetcolor = input('Target color [0 to 128]:','s');
    Info.targetcolor = str2num(Info.targetcolor); %convert input to number
else
    Info.targetcolor = '';
end

% Create text file to write data in
if strncmpi(Info.practice,'y',1) % add 'P' to indicate practice blocks
    Filename = [Info.number '--' Info.date '_' Info.order '_dataP.mat'];
else
    Filename = [Info.number '--' Info.date '_' Info.order '_data.mat'];
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%% Set up parallel port
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%initialize the inpoutx64 low-level I/O driver
%config_io;
%optional step: verify that the inpoutx64 driver was successfully installed
%global cogent;
%if( cogent.io.status ~= 0 )
%   error('inp/outp installation failed');
%end
%write a value to the default LPT1 printer output port (at 0x378)
%address_eeg = hex2dec('B010');
%outp(address_eeg,0);  %set pins to zero  


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%% Variables to adjust
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%****target****
vis_thresh = 15; %target RGB points darker than grey background
targ_length = 1; %in refresh cycles; each refresh is 1000msec / 120 Hz = 8.333 msec
target_size = 18;

%****mask****
mask_thresh = 50; %points darker than background
SOA = 6; %refresh target onset to mask onset (50 ms optimal/8.3333 msec = 6 cycles) 
ISI = SOA - targ_length; %target OFFSET to mask onset 
mask_length = 1; %refresh cycles of mask
entrainer_size = 35;

% -------------------------------------------------------------------------
% Note: This version of the task does not include entrainers

%****entrainers****
entr_thresh = 0; %50; points darker than background (no entrainer in this version)
entr_length = 1; %refresh cycles of entrainer = refresh cycles of Draw.entrainer

% hz = 10;
% rate = ((1000/hz)/8.333)/2; 
rate = 12; % constitutes a 10 Hz rhythmic presentation (10 would be a 12 Hz)
           %refresh cycles before next entrainer (1000msec /120 Hz) = 8.333 msec; 1000msec / 10 Hz  = 100 msec; 100 msec / 8.333 msec = 12 cycles
           %1000/8.33*6 == 20Hz, 1000/8.33*8 == 15Hz, 1000/8.33*10 == 12Hz, 1000/8.33*14 == 8.5Hz, 1000/8.33*30 == 4.0Hz
           %list must be an odd number of items
%number of refreshes, so formula = 1000/(8.33*desired frequency) desired frequency = 12, 15, 20, etc.           

entr_gap_length = rate - entr_length;
entr_gap_length_stair = rate - entr_length;

n_entrs = 1; %number of entrainers on a trial (can be list: entrs = [6:1:8]);
n_entrs_stair = 1; %number of entrainers on a staircase trial;

% -------------------------------------------------------------------------
% ****tSOA (previously called lags)****

%randomize the offsets
% s = rng; %save the current generator settings
% rng('shuffle') %so values are not repeated
% rntSOA1 = randi([0 9],[1 2]); 
% rntSOA2 = randi([11 20],[1 2]); 
% rntSOA3 = randi([21 30],[1 2]); 
% tSOA = [0,10,rntSOA1,rntSOA2,rntSOA3]; %number of refreshes after OFFSET of last entrainer before target 
% rng(s); %restore the original generator settings

tSOA = [0,3,8,10,12,17,21,25];  %number of refreshes after OFFSET of last entrainer before target (20ms/50ms/80ms/110ms/150ms/170ms/200ms)
% tSOA = [0,3,10,12,21,25];
n_tSOA = length(tSOA); %number of unique lags
tSOA_stair = rate; %use one full cycle after entrainer for staircase

%****fixations****
fixation_length = 48; %400 ms
preblank_length = 24; %200 ms

%****number of trials & blocks****    
tSOA_per_block = 2*length(tSOA); %how many of each lag in each block
% tSOA_per_block = length(tSOA);
n_trials = tSOA_per_block * (n_tSOA); %the +1 accounts for 1 catch trial for every type of target trial
% n_trials = 10;

% how many practice or experimental blocks 
if strncmpi(Info.practice,'y',1)
    nE_blocks = 0; %no experimental blocks if only doing practice
    %how many practice blocks
    if strncmpi(Info.stair,'y',1)
        nP_blocks = 1; %2 if using staircasing
    else
        nP_blocks = 2; %3 regular practice blocks if not using staircasing
    end
else
    nE_blocks = 2; %3 %4 experimental blocks
    nP_blocks = 0; %no practice blocks
end
% ######################################################################### 


n_blocks = nE_blocks + nP_blocks; %total blocks in experiment

p_catchtrials = 0.2; %what proportion of trials will be catch trials (no target presented)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%% Open the main window and get dimensions
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

white=[255,255,255];  %WhiteIndex(window);
black=[0,0,0];   %BlackIndex(window);

grey = [128 128 128]; %background colour
entrainer_grey = grey-entr_thresh; %entrainer colour
mask_grey = grey-mask_thresh; %mask colour
targ_grey = grey-vis_thresh; %stim_grey - vis_thresh; %target colour

% If target color was inputted, use that value
if ~isempty(Info.targetcolor)
    targ_grey = Info.targetcolor;
end

% Load the window up
screenNumber = max(Screen('Screens')); % Get the maximum screen number i.e. get an external screen if avaliable
[window,rect]=Screen(screenNumber ,'OpenWindow',grey(1));
% [window,rect]=Screen(screenNumber ,'OpenWindow',grey(1), [100 100 800 800] ); %use this line for testing

% ---------------------------------------------
% HideCursor; %Comment this out for testing -----   
% ---------------------------------------------

v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;
fixation = [h_center-10 v_center-10];
trigger_size = [0 0 1 1]; %use [0 0 1 1] for eeg, 100 100 for photodiode

% Get presentation timing information
refresh = Screen('GetFlipInterval', window); % Get flip refresh rate
slack = refresh/2; % Divide by 2 to get slack

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%% Set up the offScreen windows and stimuli
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%hide cursor
HideCursor;

%setup the blank screen
blank=Screen(window,'OpenoffScreenWindow',grey);
    Screen(blank, 'FillRect',[0 0 0],trigger_size);
    
%setup the fixation screen
fixate=Screen(window,'OpenoffScreenWindow',grey);
    Screen(fixate, 'DrawLines', [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen(fixate, 'FillRect',[0 0 0],trigger_size);

%setup the annulus entrainers
entrainer=Screen(window,'OpenoffScreenWindow',grey);
    Screen(entrainer, 'FillOval',[entrainer_grey(1) grey(1); entrainer_grey(2) grey(2); entrainer_grey(3) grey(3)] , [h_center-entrainer_size h_center-target_size; v_center-entrainer_size v_center-target_size; h_center+entrainer_size h_center+target_size; v_center+entrainer_size v_center+target_size] );
%     Screen(entrainer, 'FillRect',[0 0 0],trigger_size);
    
%Setup the target circle
target=Screen(window,'OpenoffScreenWindow',grey);
    Screen(target, 'FillOval',targ_grey, [h_center-target_size v_center-target_size h_center+target_size v_center+target_size] ); %Target
%     Screen(target, 'FillRect',[0 0 0],trigger_size);

% %Setup the target circle for instructions
target_instruct=Screen(window,'OpenoffScreenWindow',grey);
    Screen(target_instruct, 'FillOval',black, [h_center-target_size v_center-target_size h_center+target_size v_center+target_size] ); %Target

%Setup the mask
mask=Screen(window,'OpenoffScreenWindow',grey);
    Screen(mask, 'FillOval',[mask_grey(1) grey(1); mask_grey(2) grey(2); mask_grey(3) grey(3)] , [h_center-entrainer_size h_center-target_size; v_center-entrainer_size v_center-target_size; h_center+entrainer_size h_center+target_size; v_center+entrainer_size v_center+target_size] );
%     Screen(mask, 'FillRect',[0 0 0],trigger_size);
%     Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    
WaitSecs(2);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
                            %% Instructions
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('DrawText',window,'Please keep your eyes fixed on the central cross the entire time.',fixation(1)-450,fixation(2)-100,0);  %Display instructions
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0); %flip it to the screen
    WaitSecs(1); 
 KbWait; %wait for subject to press button

if ~strncmpi(Info.instruct,'n',1) %skip instructions 
    
    Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('FillOval',window,targ_grey,[h_center-target_size v_center-target_size h_center+target_size v_center+target_size]  ); %Target
    Screen('DrawText',window,'On each trial, a small circle will appear followed by a donut.',fixation(1)-450,fixation(2)-160,0);
    Screen('DrawText',window,'Decide if you can see this small circle following the donut.',fixation(1)-450,fixation(2)-110,0); 
    % Screen('FillRect',window,black,trigger_size);
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0);
    WaitSecs(1); 
KbWait; %wait for subject to press button
    Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('FillOval',window,targ_grey,[h_center-target_size v_center-target_size h_center+target_size v_center+target_size]  ); %Target
    Screen('DrawText',window,'Press the LEFT arrow if you can see the small circle.',fixation(1)-400,fixation(2)-160,0); 
    Screen('DrawText',window,'Press the RIGHT arrow if you only see the donut.',fixation(1)-400,fixation(2)-110,0);  
    % Screen('FillRect',window,black,trigger_size);
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0);
    WaitSecs(1);
KbWait; %wait for subject to press button

% #########################################################################
%% Check instructions are understood
for CheckInstruct = 1:3 %run through example three times
% #########################################################################    
        Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
        Screen('DrawText',window,'Sometimes the small circle will appear...',fixation(1)-250,fixation(2)-110,0);  
        % Screen('FillRect',window,black,trigger_size);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        Screen('Flip', window,[],0); %
        WaitSecs(1);
    KbWait; %wait for subject to press button
% #########################################################################
    %% put up fixation
    Screen('CopyWindow',fixate,window,rect,rect);
    tfixate_onset = Screen(window, 'Flip');
   
    %% put up blank
    Screen('CopyWindow',blank ,window,rect,rect);
    tblank_onset = Screen(window, 'Flip', tfixate_onset + fixation_length*refresh - slack);
% /////////////////////////////////////////////////////////////////////////   
    %% present the entrainers
    Screen('CopyWindow',entrainer,window,rect,rect);
    tentr_onset = Screen(window, 'Flip', tblank_onset + preblank_length*refresh - slack);
    for i_entr = 2:n_entrs
        Screen('CopyWindow',blank ,window,rect,rect); %blank window
    %     tblank_onset = Screen(window, 'Flip', tentr_onset + 45*entr_length*refresh - slack);
        tblank_onset = Screen(window, 'Flip', tentr_onset + entr_length*refresh - slack);
        Screen('CopyWindow',entrainer ,window,rect,rect); %donut
    %     tentr_onset = Screen(window, 'Flip', tblank_onset + 5*entr_gap_length*refresh - slack);
        tentr_onset = Screen(window, 'Flip', tblank_onset + entr_gap_length*refresh - slack);
    end
% /////////////////////////////////////////////////////////////////////////
    %% present the dark Target
    Screen('CopyWindow',target_instruct,window,rect,rect);
    % ttarget_onset = Screen(window, 'Flip', tentr_onset + 10*tSOA(2)*refresh - slack);
    ttarget_onset = Screen(window, 'Flip', tentr_onset + tSOA(1)*refresh - slack);

    %% blank Inter stimulus interval
    Screen('CopyWindow',blank ,window,rect,rect);
    tISI_onset = Screen(window, 'Flip', ttarget_onset + targ_length*refresh - slack);  

    %% present the mask
    Screen('CopyWindow',mask,window,rect,rect);
    % tmask_onset = Screen(window, 'Flip', ttarget_onset + 9*ISI*refresh - slack);
    tmask_onset = Screen(window, 'Flip', tISI_onset + ISI*refresh - slack);
    
    %% blank screen
        Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0); %Print the fixation,
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen(window, 'Flip', tmask_onset + mask_length*refresh - slack);
        WaitSecs(0.5);
    KbWait; %wait for subject to press button
% #########################################################################
% #########################################################################
    %% more instructions
        Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
        Screen('DrawText',window,'Sometimes it will not...',fixation(1)-200,fixation(2)-110,0);  
    %     Screen('FillRect',window,black,trigger_size);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        Screen('Flip', window,[],0); %
        WaitSecs(0.5);
    KbWait; %wait for subject to press button   
% /////////////////////////////////////////////////////////////////////////
    %% put up fixation
    Screen('CopyWindow',fixate,window,rect,rect);
    tfixate_onset = Screen(window, 'Flip');
   
    %% put up blank
    Screen('CopyWindow',blank ,window,rect,rect);
    tblank_onset = Screen(window, 'Flip', tfixate_onset + fixation_length*refresh - slack);      
% /////////////////////////////////////////////////////////////////////////
    %% present the entrainers
    Screen('CopyWindow',entrainer,window,rect,rect);
    tentr_onset = Screen(window, 'Flip', tblank_onset + preblank_length*refresh - slack);
    for i_entr = 2:n_entrs
        Screen('CopyWindow',blank ,window,rect,rect);
    %     tblank_onset = Screen(window, 'Flip', tentr_onset + 45*entr_length*refresh - slack);
        tblank_onset = Screen(window, 'Flip', tentr_onset + entr_length*refresh - slack);
        Screen('CopyWindow',entrainer ,window,rect,rect);
    %     tentr_onset = Screen(window, 'Flip', tblank_onset + 5*entr_gap_length*refresh - slack);
        tentr_onset = Screen(window, 'Flip', tblank_onset + entr_gap_length*refresh - slack);
    end
% /////////////////////////////////////////////////////////////////////////
    %% present the no Target
    Screen('CopyWindow',blank ,window,rect,rect);
    % ttarget_onset = Screen(window, 'Flip', tentr_onset + 10*tSOA(2)*refresh - slack);
    ttarget_onset = Screen(window, 'Flip', tentr_onset + tSOA(1)*refresh - slack);

    %% blank Inter stimulus interval
    Screen('CopyWindow',blank ,window,rect,rect);
    tISI_onset = Screen(window, 'Flip', ttarget_onset + targ_length*refresh - slack);      

    %% present the mask
    Screen('CopyWindow',mask ,window,rect,rect);
    % tmask_onset = Screen(window, 'Flip', ttarget_onset + 9*ISI*refresh - slack);
    tmask_onset = Screen(window, 'Flip', tISI_onset + ISI*refresh - slack);
   
    %% blank screen   
        Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
        Screen('CopyWindow',blank ,window,rect,rect); %blank
        Screen(window,'Flip', tmask_onset + mask_length*refresh - slack);
        WaitSecs(0.5);
    KbWait; %wait for subject to press button
% /////////////////////////////////////////////////////////////////////////
    %% check understanding
        if CheckInstruct == 1
            Screen('DrawText',window,'Again...',fixation(1)-25,fixation(2)-110,0);  
            Screen('Flip', window,[],0);
            WaitSecs(0.5);
            KbWait;
        elseif CheckInstruct == 2
            Screen('DrawText',window,'One more example...',fixation(1)-200,fixation(2)-110,0);  
            Screen('Flip', window,[],0);
            WaitSecs(0.5);
            KbWait;
        end
end %check understanding
% #########################################################################
%% final instructions   
%     Screen('DrawText',window,'Press the LEFT arrow if you see any indication of the target being present',fixation(1)-800,fixation(2)-110,0);  
    Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('DrawText',window,'Remember...Press the LEFT arrow if you see any indication of the small circle being present.',fixation(1)-650,fixation(2)-160,0);  
    Screen('DrawText',window,'Press the RIGHT arrow if you do NOT see the small circle.',fixation(1)-650,fixation(2)-110,0);  
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0); %
    WaitSecs(1);
    KbWait; %wait for subject to press button
% .........................................................................

end %Info.instruct (skip instructions)

% #########################################################################
% Instructions to start practice/experiment
Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('DrawText',window,'Remember...Press the LEFT arrow if you see any indication of the small circle being present.',fixation(1)-650,fixation(2)-160,0);  
    Screen('DrawText',window,'Press the RIGHT arrow if you do NOT see the small circle.',fixation(1)-650,fixation(2)-110,0);  
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0); %
    WaitSecs(1);
    KbWait; %wait for subject to press button
if strncmpi(Info.practice,'y',1)
    Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('DrawText',window,'Let the experimenter know if you have any questions.',fixation(1)-400,fixation(2)-160,0);  
    Screen('DrawText',window,'Press any key to begin the practice session.',fixation(1)-400,fixation(2)-110,0);  
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0); %
    WaitSecs(1);
    KbWait; 
elseif strncmpi(Info.practice,'n',1)
    Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
    Screen('DrawText',window,'Let the experimenter know if you have any questions.',fixation(1)-400,fixation(2)-160,0);  
    Screen('DrawText',window,'Press any key to begin the experiment.',fixation(1)-400,fixation(2)-110,0);  
    Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
    Screen('Flip', window,[],0); %
    WaitSecs(1);
    KbWait; 
end

% #########################################################################
%% wait a bit before trials start
Screen('CopyWindow',blank ,window,rect,rect);
Screen('FillRect',window, Vpixx2Vamp(71), trigger_size); %trigger for first block
Screen(window, 'Flip')
WaitSecs(2);
% #########################################################################




    
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%% >>>>>>>>>>>>>>>>>>>    N-Up-1-Down Staircasing    <<<<<<<<<<<<<<<<<<<<<<
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
if strncmpi(Info.stair,'y',1) %skip staircasing if 'n'         
%% Set-Up Structure UpDn for Staircasing
  % Note. DECREASE in stimulus level = INCREASE in correct responses (staircase 
  % procedures usually assume this is a positive relationship) 
    % means that up/down steps are actually decreases/increases
        
  % Information about stimulus color settings:
    % (use uisetcolor to see them)
    % white = 255
    % black = 0
    % background color = 128
    % target color = 113
    % mask color = 78
    % entrainer color = 128
    
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%            Modifiable staircasing settings in UpDn structure:
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    UpDn.xStartLevel = 85; %Initial target color: ~2/3 between background and black
    
    % Contains stimulus level to be used on current trial    
    UpDn.xCurrent = UpDn.xStartLevel;

    UpDn.sUp   = 3; % Number of consecutive undetected responses after which stimulus difficulty decreases 
    %                   (after n undetected: target color - sSizeUp = darker target color)  {4}
    UpDn.sDown = 1; % Number of consecutive detected responses after which stimulus difficulty increases
    %                   (after n detected responses: target color + sSizeDown =  target color closer to background (lighter)) {3}

    % !!!!!!!!!!!!
    % !Step Sizes!
    % !!!!!!!!!!!!
    % Size of decrease in stimulus difficulty (-step up to reduce/darken target color).
    UpDn.sSizeUp   = [7 4 6]; %good values when aiming for .50
%     UpDn.sSizeUp   = [5 3 8 4]; %good values when aiming for .70
    % Size of increase in stimulus difficulty (+step down to increase/lighten target color).
    UpDn.sSizeDown = [8 3 6]; %good values when aiming for .50
%      UpDn.sSizeDown = [6 3 7 5]; %good values when aiming for .70
    % --- see García-Pérez (1998) about the ratio of sSizeDown/sSizeUp when using fixed step sizes --- 

% % Determine and display targeted proportion correct and stimulus intensity
% % Currently used to determine step sizes to get targets proportion correct 
%  targetP = (UpDn.sSizeUp(1)./(UpDn.sSizeUp(1)+UpDn.sSizeDown(1))).^(1./UpDn.sDown)

% *** Desired Proportion of Targets Detected ***
%     UpDn.propDetect = .70;
    UpDn.propDetect = .50;
    UpDn.currProp = 0; % starting value for i_sRun = 1
    

    UpDn.stopType = 'trials'; % Can be either ‘trials’ or ‘revels’
            % When set to ‘trials’, staircase will terminate after the number of trials in stopRule.
            % When set to ‘revels’, staircase will terminate after the number of reversals in stopRule.
                % note. code is not currently set-up for reversals
    UpDn.nStairsRun = length(UpDn.sSizeUp); % Want the total number of trials to be = n_trials (72)  
    
    UpDn.stopRule = round(n_trials ./ UpDn.nStairsRun); % Number of trials or reversals before run terminates
    % want same number of trials as one block of the experiment        
%      UpDn.stopRule = 10;

    % Max stimulus level to be used in staircase.
        %If set to empty ([]) no max is applied.
    UpDn.xStimMax = grey(1) - 2;  %background color - 2
    % Min stimulus intensity to be used in staircase.
        %If set to empty ([]) no min is applied. 
    UpDn.xStimMin = 0; %black



% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%% @@@@@@@@@@@@@@@@ Loop for multiple runs of staircasing @@@@@@@@@@@@@@@@@
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for i_sRun = 1:UpDn.nStairsRun

    
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%         UpDn storage fields of each trials staircasing result
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    i_trial = 1; % restart at trial 1  

    % Contains stimulus level to be used on current trial    
    UpDn.xCurrent = UpDn.xStartLevel;

    % Stores stimulus level on trials, and passes them to to UpDn.x 
    UpDn.x(i_sRun,i_trial) = UpDn.xCurrent;
    
    % Stores stimulus level on trials
    UpDn.xStairs(i_sRun,i_trial) = UpDn.x(i_sRun,i_trial);

    UpDn.reverse(i_sRun,i_trial) = 0; % Stores for each trial whether a reversal occurred. 
            % It contains a 0 for trials where no reversal occurred.
            % It contains the count of the reversal for trials where a reversal did occur. 
            
    % Counts the # of consecutive incorrect responses until Up rule is met (equals UpDn.sUp)
    UpDn.u = 0;   % Resets to 0 on the next trial 
    % Counts the # of consecutive correct responses until Down rule is met (equals UpDn.sDown) 
    UpDn.d = 0;   % Resets to 0 on the next trial 

    % *** Used as a Termination Flag *** 
    UpDn.stop = 0; %reset to 0
        % While stop criterion has not been reached, UpDn.stop = 0 
        % When stop criterion is reached, UpDn.stop = 1  
        
     % Get proportion detected before each run after the first run  
     if i_sRun > 1 
        [mR,nR] = size(UpDn.stairResp);
        prev_trials = (mR.*nR); %total trials from previous
     end   


    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
% /////////////////////////////////////////////////////////////////////////   
%% Run staircasing procedure until meet stop criteria
%     for i_trial = 1:UpDn.stopRule
    while ~UpDn.stop  %loop until stop = 1
% /////////////////////////////////////////////////////////////////////////
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
        % update proportion detected
        if i_sRun > 1
            [mR,nR] = size(UpDn.stairResp);
            UpDn.currProp = sum(sum(UpDn.stairResp,2))./(prev_trials + (i_trial-1));  
            UpDn.detectP(i_sRun-1,i_trial) = UpDn.currProp; %to be saved
        end
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% /////////////////////////////////////////////////////////////////////////
        %Setup the target circle
        target=Screen(window,'OpenoffScreenWindow',grey);
        Screen(target, 'FillOval',UpDn.xCurrent, [h_center-target_size v_center-target_size h_center+target_size v_center+target_size] ); %Target
%         Screen(target, 'FillRect',[0 0 0],trigger_size);

        %put up fixation
        Screen('CopyWindow',fixate ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        tsfixate_onset = Screen(window, 'Flip');
        
        %put up blank
        Screen('CopyWindow',blank ,window,rect,rect);
        tqblank_onset = Screen(window, 'Flip', tsfixate_onset + fixation_length*refresh - slack);
        qfixation_time(i_sRun,i_trial) = tqblank_onset - tsfixate_onset; 
% /////////////////////////////////////////////////////////////////////////
        %% Entrainers
        if n_entrs_stair > 0
            for i_stairEntr = 1:n_entrs_stair
                
                if Info.entrain_stair == 'n' %if 'y' skip entrainers
                   Screen('CopyWindow',blank,window,rect,rect);
                   stSOA_onset = Screen(window, 'Flip');
                   break
                end
                
                Screen('CopyWindow',entrainer ,window,rect,rect);
                if i_stairEntr == 1 %wait the pre-entrainer blank
                    Screen('FillRect',window,Vpixx2Vamp(41),trigger_size); %1st entrainer trigger
                    tstepentr_onset = Screen(window, 'Flip', tqblank_onset + preblank_length*refresh - slack);
                    qpreblank_time(i_sRun,i_trial) = tstepentr_onset - tqblank_onset;
%                     res_trig = Screen('Flip', window,[],0);
                else %wait the entrainer ISI
                    Screen('FillRect',window,Vpixx2Vamp(40+i_stairEntr),trigger_size); %n entrainer trigger
                    tstepentr_onset = Screen(window, 'Flip', tblank_onset + entr_gap_length*refresh - slack);
                    qentrblank_time(i_stairEntr-1,i_trial,i_sRun) = tstepentr_onset - tqblank_onset;
                end 
                %fixation in-between
                Screen('CopyWindow',blank ,window,rect,rect); 
                if i_stairEntr < n_entrs_stair %if there is still another to come
                    tqblank_onset = Screen(window, 'Flip', tstepentr_onset + entr_length*refresh - slack);
                    stairentr_time(i_stairEntr,i_trial,i_sRun) = tqblank_onset - tstepentr_onset;
                else 
                    stSOA_onset = Screen(window, 'Flip', tstepentr_onset + entr_length*refresh - slack);
                    stairentr_time(i_sRun,i_trial) = stSOA_onset - tstepentr_onset; %#ok<*SAGROW>
                end
            end
        end
% /////////////////////////////////////////////////////////////////////////        
        %% present the Target
        Screen('CopyWindow',target ,window,rect,rect);
        Screen('FillRect',window,Vpixx2Vamp(110), trigger_size);
        tstairtarget_onset = Screen(window, 'Flip', stSOA_onset + tSOA_stair*refresh - slack);
        qlag_time(i_sRun,i_trial) = tstairtarget_onset - stSOA_onset;
        %% blank Inter stimulus interval
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
%         tstairISI_onset = Screen(window, 'Flip', ttarget_onset + targ_length*refresh - slack);
        tstairISI_onset = Screen(window, 'Flip', tstairtarget_onset + targ_length*refresh - slack);
        qtarget_time(i_sRun,i_trial) = tstairISI_onset - tstairtarget_onset;
        %% present the mask
        Screen('CopyWindow',mask ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(10), trigger_size);
        tsmask_onset = Screen(window, 'Flip', tstairISI_onset + ISI*refresh - slack);
        qISI_time(i_sRun,i_trial) = tsmask_onset - tstairISI_onset;
% /////////////////////////////////////////////////////////////////////////        
        %% Response period
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen(window, 'Flip', tsmask_onset + mask_length*refresh - slack);
        
        t1 = GetSecs;
        keyIsDown = 0;
        while  ~keyIsDown
            [keyIsDown, secs, keyCode] = KbCheck;
        end 
        
        %% Keep a log of the subject's responses
        response = find(keyCode>0);   %1 is 49, 5 is 53, left arrow is 37, right is 39     
        %% detected (left arrow)
            if response == 37
                % Stores responses for all staircasing trials
                UpDn.stairResp(i_sRun,i_trial) = 1; %detected
                Screen('FillRect',window, Vpixx2Vamp(150), trigger_size);
                res_trig = Screen('Flip', window,[],0);
        %% undetected (right arrow)
            elseif response == 39
                % Stores responses for all staircasing trials
                UpDn.stairResp(i_sRun,i_trial) = 0; %undetected
                Screen('FillRect',window, Vpixx2Vamp(160), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            else
                % Stores responses for all staircasing trials
                UpDn.stairResp(i_sRun,i_trial) = 9; %NULL
                Screen('FillRect',window, Vpixx2Vamp(190), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            end
        % Response trigger
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen(window, 'Flip', res_trig + 2*refresh - slack);
        
        % Compute and store response time
        UpDn.subject_rt(i_sRun,i_trial) = secs-t1;
        
        
% /////////////////////////////////////////////////////////////////////////
% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%% <<<<<<<<<<<<<<<<<<<<<    Update UpDn Structure    >>>>>>>>>>>>>>>>>>>>>>
% /////////////////////////////////////////////////////////////////////////
% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

        %% Target Detected (step down = increase difficulty = darken target)
        if i_trial == 1
            if UpDn.stairResp(i_sRun,i_trial) == 1
               % If a reversal happened on the current trial, contains the direction of that reversal 
                UpDn.direction = -1;       
            else
                UpDn.direction = 1;
            end
        end

        %% IF DETECTED...
        if UpDn.stairResp(i_sRun,i_trial) == 1
            UpDn.d = UpDn.d + 1; %detections counter
            
            % NO CHANGE IN TARGET COLOR:
            % If reach desired proportion and step rule has not been met
%             if ((UpDn.currProp == UpDn.propDetect) && i_sRun > 1) && UpDn.d ~= UpDn.sDown %No step down change
            if UpDn.d ~= UpDn.sDown %No step down change if step rule has not been met
                UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial); %for next trial
                
            % CHANGE IN TARGET COLOR:
            % ~~TRUE if d counter == step down rule ||or|| reversal has not yet occurred 
            % ||or|| after 1st run, proportion detected > desired proportion detected    
%             elseif UpDn.d == UpDn.sDown || max(UpDn.reverse(i_sRun),[],2) < 1 ||...
%                     ((UpDn.currProp > UpDn.propDetect) && i_sRun > 1)
            elseif UpDn.d == UpDn.sDown || max(UpDn.reverse(i_sRun),[],2) < 1    
                %% Step down change = target color + step down size (increasing color #)
                % New target color
                UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial) + UpDn.sSizeDown(i_sRun);
                if UpDn.xStairs(i_sRun,i_trial+1) > UpDn.xStimMax %target can't be darker than background
                   UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStimMax; 
                end
                UpDn.u = 0; %reset when there is a reversal
                UpDn.d = 0; %reset when there is a reversal
                UpDn.reverse(i_sRun,i_trial) = 0;
                if UpDn.direction == 1
                    UpDn.reverse(i_sRun,i_trial) = sum(UpDn.reverse(i_sRun,i_trial)~=0) + 1;
                else
                    UpDn.reverse(i_sRun,i_trial) = 0;
                end
                UpDn.direction = -1;
      
            else %No step down change
                UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial);
            end 

        else %% IF UNDETECTED...
            UpDn.u = UpDn.u + 1; %undetected counter
            
            % NO CHANGE IN TARGET COLOR:
            % If reach desired proportion or step rule has not been met
%             if ((UpDn.currProp == UpDn.propDetect) && i_sRun > 1) && UpDn.u ~= UpDn.sUp %No step down change
             if UpDn.u ~= UpDn.sUp %No step down change if step rule has not been met  
                UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial);
                
            % CHANGE IN TARGET COLOR:    
            % ~~TRUE if d counter == step up rule ||or|| reversal has not yet occurred
%             elseif UpDn.u == UpDn.sUp ||  max(UpDn.reverse(i_sRun),[],2) < 1 ||...
%                     ((UpDn.currProp < UpDn.propDetect) && i_sRun > 1)
            elseif UpDn.u == UpDn.sUp ||  max(UpDn.reverse(i_sRun),[],2) < 1   
                %% Step up change = target color - step up size (decrease color #)
                % New target color
                UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial)- UpDn.sSizeUp(i_sRun);
                if UpDn.xStairs(i_sRun,i_trial+1) < UpDn.xStimMin %target's color limit is white
                    UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStimMin;
                end
                UpDn.u = 0; %reset when there is a reversal
                UpDn.d = 0; %reset when there is a reversal
                UpDn.reverse(i_sRun,i_trial) = 0;
                if UpDn.direction == -1
                    UpDn.reverse(i_sRun,i_trial) = sum(UpDn.reverse(i_sRun,i_trial)~=0) + 1;
                else
                    UpDn.reverse(i_sRun,i_trial) = 0;
                end
                UpDn.direction = 1;
            else %No step up change
                UpDn.xStairs(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial);
            end    
        end

        % When to stop this run
        if strncmpi(UpDn.stopType,'reversals',4) &&...
                sum(UpDn.reversal(i_sRun,i_trial)~=0) == UpDn.stopRule
            UpDn.stop = 1;
        end
        if strncmpi(UpDn.stopType,'trials',4) && i_trial == UpDn.stopRule
            UpDn.stop = 1;
        end
        
        % If we didn't stop, update x variable
        if ~UpDn.stop
            UpDn.x(i_sRun,i_trial+1) = UpDn.xStairs(i_sRun,i_trial+1);
            if UpDn.x(i_sRun,i_trial+1) >= UpDn.xStimMax %limit color to darker than backgorund
                UpDn.x(i_sRun,i_trial+1) = UpDn.xStimMax;
            elseif UpDn.x(i_sRun,i_trial+1) < UpDn.xStimMin %limit color to lighter than black
                UpDn.x(i_sRun,i_trial+1) = UpDn.xStimMin;
            end
            UpDn.xCurrent = UpDn.x(i_sRun,i_trial+1); %update
        end

        i_trial = 1 + i_trial;
        
        WaitSecs(0.5); %wait 1/2 second before next trial
    
        
    end
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%     %Determine and display targeted proportion correct and stimulus intensity
%     targetP = (UpDn.sSizeUp(i_sRun)./(UpDn.sSizeUp(i_sRun)+UpDn.sSizeDown(i_sRun))).^(1./UpDn.sDown)
%     targetX = PAL_Gumbel(trueParams, targetP,'inverse'); 

end % End staircasing loop
clear i_trial i_sRun
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%% Record info for later analysis
% Record that target was present
    % Total number of trials across all runs = i_trial
subject_present(1,1:n_trials) = 1;

% Record responses for later analysis
strial = 1;
for run = 1:UpDn.nStairsRun
    for tri = 1:UpDn.stopRule
        subject_answer(1,strial) = UpDn.stairResp(run,tri);
        subject_rt(1,strial) = UpDn.subject_rt(run,tri);
        strial = strial + 1;
    end
    clear tri
end
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
%% Final target color (average of all the runs but the first)

xtarget = round(mean(UpDn.x(1:UpDn.nStairsRun,length(UpDn.x))));

% if our final proportion detected is off
% detdiff = round(mean(UpDn.detectP(1:size(UpDn.detectP),length(UpDn.x)))) - UpDn.propDetect;
% if detdiff > 0.08 %detection rate too high
%     xtarget = xtarget + 5; %5 points closer to grey
% elseif detdiff < 0.08 %detection rate too low
%     xtarget = xtarget - 5; %5 points darker than grey
% end

% make the target screen for the actual task
target=Screen(window,'OpenoffScreenWindow',grey);
    Screen(target, 'FillOval',xtarget, [h_center-target_size v_center-target_size h_center+target_size v_center+target_size] ); %Target
    Screen(target, 'FillRect',[0 0 0],trigger_size);
    
% To later record the target color
targ_grey = xtarget;

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%% Instructions to start practice blocks (after staircasing)
% Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
Screen('DrawText',window,'Let the experimenter know if you have any questions.',fixation(1)-500,fixation(2)-160,0);  
Screen('DrawText',window,'Press any key to begin the next practice block of the experiment.',fixation(1)-500,fixation(2)-110,0); 
Screen('Flip', window,[],0); %
WaitSecs(1);
KbWait 


%wait a bit before next block starts
Screen('CopyWindow',blank ,window,rect,rect);
Screen('FillRect',window, Vpixx2Vamp(72), trigger_size); %trigger for 2nd block
Screen(window, 'Flip')
WaitSecs(2);

end %N-up-1-down staircasing 
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% >>>>>>>>>>>>>>>>>>>>>    End Staircasing Method    <<<<<<<<<<<<<<<<<<<<<<
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@







% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%% >>>>>>>>>>>>>>>>>>>>>>>    Entrainment Task    <<<<<<<<<<<<<<<<<<<<<<<<<
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% If did staircasing, the 1st block is actually the 2nd
    if strncmpi(Info.stair,'y',1)
        nB = 2;
        n_blocks = n_blocks + 1;
    else % No staircasing or doing only experimental blocks
        nB = 1;
    end
    
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
for i_block = nB:n_blocks % Loop for blocks
    
    
    % Set up the random mix of lags and entrainers for each block
        % Now to find a lag you pick the next random index between 1:n_lags from i_lags
        % Then you find that index in all_lags, it tells you where to look in lags
    
    %randomize order of tSOAs
    all_tSOA = 1:n_tSOA;
    if tSOA_per_block > 1
        for i_tSOA = 2:tSOA_per_block
            all_tSOA = [all_tSOA 1:n_tSOA];
        end
    end
    clear i_tSOA
    rand_tSOA = randperm((n_tSOA)*tSOA_per_block);
    all_tSOA = all_tSOA(rand_tSOA);
        
    
    %set up the catch trials on every n-lagsth trial
    p = 1/p_catchtrials;
    q = 1/p_catchtrials;
    present = [1];
    for i_pres = 2:n_tSOA*tSOA_per_block    
       if i_pres == p    
           present = [present 0];
           p = p + q;
       else
           present = [present 1];
       end
    end
    clear i_pres
    rand_pres = randperm((n_tSOA)*tSOA_per_block);
    present = present(rand_pres);
    
    
    %% Loop for trials
    for i_trial = 1:n_trials 
        
        %put up fixation
        Screen('CopyWindow',fixate ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        tfixate_onset = Screen(window, 'Flip');
        %put up blank
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        tblank_onset = Screen(window, 'Flip', tfixate_onset + fixation_length*refresh - slack);
        fixation_time(i_block,i_trial) = tblank_onset - tfixate_onset; 
        
        %% Entrainers
        if n_entrs > 0
            Screen('CopyWindow',entrainer,window,rect,rect); %1st entrainers
            Screen('FillRect',window,Vpixx2Vamp(41),trigger_size); %1st entrainer trigger
            tentr_onset = Screen(window, 'Flip', tblank_onset + preblank_length*refresh - slack);
            preblank_time(i_block,i_trial) = tentr_onset - tblank_onset;
            if n_entrs > 1
                for i_entr = 2:n_entrs
                    Screen('CopyWindow',blank,window,rect,rect); %blank
                    tblank_onset = Screen(window, 'Flip', tentr_onset + entr_length*refresh - slack);
                    entr_time(i_entr-1,i_trial,i_block) = tblank_onset - tentr_onset;
                    Screen('CopyWindow',entrainer,window,rect,rect);
                    Screen('FillRect',window,Vpixx2Vamp(40+i_entr),trigger_size); %n entrainer trigger
                    tentr_onset = Screen(window, 'Flip', tblank_onset + entr_gap_length*refresh - slack);
                    entrblank_time(i_entr-1,i_trial,i_block) = tentr_onset - tblank_onset;
%                     res_trig = Screen('Flip', window,[],0);
                end
            end
        end
       
        
        if present(i_trial) == 1 %two options depending on whether the target is present or absent
        
            %% tSOA (Lag)
            Screen('CopyWindow',blank,window,rect,rect);
            Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
            ttSOA_onset = Screen(window, 'Flip', tentr_onset + entr_length*refresh - slack);
            entr_time(i_block,i_trial) = ttSOA_onset - tentr_onset;

            %% present the Target
            Screen('CopyWindow',target,window,rect,rect);
            Screen('FillRect',window,Vpixx2Vamp(110 + all_tSOA(i_trial)), trigger_size); %trig = 100 (target present) + 10 + trial tSOA
            ttarget_onset = Screen(window, 'Flip', ttSOA_onset + tSOA(all_tSOA(i_trial))*refresh - slack);
            tSOA_time(i_block,i_trial) = ttarget_onset - ttSOA_onset;
        
        else %target missing
            %% tSOA (Lag)
            Screen('CopyWindow',blank,window,rect,rect);
            Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
            ttSOA_onset = Screen(window, 'Flip', tentr_onset + entr_length*refresh - slack);
            entr_time(i_block,i_trial) = ttSOA_onset - tentr_onset;

            %% present the Missing Target (=blank)
            Screen('CopyWindow',blank,window,rect,rect);
            Screen('FillRect',window,Vpixx2Vamp(220 + all_tSOA(i_trial)), trigger_size); %trig = 200 (target missing) + 20 + trial tSOA
            ttarget_onset = Screen(window, 'Flip', ttSOA_onset + tSOA(all_tSOA(i_trial))*refresh - slack);
            tSOA_time(i_block,i_trial) = ttarget_onset - ttSOA_onset;
            
%             outp(address_eeg,2); %send signal for the next block
%             WaitSecs(.01);
%             outp(address_eeg,0); 
%             Screen('FillRect',window,[4 0 0],trigger_size);
%             res_trig = Screen('Flip', window,[],0);
        end
        
        %% blank Inter stimulus interval
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        tISI_onset = Screen(window, 'Flip', ttarget_onset + targ_length*refresh - slack);
        target_time(i_block,i_trial) = tISI_onset - ttarget_onset;
        
        %% present the mask
        Screen('CopyWindow',mask ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(10), trigger_size);
        tmask_onset = Screen(window, 'Flip', tISI_onset + ISI*refresh - slack);
        ISI_time(i_block,i_trial) = tmask_onset - tISI_onset;
        
        %% Response period
        Screen('CopyWindow',blank ,window,rect,rect);
        Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
        Screen(window, 'Flip', tmask_onset + mask_length*refresh - slack);
       
        % Get timing of response
        t1 = GetSecs;
        keyIsDown = 0;
        % Wait until after key is pressed or RT > 1 second
        while  ~keyIsDown
            if (t1 + 1) <= GetSecs % If subject did not respond in time
                keyCode = 99;
                sec = NaN;
                break
            else
                [keyIsDown, secs, keyCode] = KbCheck;
            end
        end
        
                
        %% keep a log of the subject answers
        response = find(keyCode>0);   %1 is 49, 5 is 53, left arrow is 37, right is 39
        
        if present(i_trial) == 1 %two options depending on whether the target is present or absent
            %% detected (left arrow)
            if response == 37
                subject_answer(i_block,i_trial) = 1; %detected
                Screen('FillRect',window, Vpixx2Vamp(150 + all_tSOA(i_trial)), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            %% undetected (right arrow)
            elseif response == 39
                subject_answer(i_block,i_trial) = 0; %undetected
                Screen('FillRect',window, Vpixx2Vamp(160 + all_tSOA(i_trial)), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            else
                subject_answer(i_block,i_trial) = 99; %unknown
                Screen('FillRect',window, Vpixx2Vamp(190 + all_tSOA(i_trial)), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            end
        
        else %target not presented (catch trials)
            %% detected (left arrow)
            if response == 37
                subject_answer(i_block,i_trial) = 1; %detected
                Screen('FillRect',window, Vpixx2Vamp(250 + all_tSOA(i_trial)), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            %% undetected (right arrow)
            elseif response == 39
                subject_answer(i_block,i_trial) = 0; %undetected
                Screen('FillRect',window, Vpixx2Vamp(260 + all_tSOA(i_trial)), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            else
                subject_answer(i_block,i_trial) = 99; %unknown
                Screen('FillRect',window, Vpixx2Vamp(290 + all_tSOA(i_trial)), trigger_size);
                res_trig = Screen('Flip', window,[],0);
            end
        end
        
        subject_rt(i_block,i_trial) = secs-t1; %compute response time and log
        WaitSecs(0.5); %wait one second before next trial
        
    end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------    
    %% Save subject trial information
%     subject_tSOA(i_block,1:i_trial) = all_tSOA; %save subject tSOAs
%     subject_present(i_block,1:i_trial) = present; %save target presence 1: present 0:absent
    subject_tSOA(i_block,1:i_trial) = all_tSOA(1,1:i_trial); %save subject tSOAs
    subject_present(i_block,1:i_trial) = present(1,1:i_trial); %save target presence 1: present 0:absent

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
    %% Wait for the subject to move onto the next block, or end the experiment. 
    if strncmpi(Info.practice,'y',1) % If it is practice blocks only
        if nB == 1 && i_block  == 1
                Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
                Screen('DrawText',window,'Let the experimenter know if you have any questions.',fixation(1)-500,fixation(2)-160,0);  
                Screen('DrawText',window,'Press any key to begin the next practice block of the experiment.',fixation(1)-500,fixation(2)-110,0); 
                Screen('FillRect',window, Vpixx2Vamp(0), trigger_size); 
                Screen('Flip', window,[],0); %
                WaitSecs(1);
            KbWait 
        elseif i_block == n_blocks  %last practice trial
                Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
                Screen('DrawText',window,'You have completed the practice blocks.',fixation(1)-500,fixation(2)-160,0);  
                Screen('DrawText',window,'Please call the experimenter using the intercom.',fixation(1)-500,fixation(2)-110,0); 
                Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
                Screen('Flip', window,[],0); %
                WaitSecs(1);
            KbWait 
        end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------  
    % If doing experimental blocks...    
    elseif ~strncmpi(Info.practice,'y',1)
        if i_block == n_blocks
                Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
                Screen('DrawText',window,['You have now completed all ' num2str(n_blocks) ' blocks. Press any key to end the experiment.'],fixation(1)-500,fixation(2)-110,0);  
                Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
                Screen('Flip', window,[],0); %
                WaitSecs(1);
            KbWait 
        else
    %         Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
            if i_block < 3
                suffix = '';
            else
                suffix = 's';
            end
                Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
                Screen('DrawText',window,['You have now completed ' num2str(i_block) ' block' suffix ' out of ' num2str(n_blocks) '.'],fixation(1)-500,fixation(2)-160,0);  
                Screen('DrawText',window,'If you have any questions, call the experimenter using the intercom.',fixation(1)-500,fixation(2)-110,0); 
                Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
                Screen('Flip', window,[],0); %
                WaitSecs(1);
            KbWait 
                Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, 0, [h_center,v_center],0);  %Print the fixation,
                Screen('DrawText',window,'Press any key to begin the next block of the experiment.',fixation(1)-500,fixation(2)-110,0);  
                Screen('FillRect',window, Vpixx2Vamp(0), trigger_size);
                Screen('Flip', window,[],0); %
                WaitSecs(1);
            KbWait 
        end
    end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

    %wait a bit before it goes on
    Screen('CopyWindow',blank ,window,rect,rect);
    Screen('FillRect',window, Vpixx2Vamp(i_block + 70), trigger_size); %block triggers
    Screen(window, 'Flip')
    WaitSecs(2);

end
clear i_block
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% >>>>>>>>>>>>>>>>>>>>>    End Entrainment Task    <<<<<<<<<<<<<<<<<<<<<<<<
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%% Save the data and close the window, exit
Screen('Close', window);
ShowCursor;

% get the actual tSOA from the index subject_tSOA
for iblock = 1:n_blocks
    for itrial = 1:n_trials
        if subject_tSOA(iblock,itrial) == 0 %no tSOAs were used
            get_tSOA(iblock,itrial) = NaN;
        else
            get_tSOA(iblock,itrial) = tSOA(subject_tSOA(iblock,itrial));
        end
    end
    clear itrial
end

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%% Save data
if strncmpi(Info.stair,'y',1) %save if used staircasing
    save(Filename,'targ_grey','xtarget','subject_answer','subject_tSOA','tSOA','get_tSOA','subject_present','subject_rt','Info', 'UpDn', 'target_time', 'entr_time', 'tSOA_time', 'fixation_time');
else %if staircasing was not used OR only experimental blocks (certain variables were not created)
    save(Filename,'targ_grey','subject_answer','subject_tSOA','tSOA','get_tSOA','subject_present','subject_rt','Info', 'target_time', 'entr_time', 'tSOA_time', 'fixation_time');
end
% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%% Post-experiment analysis

% Exclude trials from staircasing
if strncmpi(Info.stair,'y',1)
    nBstart = 2;
else
    nBstart = 1;
end

% Variables with non-staircasing trials
cmp_subject_answer = subject_answer(nBstart:n_blocks,1:n_trials);
cmp_subject_tSOA = subject_tSOA(nBstart:n_blocks,1:n_trials);
cmp_subject_present = subject_present(nBstart:n_blocks,1:n_trials);
cmp_subject_rt = subject_rt(nBstart:n_blocks,1:n_trials);

%compute average RT and detection and plot
for i_tSOA = 1:n_tSOA 
    mean_per_tSOA(i_tSOA) = sum(cmp_subject_answer((cmp_subject_tSOA==i_tSOA)&cmp_subject_present==1)==1)/length(cmp_subject_answer((cmp_subject_tSOA==i_tSOA)&cmp_subject_present==1)); 
    RT_per_tSOA(i_tSOA) = mean(cmp_subject_rt((cmp_subject_tSOA==i_tSOA)&cmp_subject_present==1));
end

% change x-labels   
newlabel = {tSOA'};
% plots
figure; title(Info.number);
    subplot(2,1,1); plot(mean_per_tSOA); ylabel('Proportion Detect'); xlabel('tSOA');
    ax = gca;
    ax.XAxis.TickLabels = newlabel;

    subplot(2,1,2); plot(RT_per_tSOA*1000); ylabel('RT (msec)'); xlabel('tSOA');
    ax = gca;
    ax.XAxis.TickLabels = newlabel;
    
    
% display RT, detection rate and target color values
disp(' ')
disp(' ')
disp(['Mean RT = ' num2str(mean(RT_per_tSOA))])
disp(['Mean Detection Rate = ' num2str(mean(mean_per_tSOA))])
disp(['Target Color = ' num2str(targ_grey)])
    




 

