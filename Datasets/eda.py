from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.preprocessing import OneHotEncoder, LabelEncoder
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import numpy as np 
import pandas as pd 
import seaborn as sns
from sklearn.compose import ColumnTransformer


import os
for dirname, _, filenames in os.walk('/kaggle/input'):
    for filename in filenames:
        print(os.path.join(dirname, filename))

df = pd.read_csv('data_toddler.csv')

df.head()
df.describe()

unique_statuses = df['Status'].unique()
print(unique_statuses)

df_numerical = df.select_dtypes(include=['int64', 'float64'])

# One-hot encode categorical variables
df_encoded = pd.get_dummies(df.select_dtypes(include=['object']))

# Concatenate numerical and encoded categorical variables
df_combined = pd.concat([df_numerical, df_encoded], axis=1)

# Create a heatmap for all variables
correlation_matrix_combined = df_combined.corr()
plt.figure(figsize=(12, 10))
sns.heatmap(correlation_matrix_combined, annot=True, cmap='coolwarm', fmt=".2f")
plt.title('Correlation Heatmap for All Variables')
plt.show()


sns.pairplot(df_combined)
plt.suptitle('Pairplot for All Variables', y=1.02)
plt.show()


plt.figure(figsize=(8, 6))
sns.countplot(x='Gender', data=df)
plt.title('Countplot for Gender')
plt.show()


plt.figure(figsize=(8, 6))
sns.countplot(x='Status', data=df)

# Add count annotations on the bars
for p in plt.gca().patches:
    plt.gca().annotate(f'{p.get_height()}', (p.get_x() + p.get_width() / 2., p.get_height()),
                       ha='center', va='center', xytext=(0, 10), textcoords='offset points')

plt.title('Countplot for Status')
plt.show()

plt.figure(figsize=(12, 8))
sns.boxplot(data=df_numerical, showfliers=True)
plt.title('Boxplot for Numerical Variables with Outliers')
plt.show()


X = df.drop('Status', axis=1)
y = df['Status']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)


encoder = OneHotEncoder(sparse=False, drop='first')
X_train_encoded = X_train.copy()
X_test_encoded = X_test.copy()

X_train_encoded[['Gender']] = encoder.fit_transform(X_train[['Gender']])

X_test_encoded[['Gender']] = encoder.transform(X_test[['Gender']])


label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)


xgb_model = XGBClassifier(random_state=42)


xgb_model.fit(X_train_encoded, y_train_encoded)


y_pred_encoded = xgb_model.predict(X_test_encoded)


y_pred = label_encoder.inverse_transform(y_pred_encoded)


accuracy = accuracy_score(y_test, y_pred)
print(f'Test Accuracy: {accuracy * 100:.2f}%')

print("\nClassification Report:")
print(classification_report(y_test, y_pred))

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))

