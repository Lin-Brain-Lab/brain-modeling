addpath("/Users/nikhilanand/eeglab_work/eeglab2020_0 2")
eeglab

avgPSD = zeros(310,5);

arr = [1,2,332,333,334];

for i = [1,2,3,4,5]
    sub = arr(i);
    if sub<10
        s = ['000' char(string(sub))];
    elseif sub<100
        s = ['00' char(string(sub))];
    else
        s = ['0' char(string(sub))];
    end
    
    filePath = fullfile('/Users/nikhilanand/eeglab_work/psd_exports/', ['sub-' s '_psd_data.mat']);
    data = load(filePath).psdTensor;

    meanT = mean(data, 2);
    meanV = reshape(meanT, [], 1);

    avgPSD(:,i) = meanV;
    
end

matrix = cell2mat(avgPSD);
psdCorrTensor = corrcoef(matrix');

% Save the psdTensor as a MAT file
save(['/Users/nikhilanand/eeglab_work/psd_correlations/sub-' s '_psd_corr.mat'], 'psdCorrTensor');