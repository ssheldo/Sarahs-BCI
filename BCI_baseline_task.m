function BCI_baseline_task()

% Triggers
%   50 + session # = start block
%   60 + session # = end block

% Clear the workspace and the screen
sca;
close all;
clearvars;

%//////////////////////////////////////////////////////////////////////////
%% Input participant's IDs and date to save the data
Info.subjID = input('Participant Number:','s');
Info.session = input('Session Number:','s');
if str2double(Info.session) > 1
    Info.instruct = 'no';
else
    Info.instruct = input('Instructions? (yes or no):','s');
end
Info.time = datestr(now,30); % 'dd-mmm-yyyy HH:MM:SS'
Info.date = date; % day, month, year
% Create .m file to write data in
Filename = [Info.subjID '--' Info.date '_data.mat'];
%//////////////////////////////////////////////////////////////////////////
%% Get electrode information file
% Info.electrode_locs = 'M:\Analysis\Entrainment\tACS\Vamp_18chan_montage25.ced';
% Info.electrode_locs = 'M:\Analysis\ElectrodeLocs\EOG-electrode-locs-32.ced'; %32 channel passive electrodes
Info.electrode_locs = 'M:\Analysis\ElectrodeLocs\EOG-electrode-locs.ced'; %18 channel active electrodes
Info.chanlocs = readlocs(Info.electrode_locs,'filetype','autodetect');
%//////////////////////////////////////////////////////////////////////////
%% Get channel indices
Info.n_elect = 1:18; %list of every electrode collecting brain data
Info.refelec = 16; %which electrode do you want to re-reference to?
Info.eogelec = 17:18; %list all the EOGs
%//////////////////////////////////////////////////////////////////////////





% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                         Psychtoolbox
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 %% Set up parallel port
%initialize the inpoutx64 low-level I/O driver
% config_io;
% %optional step: verify that the inpoutx64 driver was successfully installed
% global cogent;
% if( cogent.io.status ~= 0 )
%    error('inp/outp installation failed');
% end
% %write a value to the default LPT1 printer output port (at 0x378)
% address_eeg = hex2dec('B010');
% 
% outp(address_eeg,0);  %set pins to zero

% #########################################################################
%% START PSYCHTOOLBOX

Screen('Preference','SkipSyncTests', 0) % ensures it will run, should be removed if possible

% Here we call some default settings for setting up Psychtoolbox
% PsychDefaultSetup(2);
Priority(2);

% Get the screen numbers
screenNumber = max(Screen('Screens')); % Get the maximum screen number i.e. get an external screen if avaliable

% Define black and white & colors
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
blue = [0 0 1];
green = [0 1 0];
red = [1 0 0];
orange = [0.9100 0.4100 0.3000]; 
gray = [128 128 128]; %matches target detect task

fontsize = 26; % size of instruction text

% Open screen window
[onScreen, windowRect] = Screen(screenNumber,'OpenWindow',gray(1));
% [win,rect]=Screen(screenNumber ,'OpenWindow',black(1));

% Get the size of the on screen window
[screenX, screenY] = Screen('WindowSize',onScreen);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
centerX = screenX * 0.5; % center of screen in X direction
centerY = screenY * 0.5; % center of screen in Y direction

trigger_size = [0 0 1 1]; %use [0 0 1 1] for eeg, 100 100 for photodiode

HideCursor; %comment out when debugging

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Present Instructions
BCI_baseline_instructions(onScreen,fontsize,centerX,centerY,gray,black,white,Info.instruct)



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                        Open Data Streams
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% instantiate the library
disp('Loading the library...');
lib = lsl_loadlib();

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Resolve an EEG stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); %find the EEG stream from BrainVision RDA
end
%create a new EEG inlet
disp('Opening a EEG inlet...');
inlet_EEG = lsl_inlet(result{1});

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                     Data Acquisition Parameters
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

srate        = 1000;
srate_Amp    = 1000; % sampling rate of the amplifier
nfft         = 2^10;
windowSize   = 500; % 1/2 second
windowInc    = 500; % update every 1/2 second
chans        = Info.n_elect; % channel streaming data from
dataBuffer   = zeros(length(chans),(windowSize*6)/srate*srate_Amp);
% mrksBuffer   = zeros(1,(windowSize*6)/srate*srate_Amp);
dataBufferPointer = 1;

