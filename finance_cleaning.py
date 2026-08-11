import pandas as pd
import numpy as np


# ============================================================
# 1. LOAD RAW FINANCIAL DATA
# ============================================================

INPUT_FILE = "Financial_Performance_150Kcsv.csv"
OUTPUT_FILE = "Financial_Performance_150K_Cleaned.csv"

df = pd.read_excel(INPUT_FILE)

print("=" * 60)
print("FINANCIAL DATA CLEANING")
print("=" * 60)

print(f"Original rows: {len(df):,}")
print(f"Original columns: {len(df.columns)}")


# ============================================================
# 2. STANDARDIZE COLUMN NAMES
# ============================================================

df.columns = (
    df.columns
    .str.strip()
    .str.replace(r"\s+", "_", regex=True)
)

print("\nColumn names standardized.")


# ============================================================
# 3. REMOVE COMPLETELY EMPTY ROWS AND COLUMNS
# ============================================================

df = df.dropna(axis=0, how="all")
df = df.dropna(axis=1, how="all")

print(f"Rows after removing completely blank rows: {len(df):,}")
print(f"Columns after removing completely blank columns: {len(df.columns)}")


# ============================================================
# 4. CLEAN TEXT FIELDS
# ============================================================

text_columns = df.select_dtypes(
    include=["object", "string"]
).columns

for column in text_columns:

    df[column] = (
        df[column]
        .astype("string")
        .str.strip()
        .str.replace(r"\s+", " ", regex=True)
    )


# ============================================================
# 5. HANDLE MISSING TEXT VALUES
# ============================================================

for column in text_columns:
    df[column] = df[column].fillna("Unknown")


# ============================================================
# 6. STANDARDIZE COMMON CATEGORICAL VALUES
# ============================================================

# These are examples of controlled fields in the finance dataset.
# Values are normalized without changing their business meaning.

categorical_columns = [
    "Company_Entity",
    "Region",
    "Cost_Center",
    "Department",
    "Account_Name",
    "Account_Group",
    "Subledger_Type",
    "Transaction_Currency",
    "Debit/Credit_Indicator",
    "Payment_Status",
    "Tax_Code",
    "Cash_Flow_Category",
    "Is_Posted",
    "Audit_Status",
    "Reconciliation_Flag",
    "Approved_By",
    "Counterparty_ID",
    "Counterparty_Type"
]

for column in categorical_columns:

    if column in df.columns:

        df[column] = (
            df[column]
            .astype("string")
            .str.strip()
        )


# ============================================================
# 7. CONVERT POSTING DATE TO DATETIME
# ============================================================

if "Posting_Date" in df.columns:

    df["Posting_Date"] = pd.to_datetime(
        df["Posting_Date"],
        errors="coerce"
    )


# ============================================================
# 8. CONVERT NUMERIC COLUMNS TO NUMERIC TYPES
# ============================================================

numeric_columns = [
    "Fiscal_Year",
    "Fiscal_Period",
    "Base_Amount_USD",
    "Local_Amount",
    "Exchange_Rate",
    "Payment_Terms_Days",
    "Tax_Amount_USD",
    "Budget_Allocated_USD",
    "Variance_to_Budget"
]

for column in numeric_columns:

    if column in df.columns:

        df[column] = pd.to_numeric(
            df[column],
            errors="coerce"
        )


# ============================================================
# 9. CHECK DUPLICATES
# ============================================================

duplicate_count = df.duplicated().sum()

print(f"\nDuplicate rows found: {duplicate_count:,}")

if duplicate_count > 0:
    df = df.drop_duplicates()

print(f"Rows after duplicate removal: {len(df):,}")


# ============================================================
# 10. CHECK JOURNAL ENTRY ID DUPLICATES
# ============================================================

if "Journal_Entry_ID" in df.columns:

    journal_duplicates = (
        df["Journal_Entry_ID"]
        .duplicated()
        .sum()
    )

    print(
        f"Duplicate Journal Entry IDs: "
        f"{journal_duplicates:,}"
    )


# ============================================================
# 11. DO NOT ALTER FINANCIAL VALUES
# ============================================================

# Negative financial values are NOT automatically removed.
# Zero values are NOT automatically removed.
# Missing numeric values are NOT replaced with zero.

print("\nFinancial values preserved without automatic modification.")


# ============================================================
# 12. BASIC DATA QUALITY SUMMARY
# ============================================================

print("\n" + "=" * 60)
print("DATA QUALITY SUMMARY")
print("=" * 60)

print("\nMissing values:")
print(
    df.isna()
    .sum()
    .sort_values(ascending=False)
)


# ============================================================
# 13. CHECK NUMERIC SUMMARY
# ============================================================

print("\nNumeric columns summary:")

print(
    df.select_dtypes(include=np.number)
    .describe()
)


# ============================================================
# 14. CHECK CATEGORICAL VALUES
# ============================================================

print("\nCategorical field review:")

review_columns = [
    "Debit/Credit_Indicator",
    "Payment_Status",
    "Tax_Code",
    "Cash_Flow_Category",
    "Is_Posted",
    "Audit_Status",
    "Reconciliation_Flag",
    "Counterparty_Type"
]

for column in review_columns:

    if column in df.columns:

        print(f"\n{column}:")
        print(
            df[column]
            .value_counts(dropna=False)
            .head(20)
        )


# ============================================================
# 15. SORT DATA
# ============================================================

if "Posting_Date" in df.columns:

    df = df.sort_values(
        by="Posting_Date",
        ascending=True
    )


# ============================================================
# 16. RESET INDEX
# ============================================================

df = df.reset_index(drop=True)


# ============================================================
# 17. EXPORT CLEAN DATASET
# ============================================================

df.to_csv(
    OUTPUT_FILE,
    index=False
)

print("\n" + "=" * 60)
print("CLEANING COMPLETE")
print("=" * 60)

print(f"Final rows: {len(df):,}")
print(f"Final columns: {len(df.columns):,}")
print(f"Output file: {OUTPUT_FILE}")
