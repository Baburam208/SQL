import pandas as pd

df = pd.read_excel("Dataset1.xlsx", sheet_name="Working")
df.to_csv("dataset1.csv", index=False)
