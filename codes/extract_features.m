addpath("/Users/nikhilanand/eeglab_work/eeglab2020_0 2")
eeglab

for sub = [1,2,3,332,333,334]
    if sub<10
        s = ['000' char(string(sub))];
    elseif sub<100
        s = ['00' char(string(sub))];
    else
        s = ['0' char(string(sub))];
    end
    
    EEG = pop_loadset(['sub-' s '_ses-01_task-rest_fro_epoched.set'],'/Users/nikhilanand/eeglab_work/epoched_data/');

    % deltaBand = [0.5, 4];
    % thetaBand = [4, 8];
    % alphaBand = [8, 14];
    % betaBand = [14, 30];
    % gammaBand = [30, Inf];

    efData = zeros(size(EEG.data,1),size(EEG.data,2),size(EEG.data,3),5);
    arr = [0.5,4,8,14,30];

    for i = 1:4
        disp(i);
        low = arr(i);
        high = arr(i+1);
        efData(:,:,:,i) = pop_eegfiltnew(EEG,low,high,3302,0,[],0).data;
    end

    low = arr(5);
    efData(:,:,:,5) = pop_eegfiltnew(EEG,low,[],3302,0,[],0).data;

    % Getting magnitude data vector
    magData = zeros(size(EEG.data,1),size(EEG.data,2),size(EEG.data,3),5);
    [channels, ~, epochs, bands] = size(efData);
    
    for ei = 1:epochs
        for ci = 1:channels
            for bi = 1:5
                epochData = squeeze(efData(ci,:,ei,bi));
                h = hilbert(epochData);
                mag = abs(h).^2;
                re = real(h);
                im = imag(h);
                magData(ci,:,ei,bi) = mag;
                plot(mag);
            end
        end
    end

    % Computing envelope features

    [channels, samples, epochs, bands] = size(magData);
    magFeatures = zeros(channels, bands, 6);

    for ch = 1:channels
        for b = 1:bands
            data = magData(ch,:,:,b);
            epochStats = [mean(data,2); median(data,2); mode(data,2); 
                std(data,0,2); kurtosis(data,1,2); skewness(data,1,2)];
            magFeatures(ch,b,:) = mean(epochStats,3);
        end
    end
    
    
    save(['/Users/nikhilanand/eeglab_work/exports/amp/sub-' s '_amp_data.mat'], 'magFeatures');

    % PSD Data vector
    numBins = 500;
    channels = size(EEG.data,1);
    epochs = size(EEG.data,3);

    psdData = zeros(channels,numBins,epochs,5);
    [channels, ~, epochs, bands] = size(efData);
    
    for ei = 1:epochs
        for ci = 1:channels
            for bi = 1:5
                epochData = squeeze(efData(ci,:,ei,bi));
                [psd, frequencies] = pwelch(epochData, [], [], [], EEG.srate);
                if bi == 5
                    interpolatedPSD = interp1(frequencies, psd, linspace(arr(5), 100, numBins));
                else
                    interpolatedPSD = interp1(frequencies, psd, linspace(arr(bi), arr(bi+1), numBins));
                end

                psdData(ci,:,ei,bi) = interpolatedPSD;
            end
        end
    end

    % Getting features and saving

    [channels, ~, epochs, bands] = size(psdData);
    psdFeatures = zeros(channels, 3, bands);

    for ch = 1:channels
        for b = 1:bands
            psd = squeeze(psdData(ch, :, :, b));

            if b == 5
                top = 100;
            else
                top = arr(b+1);
            end

            totalPower = sum(psd);
            meanPower = totalPower/(top-arr(b)); % arr(b+1) - arr(b) is the frequency range
            totalPower = mean(totalPower);
            meanPower = mean(meanPower);
            
            cumulativePower = cumsum(psd);
            edgeFreqIdx = find(cumulativePower >= 0.95*totalPower, 1);
            edgeFreq = (edgeFreqIdx - 1)*(top-arr(b))/500;

            psdFeatures(ch, :, b) = [totalPower, meanPower, edgeFreq];
            % psdFeatures = permute(psdFeatures, [1, 3, 2]);
        end
    end

    save(['/Users/nikhilanand/eeglab_work/exports/psd/sub-' s '_psd_data.mat'], 'psdFeatures');

    % Relative powers
    [channels, bins, epochs, bands] = size(psdData);
    deltaIdx = 1;
    thetaIdx = 2;
    alphaIdx = 3;
    betaIdx = 4;
    gammaIdx = 5;

    relPowFeatures = zeros(channels, 7);

    for ch = 1:channels
        deltaPower = sum(psdData(ch, :, deltaIdx));
        thetaPower = sum(psdData(ch, :, thetaIdx));
        alphaPower = sum(psdData(ch, :, alphaIdx));
        betaPower = sum(psdData(ch, :, betaIdx));
        gammaPower = sum(psdData(ch, :, gammaIdx));

        relPowFeatures(ch, 1) = thetaPower / alphaPower;
        relPowFeatures(ch, 2) = betaPower / alphaPower;
        relPowFeatures(ch, 3) = (thetaPower + alphaPower) / betaPower;
        relPowFeatures(ch, 4) = thetaPower / betaPower;
        relPowFeatures(ch, 5) = (thetaPower + alphaPower) / (alphaPower + betaPower);
        relPowFeatures(ch, 6) = gammaPower / deltaPower;
        relPowFeatures(ch, 7) = (gammaPower + betaPower) / (deltaPower + alphaPower);
    end

    save(['/Users/nikhilanand/eeglab_work/exports/rel_power/sub-' s '_rel_power.mat'], 'relPowFeatures');

end