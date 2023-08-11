import scipy.io
import numpy as np
import networkx as nx
import pickle
from sklearn.preprocessing import StandardScaler

features = np.zeros((152,1395))

for sub in range(1,153):
    filename = "resting_eeg_fconn_"+str(sub).zfill(4)+'.mat'
    
    try:
        mat_data = scipy.io.loadmat('model_for_connectivity/fconn_test_data/'+filename)
    except:
        continue

    full_data = mat_data["fconn"]

    if(full_data.shape==(30,30,17)):
        pass
    else:
        continue

    # print(full_data[:,:,[0,1,2]].shape)
    freqs = [0,1,2] # Vary this as a hyperparameter!
    data = full_data[:,:,freqs]
    n = data.shape[0]

    data_final = np.zeros((int(n*(n+1)/2),len(freqs))) # (465,3)

    for k in range(len(freqs)):
        d = 0
        for i in range(data.shape[0]):
            for j in range(data.shape[1]):
                if(j>=i):
                    data_final[d,k] = data[i,j,k]
                    # print(d,i,j)
                    d+=1

    data_final = data_final.flatten()
    features[sub-1] = data_final


print(features)
np.savetxt('model_for_connectivity/modelling_new/features.csv', features, delimiter=',')