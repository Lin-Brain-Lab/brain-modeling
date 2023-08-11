import scipy.io
import numpy as np
import networkx as nx
import pickle
from sklearn.preprocessing import StandardScaler

features = np.zeros((152,1530))

for sub in range(1,153):
    filename = "resting_eeg_fconn_"+str(sub).zfill(4)+'.mat'
    
    try:
        mat_data = scipy.io.loadmat('model_for_connectivity/fconn_test_data/'+filename)
    except:
        continue

    feats = np.zeros((17,30,3))

    if(mat_data["fconn"].shape==(30,30,17)):
        pass
    else:
        continue

    degrees = np.zeros((17,30))
    degrees[:] = -1

    # Computing degree of nodes
    for i in range(17):
        graph = mat_data["fconn"][:,:,i]
        graph = np.where(graph < 0.3, 0,graph)
        ch = graph.shape[0]

        for j in range(30):
            jgraph = graph[j,:]
            for k in range(30):
                conn = jgraph[k]
                degrees[i,j] += conn

    print(degrees[3])
    feats[:,:,0] = degrees

    bcents = np.zeros((17,30))

    # Computing BCs
    for i in range(17):
        graph = mat_data["fconn"][:,:,1]
        graph = np.where(graph < 0.3, 0,graph)
        graph = np.where(graph == 0, 0, 1/graph)
        graph = np.where(graph == 1, 0, graph)
        G = nx.from_numpy_array(graph)
        bc = nx.betweenness_centrality(G,normalized=False,weight='weight')
        bc_arr = list(bc.values())
        bcents[i,:] = bc_arr

    feats[:,:,1] = bcents

    ecents = np.zeros((17,30))

    # Computing ECs
    for i in range(17):
        graph = mat_data["fconn"][:,:,1]
        graph = np.where(graph < 0.3, 0,graph)
        graph = np.where(graph == 1, 0, graph)
        G = nx.from_numpy_array(graph)
        ec = nx.eigenvector_centrality(G,weight='weight')
        ec_arr = list(ec.values())
        ecents[i,:] = ec_arr

    feats[:,:,2] = ecents

    scaler = StandardScaler()
    scaled = scaler.fit_transform(feats.reshape(-1,3)) 
    scaled = scaled.flatten()
    features[sub-1] = scaled

print(features)
np.savetxt('model_for_connectivity/features.csv', features, delimiter=',')