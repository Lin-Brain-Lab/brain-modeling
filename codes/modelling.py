import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.svm import SVR
from sklearn.model_selection import KFold
from sklearn.metrics import mean_absolute_error

data = np.loadtxt('model_for_connectivity/features.csv', delimiter=',')

variances = np.var(data, axis=0)

# Testing variance of features

sorted_variances = np.sort(variances)[::-1]
x = np.arange(1, len(sorted_variances) + 1)

plt.plot(x, sorted_variances)
plt.xlabel('Feature Index')
plt.ylabel('Variance')
plt.title('Variance of Features')
plt.show()

# Filtering 210 best features and extracting data labels and features

indices_of_interest = np.argsort(variances)[-1520:] # Hyperparameter #1: How many top features should be used?
new_data = data[:,indices_of_interest]

indices_of_interest_sorted = np.sort(indices_of_interest)
converted_indices = ['ch' + str(i//51 + 1) + 'b' + str((i%51)//3 + 1) + 'f' + str(i%3 + 1) for i in indices_of_interest_sorted]
print(converted_indices)
dfX = pd.DataFrame(new_data, columns=converted_indices)

data_info = pd.read_csv('model_for_connectivity/data_info.csv',usecols=[0,1])
data_info = data_info.loc[:120]
data_filt = data_info.dropna()

subjects_list = data_filt['BASIC_INFO_ID'].unique().tolist()
sub_nums = [int(subject.split('-')[1]) for subject in subjects_list]
print(sub_nums)

arr = np.array(sub_nums)
existing_indices = arr - 1
dfXExisting = dfX.loc[existing_indices]

X = dfXExisting.values
labels = data_filt.values[:,1]
aug_labels = np.array(labels) + np.random.normal(0, 0, len(labels)) # Hyperparameter #2: Whether to augment? (Change standard deviation to 0)

# Fitting to the model

regressor = SVR(kernel='rbf') # Hyperparameter #2: Which regressor to use? Which kernel?
regressor.fit(X,aug_labels)

mae = sum(abs(regressor.predict(X) - aug_labels))/len(aug_labels)

array2d = np.zeros((len(aug_labels),2))
print(array2d.shape)
array2d[:,0] = aug_labels
array2d[:,1] = regressor.predict(X)

# Plotting age vs predictions

x = range(len(aug_labels))
plt.plot(x, array2d[:,0], label='Augmented ages')
plt.plot(x, array2d[:,1], label='Regressor predictions')
plt.xlabel('X-axis')
plt.ylabel('Y-axis')
plt.legend()
plt.show()

sorted = array2d[array2d[:, 0].argsort()]
x = range(len(aug_labels))
plt.plot(x, sorted[:,0], label='Augmented ages')
plt.plot(x, sorted[:,1], label='Regressor predictions')
plt.xlabel('X-axis')
plt.ylabel('Y-axis')
plt.legend()
plt.show()

# KFold Cross-validation

svr = SVR(kernel='rbf')

fold_errors = []

y = aug_labels

kf = KFold(n_splits=10, shuffle=True)

for train_index, val_index in kf.split(X):
    X_train, X_val = X[train_index], X[val_index]
    y_train, y_val = y[train_index], y[val_index]
    
    svr.fit(X_train, y_train)
    
    y_pred = svr.predict(X_val)
    fold_error = mean_absolute_error(y_val, y_pred)
    
    fold_errors.append(fold_error)

for i, error in enumerate(fold_errors):
    print(f"Iteration {i+1}: Validation Error = {error}")

print("Average validation error: ", np.mean(fold_error))