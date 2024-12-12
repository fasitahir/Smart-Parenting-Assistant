import pandas as pd

# Read the original CSV file
df = pd.read_csv('data_balita.csv')

# Column Name Mapping
column_mapping = {
    'Umur (bulan)': 'Age (months)',
    'Jenis Kelamin': 'Gender',
    'Tinggi Badan (cm)': 'Height (cm)',
    'Status Gizi': 'Nutrition Status'
}

df = df.rename(columns=column_mapping)

# Data Value Mapping
value_mapping = {
    'laki-laki': 'male',
    'perempuan': 'female',
    'tinggi': 'tall'
}

# Apply the value mapping to the relevant columns
df['Gender'] = df['Gender'].map(value_mapping).fillna(df['Gender'])  # Apply gender mapping
df['Nutrition Status'] = df['Nutrition Status'].map(value_mapping).fillna(df['Nutrition Status'])  # Apply nutrition mapping

# Save the translated data to a new CSV file (csv2)
df.to_csv('data_toddler.csv', index=False)