% Frequencies for spectral decomposition
freqband = [8 13]; % alpha
freqs     = linspace(0, srate/2, floor(nfft/2));
freqs     = freqs(2:end); % remove DC (match the output of PSD)
freqRange = intersect(find(freqs >= freqband(1)), find(freqs <= freqband(2)));
freqall = [0.5 30]; % for EEG amplitude
freqRangeall = intersect(find(freqs >= freqall(1)), find(freqs <= freqall(2)));

% Create filter
% freqfilt = [7 8 14 15];
% B = design_bandpass(freqfilt,srate_Amp,20,true);

% Selects electrode for feedback
selchan = 7; %Pz
mask = zeros(length(chans),1)';
mask(selchan) = 1; %Pz



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                    Deal with Incoming EEG Data
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Fill the EEG data structure (for eeglab)
EEG          = eeg_emptyset; 
EEG.nbchan   = length(chans);
EEG.srate    = srate;
EEG.xmin     = 0;
EEG.chanlocs = Info.chanlocs;

state = []; %for use with BCILab functions 

winPerSec = windowSize/windowInc;
chunkSize = windowInc*srate_Amp/srate; % at 512 so every 1/4 second is 128 samples

% 1 minute of data for baseline
sessionDuration = 60; % 1 minute

dataAccu = zeros(length(chans), (sessionDuration+3)*srate);    
dataAccuPointer = 1;  
chunkMarker   = zeros(1, sessionDuration*10);

chunkCount = 1; % Keep track of number of data chunks


% #########################################################################
%% START BASELINE TASK WINDOW

HideCursor; %hide cursor

Screen('FillRect', onScreen, gray);
Screen('DrawLines',onScreen,[-7 7 0 0; 0 0 -7 7],1,0,[centerX,centerY],0);  %Print the fixation
Screen('FillRect',onScreen,Vpixx2Vamp(51),trigger_size); %trigger for first block
% Screen('Flip',onScreen,[],0); %flip it to the screen
Screen(onScreen,'Flip'); %flip it to the screen

% #########################################################################
%% Start timer
tic;


%% ========================================================================
                        %%%%%%%%%%%%%%%%%%%%%%
                        % Baseline Task Loop %
                        %%%%%%%%%%%%%%%%%%%%%%
% =========================================================================

while toc < sessionDuration
    
    % Get chunk from the EEG inlet
    [chunk,stamps] = inlet_EEG.pull_chunk();
    

    % Fill buffer
    if ~isempty(chunk) && size(chunk,2) > 1
        
        if dataBufferPointer + size(chunk,2) > size(dataBuffer,2)
            disp('Buffer overrun');
            dataBuffer(:,dataBufferPointer:end) = chunk(chans,1:(size(dataBuffer,2)-dataBufferPointer+1));
            dataBufferPointer = size(dataBuffer,2);
        else
            dataBuffer(:,dataBufferPointer:dataBufferPointer+size(chunk,2)-1) = chunk(chans,:);
            dataBufferPointer = dataBufferPointer+size(chunk,2);
        end
        
    end
    
    
    % Fill EEG.data
    if dataBufferPointer > chunkSize*winPerSec
        
        % empty buffer based on specified sample rate
        if srate_Amp == srate
                EEG.data = dataBuffer(:,1:chunkSize*winPerSec);   
%                 EEG.mrks = mrksBuffer(1,1:chunkSize*winPerSec);
            elseif srate_Amp == 2*srate
                EEG.data = dataBuffer(:,1:2:chunkSize*winPerSec);
            elseif srate_Amp == 4*srate
                EEG.data = dataBuffer(:,1:4:chunkSize*winPerSec);
            elseif srate_Amp == 8*srate
                EEG.data = dataBuffer(:,1:8:chunkSize*winPerSec);
        else
            error('Cannot convert sampling rate')
        end
        
        % Shift buffer 1 block
        dataBuffer(:,1:chunkSize*(winPerSec-1)) = dataBuffer(:,chunkSize+1:chunkSize*winPerSec);
        dataBufferPointer = dataBufferPointer-chunkSize;
        
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % Processing Streaming Data
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        % Arithmetically rereference to linked mastoid (M1 + M2)/2
        for x = 1:size(EEG.data,1)-2 % excluding EOGs
            EEG.data(x,:) = (EEG.data(x,:)-((EEG.data(Info.refelec,:))*.5));
        end

        % Correct for EOG artifacts
        EEG = online_filt_EOG(EEG);
        
        % Update EEG information
        EEG.pnts = size(EEG.data,2);
        EEG.nchan = size(EEG.data,1);
        EEG.xmax = EEG.pnts/EEG.srate;
        
        % Filter data
        [EEG_temp, state] = hlp_scope({'disable_expressions',true},@flt_fir,'signal',EEG,'fspec',[0.5 1],'fmode','highpass','ftype','minimum-phase', 'state', state);
        EEG = EEG_temp.parts{1,2}; %put filtered data back into EEG structure
