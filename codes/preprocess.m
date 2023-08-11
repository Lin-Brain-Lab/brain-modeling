%Global Variable
global rejectArray
rejectArray = [];
subArray = [];
%Folder Paths
addpath("/home/anandn/eeglab2020_0")
fricPath = "/space_lin2/nikhil/preprocessed/fric"; %ica path
frocPath = "/space_lin2/nikhil/preprocessed/froc"; %oculormotor removed path
eeglab
%

for i = 1:334
    sub_id = i;
    if sub_id < 10
        subj = ['000' num2str(sub_id)];
    elseif sub_id < 100
            subj = ['00' num2str(sub_id)];
    else
        subj = ['0' num2str(sub_id)];
    end
    rawPath = ['/space_lin1/quanta/sub-' subj '/eeg/']; %raw data path
    
    subArray(end+1) = sub_id;
    EEG.etc.eeglabvers = '2020.0'; % this tracks which version of EEGLAB is being used, you may ignore it

    try
        EEG = pop_loadbv(rawPath, ['sub-' subj '_ses-01_task-rest.vhdr'], [], []);
    catch
        continue;
    end
    
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, [9 20] );
    EEG = eeg_checkset( EEG );
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',['sub-' subj '_ses-01_task-rest_fric.set'],'filepath',fricPath);
    EEG = eeg_checkset( EEG );

    %Remove bad components
    EEG = eeg_checkset( EEG );
    EEG = pop_loadset('filename',['sub-' subj '_ses-01_task-rest_fric.set'],'filepath',fricPath);
    EEG = pop_iclabel(EEG,'default');
    EEG = pop_icflag(EEG,[NaN NaN;NaN NaN;0.90 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN],subj);
    EEG = pop_subcomp(EEG, [], 0);

    EEG = pop_saveset( EEG, 'filename',['sub-' subj '_ses-01_task-rest_fro.set'],'filepath',frocPath);
    EEG = eeg_checkset( EEG );
end
% varname={'Participant #','# of Components'};
% table1 = table(rejectArray, subArray, 'VariableNames', varname);
