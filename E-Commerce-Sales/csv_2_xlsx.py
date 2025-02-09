import pandas as pd

# Load the exported CSV
df = pd.read_csv("C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/duplicated_listings.csv")

# Save as Excel file
df.to_excel("duplicated_listings.xlsx", index=False)
