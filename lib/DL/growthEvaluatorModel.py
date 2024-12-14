import pickle
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import pandas as pd 

import os

# Get the root directory of the project
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))

# Construct the absolute path
data_path = os.path.join(root_dir, 'Data', 'prepared_data.csv')

label_encoder = LabelEncoder()

df = pd.read_csv(data_path)


# Feature and target separation
X_over = df.drop('Nutrition Status', axis=1)
y_over = df['Nutrition Status']

# Split into train and test sets
X_train_over, X_test_over, y_train_over, y_test_over = train_test_split(X_over, y_over, test_size=0.2, random_state=42)

label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train_over)


random_forest = RandomForestClassifier(random_state=42)

random_forest.fit(X_train_over, y_train_encoded)

# Make predictions
y_pred_over = random_forest.predict(X_test_over)
y_pred = label_encoder.inverse_transform(y_pred_over)
print("Prediction features:", X_test_over.columns)



store_path = os.path.join(root_dir, 'lib','Model')


# Save the RandomForest model
model_path = store_path + "\\random_forest_model.pkl"
with open(model_path, "wb") as file:
    pickle.dump(random_forest, file)

# Save the LabelEncoder
label_encoder_path = store_path + "\\label_encoder.pkl"
with open(label_encoder_path, "wb") as file:
    pickle.dump(label_encoder, file)

print(f"Model and LabelEncoder saved successfully!")