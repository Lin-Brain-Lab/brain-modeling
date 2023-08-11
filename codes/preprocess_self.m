global rejectArray
rejectArray = []
subArray = []
addpath('/Users/nikhilanand/eeglab_work/eeglab2020_0 2'); % eeglab path
eeglab

% arr = [1,2,332,333,334];
arr = [2];
for i = 1:length(arr)
    sub_id = arr(i)
    if sub_id < 10
        subj = ['000' num2str(sub_id)];
    elseif sub_id < 100
        subj = ['00' num2str(sub_id)];
    else
        subj = ['0' num2str(sub_id)];
    end

    subArray(end+1) = sub_id;
    EEG.etc.eeglabvers = '2020.0'; % this tracks which version of EEGLAB is being used, you may ignore it
    
    % disp(subj);
    disp(['/Users/nikhilanand/eeglab_work/sub_preprocess_script/sub-' subj '/raw/sub-' subj '_ses-01_task-rest.vhdr']);

    try
        EEG = pop_loadbv(['/Users/nikhilanand/eeglab_work/sub_preprocess_script/sub-' subj '/raw'], ['sub-' subj '_ses-01_task-rest.vhdr'], [], []);
    catch
        EEG = pop_loadbv(['/Users/nikhilanand/eeglab_work/sub_preprocess_script/sub-' subj '/raw'], ['sub-' subj '_ses-01_resting.vhdr'], [], []);
    end
        
    % EEG = eeg_checkset( EEG );
    % EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
    % EEG = eeg_checkset( EEG );
    % EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
    % EEG = eeg_checkset( EEG );
    % EEG = pop_reref( EEG, [9 20] );
    % EEG = eeg_checkset( EEG );
    % EEG = eeg_checkset( EEG );
    % EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
    % EEG = eeg_checkset( EEG );
    % EEG = pop_saveset( EEG, 'filename',['sub-' subj '_ses-01_task-rest_fric.set'],'filepath',['/Users/nikhilanand/eeglab_work/sub_preprocess_script/sub-' subj '/ana']);
    % EEG = eeg_checkset( EEG );

    %Remove bad components
    EEG = eeg_checkset( EEG );
    EEG = pop_loadset('filename',['sub-' subj '_ses-01_task-rest_fric.set'],'filepath',['/Users/nikhilanand/eeglab_work/sub_preprocess_script/sub-' subj '/ana']);
    EEG.icawinv = pinv( EEG.icaweights*EEG.icasphere);
    eeg_ica = EEG.icawinv*EEG.data;

    Wf = EEG.icasphere*EEG.icaweights;
    data=reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials);
    seeg_ic = Wf*data;
    Uf_eeg = EEG.icaweights*EEG.icasphere;

    EEG = pop_iclabel(EEG,'default');
    EEG = pop_icflag(EEG,[NaN NaN;NaN NaN;0.90 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN], subj);
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset( EEG );

    % components = find(EEG.reject.gcompreject == 1);
    % disp(['Rejected components: ' components]);
    % save(['/Users/nikhilanand/eeglab_work/preprocess_exports/rejected_components/sub-' subj '_rejected.mat', 'components']);
    components = load(['/Users/nikhilanand/eeglab_work/preprocess_exports/rejected_components/sub-' subj '_rejected.mat'], 'components')

    % So we have displayed the component that was rejected. Also display
    % the correlation of that component with Fp1 - these two infos would
    % give us an idea of which subjects were odd and didn't have the
    % correct component removed.

    % eeg_vem = Uf_eeg(components.components(1),:)*EEG.data; % Assume only one component is extracted
    % eeg_allcomps = Uf_eeg*EEG.data

    %% calculate the correlations between EEG eyemovement signal and all SEEG components
    CM = zeros(1, size(seeg_ic,1));
    for i = 1: size(seeg_ic,1)
        % R = corrcoef(seeg_ic(i,:),eeg_vem);
        R = corrcoef(EEG.data(i,:),eeg_ica(components.components(1),:)); %
        CM(i) = R(2,1);
    end
    [Y,I] = max(abs(CM));
    save(['/Users/nikhilanand/eeglab_work/preprocess_exports/correlations/sub-' subj '_correlations.mat'], 'CM');

    EEG = pop_saveset( EEG, 'filename',['sub-' subj '_ses-01_task-rest_fro.set'],'filepath',['/Users/nikhilanand/eeglab_work/sub_preprocess_script/sub-' subj '/ana']);
    EEG = eeg_checkset( EEG );

end
