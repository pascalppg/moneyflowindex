import pandas as pd
import numpy as np

df = pd.read_csv('sample.csv')

# STEP 1 : Calculate the ‘Typical Price’
# TP = (High + Low + Close) / 3

df['Typical_Price'] = (df['High'] + df['Low'] + df['Close']) / 3

# STEP 2: Calculate the ‘Money Flow’
# MF = Typical Price * Volume

df['Money_Flow'] = df['Typical_Price'] * df['Volume']

# STEP 3
df['Prev_TP'] = df['Typical_Price'].shift(1)

df['Positive_MF'] = np.where(
    df['Typical_Price'] > df['Prev_TP'],
    df['Money_Flow'],
    0
)

df['Negative_MF'] = np.where(
    df['Typical_Price'] <= df['Prev_TP'],
    df['Money_Flow'],
    0
)

df.loc[0, ['Positive_MF', 'Negative_MF']] = np.nan

# Function calculate MFI
def calculate_mfi(dataframe, m):
    df_temp = dataframe.copy()

    df_temp[f'PMF_{m}'] = df_temp['Positive_MF'].rolling(window=m).sum()
    df_temp[f'NMF_{m}'] = df_temp['Negative_MF'].rolling(window=m).sum()

    df_temp[f'MFR_{m}'] = df_temp[f'PMF_{m}'] / df_temp[f'NMF_{m}'].replace(0, np.nan)

    df_temp[f'MFI_{m}'] = 100 * (df_temp[f'MFR_{m}'] / (1 + df_temp[f'MFR_{m}']))

    return df_temp

# Generate output file
for m in [5, 7, 10]:
    result = calculate_mfi(df, m)
    output_file = f'case3_answer{m}.csv'
    result.to_csv(output_file, index=False)
    print(f"Generated: {output_file}")