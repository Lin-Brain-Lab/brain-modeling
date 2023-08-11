addpath("/MATLAB Drive/eeglab2020_0")
eeglab

for sub = [1,2,3,332,333,334]
    if sub<10
        s = ['000' char(string(sub))];
    elseif sub<100
        s = ['00' char(string(sub))];
    else
        s = ['0' char(string(sub))];
    end
    disp("s: ");
    disp(s);

        
    try
        EEG = pop_loadset(['sub-' s '_ses-01_task-rest_fro.set'],['/MATLAB Drive/subjects/sub-' s '/ana']);
    catch
        EEG = pop_loadset(['sub-' s '_ses-01_resting_fro.set'],['/MATLAB Drive/subjects/sub-' s '/ana']);
    end

    events = eeg_emptyset();
    
    events = [];
    sampling_rate = EEG.srate;
    
    interval = 30;
    interval_samples = interval * sampling_rate;
    total_evnts = floor(EEG.pnts/interval_samples);
    
    for i = 1:total_evnts
    event.type = num2str(i);  % Event type can be a unique identifier for each event
        event.latency = (i - 1) * interval_samples + 1;  % Adjust latency based on 0-based indexing
        event.duration = 1;  % Set event duration to 1 sample (instantaneous event)
    
        % Add the event to the event structure
        events = [events, event];
    end
    
    EEG.event = events;
    disp("Event:");
    disp(EEG.event);
    EEG = pop_epoch(EEG,{1,10,2,3,4,5,6,7,8,9},[0 60],'newname', [s '_frico_epochs'],'epochinfo', 'yes');
    
    % pop_eegplot(EEG);
    
    EEG = pop_saveset( EEG, 'filename',['sub-' s '_ses-01_task-rest_fro_epoched.set'],'filepath','/MATLAB Drive/epoched_data/');
end