function BCI_feedback_task_v2()

% Triggers
%   10 = no change
%   11 = increase
%   12 = decrease
% 
%   20 + session # = start block
%   30 + session # = end block


%//////////////////////////////////////////////////////////////////////////
% Clear the workspace and the screen
sca;
close all;
clearvars;

%//////////////////////////////////////////////////////////////////////////
%% Input participant's IDs and date to save the data
Info.subjID = input('Participant Number:','s');
Info.condition = input('Feedback Condition (1 or 2):','s');
Info.train = input('Training Session Number:','s');
if str2double(Info.train) > 1
    Info.instruct = 'no';
else
    Info.instruct = input('Instructions? (yes or no):','s');
end
Info.time = datestr(now,30); % 'dd-mmm-yyyy HH:MM:SS'
Info.date = date; % day, month, year
% Create .m file to write data in
% Filename = [Info.subjID '--' Info.date '_' Info.condition '_fbdata.mat'];
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
%% Load the baseline data
[File,Path] = uigetfile(['M:\Experiments\BCI\SubjData\' Info.subjID '\*.mat'],...
    'Select baseline file');
Base_Data = load([Path,File]);

% stateASR = Base_Data.stateAsr; % get the asr calibration data
stateASR = Base_Data.stateAsr; % get the asr calibration data
% get the baseline adjusted to make it more rewarding
if str2double(Info.condition) == 1 %increasing
    baselinepower = Base_Data.Rel_Amp;
elseif str2double(Info.condition) == 2 %decreasing
    baselinepower = Base_Data.Rel_Amp;
end
%//////////////////////////////////////////////////////////////////////////
dirChange = 1;

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
disp('Good job! Opening a EEG inlet...');
inlet_EEG = lsl_inlet(result{1});


% #########################################################################
%% START PSYCHTOOLBOX

% Screen('Preference','SkipSyncTests', 0) % ensures it will run, should be removed if possible

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

% Get the size of the on screen window
[screenX, screenY] = Screen('WindowSize',onScreen);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
centerX = screenX * 0.5; % center of screen in X direction
centerY = screenY * 0.5; % center of screen in Y direction

trigger_size = [0 0 1 1]; %use [0 0 1 1] for eeg, 100 100 for photodiode

% Feedback drawing
delta = 720; 
baseRect = [0 delta screenX screenY]; %(left,top,right,bottom)
maxChange = 3; %change of feedback bar

% Make a base Rect to use for the base line marker 
baseRect2 = [0 0 12 12];
% Screen X positions of our baseline squares
squareXpos = (screenX * 0.0):30:(screenX * 1.0);
numSqaures = length(squareXpos);
squareYpos = screenY * 0.5; % not sure this is currently doing anything 

% Make our rectangle coordinates --> not a clue what this does yet
allRects = nan(4, 3);
for i = 1:numSqaures
    allRects(:, i) = CenterRectOnPointd(baseRect2, squareXpos(i), squareYpos); 
end


% HideCursor; %comment out when debugging

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Present Instructions
BCI_feedback_task_instructions(onScreen,fontsize,centerX,centerY,gray,black,white,Info.instruct,...
    str2double(Info.train),trigger_size)


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                     Data Acquisition Parameters
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

srate        = 500; %1000
srate_Amp    = 500; %1000 sampling rate of the amplifier
nfft         = 2^10; %srate = 500 then 0.5 Hz resolution
windowSize   = 500; % 1 sec; 1/2 second
windowInc    = 125; % 1/4; update every 1/2 second
chans        = Info.n_elect; % channel streaming data from
dataBuffer   = zeros(length(chans),(windowSize*6)/srate*srate_Amp);
% mrksBuffer   = zeros(1,(windowSize*6)/srate*srate_Amp);
dataBufferPointer = 1;

% Frequencies for spectral decomposition
freqband  = [8 13]; % alpha
freqs     = linspace(0, srate/2, floor(nfft/2)+1);
freqs     = freqs(2:end); % remove DC (match the output of PSD)
freqRange = intersect(find(freqs >= freqband(1)), find(freqs <= freqband(2)));
freqall   = [0.5 30]; % for EEG amplitude
freqRangeall = intersect(find(freqs >= freqall(1)), find(freqs <= freqall(2)));

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
chunkSize = windowInc*srate_Amp/srate; % at 500 so every 1/4 second is 125 samples

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sessionDuration = 60*5; % in seconds  60*5 = 5 mins
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% figure %open new figure

% Save processed data
chunkPower    = zeros(1, sessionDuration*10);
chunkPower2   = zeros(1, sessionDuration*10);
chunkAmp2     = zeros(1, sessionDuration*10);
chunkPower3   = zeros(1, sessionDuration*10);
amp1          = {};
amp_mean      = zeros(1, sessionDuration*10);
pxx           = {};
f             = {};
PSD           = {};
fq            = {};
PSD2          = {};
fq2           = {};
amp_mean_all  = zeros(1, sessionDuration*10);
Rel_Amp       = zeros(1, sessionDuration*10);
chunkMarker   = zeros(1, sessionDuration*10);
all_dirChange = zeros(1, sessionDuration*10);

dataAccu = zeros(length(chans),(sessionDuration+3)*srate);    
dataAccuPointer = 1; 

chunkCount = 1; % Keep track of number of data chunks

% #########################################################################
%% START TASK WINDOW

% HideCursor; %hide cursor

% Screen('FillRect', onScreen, gray);
% Screen('DrawLines',onScreen,[-7 7 0 0; 0 0 -7 7],1,0,[centerX,centerY],0);  %Print the fixation
% Screen('FillRect',onScreen,Vpixx2Vamp(20+Info.train),trigger_size); %trigger for first block
% Screen('Flip',onScreen,[],0); %flip it to the screen
% Screen(onScreen,'Flip'); %flip it to the screen



tic; % start timer

%% ========================================================================
                        %%%%%%%%%%%%%%%%%%%%%%
                        % Neurofeedback loop %
                        %%%%%%%%%%%%%%%%%%%%%%
% =========================================================================
while toc < sessionDuration
    
    % Get chunk from the EEG inlet
    [chunk,stamps] = inlet_EEG.pull_chunk();
    
    % Fill buffer
    if ~isempty(chunk) && size(chunk,2) > 1
        
%         chunk = filter(B,1,chunk,srate,2);
        
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
        clear x

        % Correct for EOG artifacts
        EEG = online_filt_EOG(EEG);
        
        % Filter data
        EEG.pnts = size(EEG.data,2);
        EEG.nchan = size(EEG.data,1);
        EEG.xmax = EEG.pnts/srate;
%         EEG.data = filter(B,1,EEG.data,srate,2); %band-pass filter
%         [EEG,state] = exp_eval(flt_fir('signal',EEG,'fspec',[0.5 1],'fmode','highpass','ftype','minimum-phase','state',state));
        [EEG_temp, state] = hlp_scope({'disable_expressions',true},@flt_fir,'signal',EEG,'fspec',[0.5 1],'fmode','highpass','ftype','minimum-phase', 'state', state);
        EEG = EEG_temp.parts{1,2}; %put filtered data back into EEG structure
        clear EEG_temp
        
        
        % apply ASR and update state
        [EEG.data stateASR]= asr_process(EEG.data, EEG.srate, stateASR);
        
        % accumulate data to save it
        dataAccu(:, dataAccuPointer:dataAccuPointer+size(EEG.data,2)-1) = EEG.data;
        dataAccuPointer = dataAccuPointer + size(EEG.data,2);
        chunkMarker(chunkCount) = dataAccuPointer;

        
        % ------- Get measure of alpha power ------
        
        % Apply linear transformation (get channel Pz at that point)
        ICAact = mask*EEG.data;

        % Perform spectral decomposition
        Xdata = fft(ICAact, nfft);
        % extract amplitude using Pythagorian theorem
        amp1{chunkCount} = 2*(sqrt( imag(Xdata/nfft).^2 + real(Xdata/nfft).^2 ));
        amp_tmp = amp1{chunkCount}(freqRange);
        amp_mean(chunkCount) = mean(amp_tmp); %mean alpha amp
        clear amp_tmp
        amp_tmp = amp1{chunkCount}(freqRangeall); %amplitude for freq 0.5-30
        amp_mean_all(chunkCount) = mean(amp_tmp);
        clear amp_tmp
        % get relative amplitude
        Rel_Amp(chunkCount) = amp_mean(chunkCount)/amp_mean_all(chunkCount);

                % Perform spectral decomposition
        dataSpec = fft(ICAact, nfft);
        dataSpec = dataSpec/nfft;
        dataSpec = dataSpec(freqRange);
%         X = mean(10*log10(abs(dataSpec).^2)/nfft);
        X = mean(2*(abs(dataSpec)));
        chunkPower(chunkCount) = X;
        clear dataSpec
                
%       % Perform spectral decomposition
        noverlap_PSD = [];	% Default of 50% overlap is taken with 'noverlap' empty.
        [PSD{chunkCount},fq{chunkCount}] = pwelch(ICAact(1,:)',hamming(length(ICAact)),noverlap_PSD,nfft,srate,'power');
        getfreqs = intersect( find(fq{chunkCount} >= freqband(1)), find(fq{chunkCount} <= freqband(2)) );
        chunkPower2(chunkCount) = mean(10*log10(PSD{chunkCount}(getfreqs)));
        clear getfreqs
        
        % Perform spectral decomposition
        [PSD2{chunkCount},fq2{chunkCount}] = pwelch(ICAact(1,:)',hamming(length(ICAact)),noverlap_PSD,nfft,srate);
        getfreqs = intersect( find(fq2{chunkCount} >= freqband(1)), find(fq2{chunkCount} <= freqband(2)) );
        chunkAmp2(chunkCount) = mean((PSD2{chunkCount}(getfreqs)).^0.5);
        clear getfreqs
        
        % ---------------------------------------------------------
        
        
        %%%%%%%% Feedback %%%%%%%%%%%%%%
        alphapower = Rel_Amp(chunkCount);
        if str2double(Info.condition) == 1 %increasing alpha
            if alphapower > baselinepower
                delta = delta - maxChange;
                if delta > maxChange %not at top of screen
                    baseRect = [0 delta 2160 1440];
                    dirChange = 1;
                else
                    delta = delta + maxChange;
                    baseRect = [0 maxChange 2160 1440];
                    dirChange = 0;
                end
            elseif alphapower < baselinepower 
                delta = delta + maxChange;
                if delta < screenY %not at bottom of screen
                    baseRect = [0 delta 2160 1440];
                    dirChange = 2;
                else
                    delta = delta - maxChange;
                    baseRect = [0 delta 2160 1440];
                    dirChange = 0;
                end
            else
                delta = delta;
                baseRect = [0 delta 2160 1440];
                dirChange = 0;
            end
        elseif str2double(Info.condition) == 2 %decreasing alpha
            if alphapower > baselinepower
                delta = delta + maxChange;
                if delta < screenY %not at bottom of screen
                    baseRect = [0 delta 2160 1440];
                    dirChange = 2;
                else
                    delta = delta - maxChange;
                    baseRect = [0 delta 2160 1440];
                    dirChange = 0;
                end
            elseif alphapower < baselinepower
                delta = delta - maxChange;
                if delta > maxChange %not at top of screen
                    baseRect = [0 delta 2160 1440];
                    dirChange = 1;
                else
                    delta = delta + maxChange;
                    baseRect = [0 maxChange 2160 1440];
                    dirChange = 0;
                end
            else
                delta = delta;
                baseRect = [0 delta 2160 1440];
                dirChange = 0;
            end
        end
        clear alphapower  
        
        
        % set the fill color to blue
%         fillColor = orange.*255;
        fillColor = white;
        baselineColor = blue.*255;
        % center the square (middle of the screen)
        CenterRectOnPointd(baseRect, xCenter, yCenter);

        % Draw the rect to the screen
        Screen('FillRect', onScreen, fillColor, baseRect);
        Screen('FillRect', onScreen, baselineColor, allRects);
        Screen('FillRect', onScreen, Vpixx2Vamp(10 + dirChange), trigger_size);

        
        Screen('Flip', onScreen); % Flip to the screen

        all_dirChange(chunkCount) = dirChange; %save direction of change
        
%         WaitSecs(0.1) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Plot processed data
%         gcf; plot(f{chunkCount},10*log10(pxx{chunkCount}))
%         grid
%         xlim([0 30])
%         drawnow % update figure
        
        WaitSecs(0.005);
        
        chunkCount = chunkCount + 1; %keep track of number of data chunks
        
    end
    
end
% =========================================================================
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

Screen('FillRect', onScreen, gray);
Screen('FillRect',onScreen,Vpixx2Vamp(30+str2double(Info.train)),trigger_size); %trigger for end of block
% Screen('Flip',onScreen,[],0); %flip it to the screen
Screen(onScreen,'Flip'); %flip it to the screen

Screen('FillRect',onScreen,gray);
Screen('TextSize',onScreen,fontsize);
Screen('DrawText',onScreen,'Thank you for participating in this task. Please alert the experimenter that you are finished.',...
    (centerX-600),(centerY+20),white);  %Display instructions
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
% lsl_close_inlet(inlet_marker);
% /////////////////////////////////////////////////////////////////////////
%% Save data
NF_FileName = fullfile(['M:\Experiments\BCI\SubjData\' Info.subjID], [date '_NFTraining_Session' Info.train '_cond' Info.condition '.mat']);
save(NF_FileName);
% /////////////////////////////////////////////////////////////////////////


% period = 1/EEG.srate; %based on sampling rate


















