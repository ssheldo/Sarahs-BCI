function EEG = online_filt_EOG(EEG)
% This is an online filter that operates on continuous data, and removes artifacts using a
% regression technique, if artifact channels (e.g., EOG or EMG) are present (using recursive least
% squares) [1]. Note that noise in the artifact signals may be transferred onto the EEG channels.
% *Assumes the last two channels are the EOG channels*
%
% References:
%  [1] P. He, G.F. Wilson, C. Russel, "Removal of ocular artifacts from electro-encephalogram by adaptive filtering"
%      Med. Biol. Eng. Comput. 42 pp. 407-412, 2004



ffact = 0.9995; % Forgetting factor: Determines the memory length of the adaptive filter.
kernellen = 3; % Kernel length: The length/order of the temporal FIR filter kernel.

eegchans = 1:EEG.nbchan;    % eeg channel indices (number of selected channels)
eogchans = eegchans((end-1):end);  % eog channel indices (assumes the last two channels are EOG channels)
neog = length(eogchans);    % number of eog channel indices

% initialize RLS filter state
hist = zeros(neog,kernellen);     % hist is the block of the M last eog samples in matrix form
R_n = eye(neog * kernellen) / 0.01; % R(n-1)^-1 is the inverse matrix
H_n = zeros(neog*kernellen,length(eegchans));  % H(n-1) is the EOG filter kernel


% apply filter
[EEG.data,hist,H_n,R_n] = compute(EEG.data,hist,H_n,R_n,eegchans,eogchans,ffact);



% exp_endfun % end of online_filt_EOG



function [X,hist,H_n,R_n] = compute(X,hist,H_n,R_n,eeg,eog,ffact)
% for each sample...
for n = 1:size(X,2)
    % update the EOG history by feeding in a new sample
    hist = [hist(:,2:end) X(eog,n)];
    % vectorize the EOG history into r(n)        % Eq. 23
    tmp = hist';
    r_n = tmp(:);
    
    % calculate K(n)                             % Eq. 25
    K_n = R_n * r_n / (ffact + r_n' * R_n * r_n);
    % update R(n)                                % Eq. 24
    R_n = ffact^-1 * R_n - ffact^-1 * K_n * r_n' * R_n;
    
    % get the current EEG samples s(n)
    s_n = X(eeg,n);    
    % calculate e(n/n-1)                         % Eq. 27
    e_nn = s_n - (r_n' * H_n)';    
    % update H(n)                                % Eq. 26
    H_n = H_n + K_n * e_nn';
    % calculate e(n), new cleaned EEG signal     % Eq. 29
    e_n = s_n - (r_n' * H_n)';
    % write back into the signal
    X(eeg,n) = e_n;
end












