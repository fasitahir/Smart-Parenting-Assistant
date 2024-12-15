from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import numpy as np 
import pandas as pd 
import seaborn as sns
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import TomekLinks

# Load the dataset
df = pd.read_csv('data_toddler.csv')

# Display initial data exploration
df.head()
df.describe()

# Check unique values in the target column
unique_statuses = df['Nutrition Status'].unique()
print("Unique Nutrition Status:", unique_statuses)

# Split numerical and categorical columns
df_numerical = df.select_dtypes(include=['int64', 'float64'])
df_encoded = pd.get_dummies(df.select_dtypes(include=['object']), drop_first=True)

# Combine numerical and encoded categorical data
df_combined = pd.concat([df_numerical, df_encoded], axis=1)

# Correlation heatmap
correlation_matrix_combined = df_combined.corr()
plt.figure(figsize=(12, 10))
sns.heatmap(correlation_matrix_combined, annot=True, cmap='coolwarm', fmt=".2f")
plt.title('Correlation Heatmap for All Variables')
plt.show()

# Countplots
plt.figure(figsize=(8, 6))
sns.countplot(x='Gender', data=df)
plt.title('Countplot for Gender')
plt.show()

plt.figure(figsize=(8, 6))
sns.countplot(x='Nutrition Status', data=df)
for p in plt.gca().patches:
    plt.gca().annotate(f'{p.get_height()}', (p.get_x() + p.get_width() / 2., p.get_height()),
                       ha='center', va='center', xytext=(0, 10), textcoords='offset points')
plt.title('Countplot for Nutrition Status')
plt.show()

# Boxplot for numerical variables
plt.figure(figsize=(12, 8))
sns.boxplot(data=df_numerical, showfliers=True)
plt.title('Boxplot for Numerical Variables with Outliers')
plt.show()

# Feature and target separation
X = df.drop('Nutrition Status', axis=1)
y = df['Nutrition Status']

# Split into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Encode categorical features
encoder = OneHotEncoder(sparse_output=False, drop='first')
X_train_encoded = X_train.copy()
X_test_encoded = X_test.copy()

X_train_encoded[['Gender']] = encoder.fit_transform(X_train[['Gender']])
X_test_encoded[['Gender']] = encoder.transform(X_test[['Gender']])

# Encode target labels
label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)
y_test_encoded = label_encoder.transform(y_test)

# Train and Evaluate Models
def evaluate_model(model, X_test, y_test, model_name):
    y_pred_encoded = model.predict(X_test)
    y_pred = label_encoder.inverse_transform(y_pred_encoded)
    
    # Accuracy
    accuracy = accuracy_score(y_test, y_pred)
    print(f'{model_name} Test Accuracy: {accuracy * 100:.2f}%')

    # Classification report
    report = classification_report(y_test, y_pred, output_dict=True)
    precision = report['weighted avg']['precision']
    recall = report['weighted avg']['recall']
    f1_score = report['weighted avg']['f1-score']
    print(f"{model_name} Precision: {precision:.2f}, Recall: {recall:.2f}, F1-Score: {f1_score:.2f}, Accuracy: {accuracy:.2f}")

    # Confusion matrix
        # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    cm_labels = label_encoder.classes_

    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=cm_labels, yticklabels=cm_labels, annot_kws={"size": 14})
    plt.title(f'Confusion Matrix {model_name}', fontsize=16)
    plt.xlabel('Predicted Labels', fontsize=15)
    plt.ylabel('True Labels', fontsize=15)
    plt.xticks(fontsize=14)
    plt.yticks(fontsize=14)
    plt.show()
# Train XGBoost model
xgb_model = XGBClassifier(random_state=42)
xgb_model.fit(X_train_encoded, y_train_encoded)
evaluate_model(xgb_model, X_test_encoded, y_test, "XGBoost")

# Train Random Forest model
random_forest = RandomForestClassifier(random_state=42)
random_forest.fit(X_train_encoded, y_train_encoded)
evaluate_model(random_forest, X_test_encoded, y_test, "Random Forest")

# Train KNN model
knn = KNeighborsClassifier()
knn.fit(X_train_encoded, y_train_encoded)
evaluate_model(knn, X_test_encoded, y_test, "KNN")

# Balancing the dataset
# SMOTE for oversampling



# X_encoded = pd.get_dummies(X)
# label_encoder = LabelEncoder()
# y_encoded = label_encoder.fit_transform(y)

# smote = SMOTE(sampling_strategy='auto', random_state=42)
# X_smote, y_smote = smote.fit_resample(X_encoded, y_encoded)

# # Create oversampled dataset
# df_smote = pd.concat(
#     [pd.DataFrame(X_smote, columns=X_encoded.columns), 
#      pd.DataFrame(label_encoder.inverse_transform(y_smote), columns=['Nutrition Status'])], 
#     axis=1
# )
# # df_smote.to_csv('oversampled_data.csv', index=False)
# print("Oversampled dataset created.")

# # Random undersampling
# tomek = TomekLinks()
# X_tomek, y_tomek = tomek.fit_resample(X_encoded, y_encoded)

# # Create undersampled dataset
# df_tomek = pd.concat(
#     [pd.DataFrame(X_tomek, columns=X_encoded.columns), 
#      pd.DataFrame(label_encoder.inverse_transform(y_tomek), columns=['Nutrition Status'])], 
#     axis=1
# )
# # df_tomek.to_csv('undersampled_data.csv', index=False)
# print("Undersampled dataset created.")