%         clear EEG_temp
        
        % To accumulate data for calibration
        dataAccu(:, dataAccuPointer:dataAccuPointer+size(EEG.data,2)-1) = EEG.data;
        dataAccuPointer = dataAccuPointer + size(EEG.data,2);
        chunkMarker(chunkCount) = dataAccuPointer;
       
        
        chunkCount = chunkCount + 1; %keep track of number of data chunks
        
    end %data buffer
    
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                           End Baseline
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%% END BASELINE TASK WINDOW
Screen('FillRect', onScreen, gray);
% Screen('DrawLines',onScreen,[-7 7 0 0; 0 0 -7 7],1,0,[centerX,centerY],0);  %Print the fixation
Screen('FillRect',onScreen,Vpixx2Vamp(52),trigger_size); %trigger for end of block
% Screen('Flip',onScreen,[],0); %flip it to the screen
Screen(onScreen,'Flip'); %flip it to the screen

Screen('FillRect',onScreen,gray);
Screen('TextSize',onScreen,fontsize);
Screen('DrawText',onScreen,'Thank you for participating in this task. Please alert the experimenter that you are finished.',...
    (centerX-400),(centerY+20),white);  %Display instructions
Screen('FillRect',onScreen,Vpixx2Vamp(0),trigger_size); %trigger for first block
% Screen('Flip',onScreen,[],0); %flip it to the screen
Screen(onScreen,'Flip'); %flip it to the screen
WaitSecs(0.5)
KbWait; %wait for subject to press button

ShowCursor;
Screen('Close',onScreen);

% /////////////////////////////////////////////////////////////////////////
%% Close EEG stream
lsl_close_inlet(inlet_EEG);
% /////////////////////////////////////////////////////////////////////////


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                      Post-Processing
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 % Apply linear transformation (get channel Pz at that point)
transchan = mask*dataAccu;
        
% Perform spectral decomposition
Xdata = fft(transchan, nfft);
% extract amplitude using Pythagorian theorem
amp1_bline = 2*(sqrt( imag(Xdata/nfft).^2 + real(Xdata/nfft).^2 ));
amp_tmp = amp1_bline(freqRange);
bline_mean = mean(amp_tmp);
clear amp_tmp
amp_tmp = amp1_bline(freqRangeall);
bline_mean_all = mean(amp_tmp);
clear amp_tmp

Rel_Amp = bline_mean/bline_mean_all;


% /////////////////////////////////////////////////////////////////////////
%% ASR calibration
disp('Training ASR, please wait...');
% Info.stateAsr = asr_calibrate(dataAccu(:, 1:EEG.srate*60), EEG.srate);
dataAccu = dataAccu(:, 1:dataAccuPointer-1);
stateAsr = asr_calibrate(dataAccu,EEG.srate);


% /////////////////////////////////////////////////////////////////////////
%% Save data
% Creating new folders if they don't exist 
if ~exist(['M:\Experiments\BCI\SubjData\' Info.subjID '\'],'dir')
    mkdir(['M:\Experiments\BCI\SubjData\' Info.subjID '\']);
end
    

% Save data
asrFileName = fullfile(['M:\Experiments\BCI\SubjData\' Info.subjID], [date '_baseline_ASR_state_v' Info.session '.mat']);

save(asrFileName,'Info','stateAsr','Xdata','nfft','srate','freqRange','freqband','srate_Amp',...
    'dataAccu','chunkMarker','chunkCount','dataAccuPointer','nfft','sessionDuration',...
    'bline_mean','bline_mean_all','Rel_Amp')




