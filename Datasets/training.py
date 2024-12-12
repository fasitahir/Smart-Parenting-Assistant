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


label_encoder = LabelEncoder()

df_tomek = pd.read_csv('oversampled_data.csv')

plt.figure(figsize=(8, 6))
sns.countplot(x='Nutrition Status', data=df_tomek)
for p in plt.gca().patches:
    plt.gca().annotate(f'{p.get_height()}', (p.get_x() + p.get_width() / 2., p.get_height()),
                       ha='center', va='center', xytext=(0, 10), textcoords='offset points')
plt.title('Countplot for Nutrition Status')
plt.show()

# Train XGBoost model
# Feature and target separation
X_over = df_tomek.drop('Nutrition Status', axis=1)
y_over = df_tomek['Nutrition Status']

# Split into train and test sets
X_train_over, X_test_over, y_train_over, y_test_over = train_test_split(X_over, y_over, test_size=0.2, random_state=42)

label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train_over)


xgb_model = XGBClassifier(random_state=42)
xgb_model.fit(X_train_over, y_train_encoded)

# Make predictions
y_pred_over = xgb_model.predict(X_test_over)
y_pred = label_encoder.inverse_transform(y_pred_over)

# Accuracy
accuracy = accuracy_score(y_test_over, y_pred)
print(f'Test Accuracy: {accuracy * 100:.2f}%')

# Classification report
print("\nClassification Report:")
print(classification_report(y_test_over, y_pred))

# Confusion matrix
cm = confusion_matrix(y_test_over, y_pred)
cm_labels = label_encoder.classes_

plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=cm_labels, yticklabels=cm_labels)
plt.title('Confusion Matrix XGBoost')
plt.xlabel('Predicted Labels')
plt.ylabel('True Labels')
plt.show()




random_forest = RandomForestClassifier(random_state=42)
random_forest.fit(X_train_over, y_train_encoded)

# Make predictions
y_pred_over = random_forest.predict(X_test_over)
y_pred = label_encoder.inverse_transform(y_pred_over)

# Accuracy
accuracy = accuracy_score(y_test_over, y_pred)
print(f'Test Accuracy: {accuracy * 100:.2f}%')

# Classification report
print("\nClassification Report:")
print(classification_report(y_test_over, y_pred))

# Confusion matrix
cm = confusion_matrix(y_test_over, y_pred)
cm_labels = label_encoder.classes_

plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=cm_labels, yticklabels=cm_labels)
plt.title('Confusion Matrix Random Forest')
plt.xlabel('Predicted Labels')
plt.ylabel('True Labels')
plt.show()