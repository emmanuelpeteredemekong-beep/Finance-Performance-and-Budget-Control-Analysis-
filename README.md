# Finance-Performance-and-Budget-Control-Analysis-
Finance Performance and Budget Control Analysis using Python, Excel, SQL and Power bi including business insight and recommendations 
# Finance Performance and Budget Control Analysis

## 📌 Project Overview
This project analyzes finance performance, budget allocation, and spending patterns across departments to support better budget control and audit tracking. Using Python, Excel, SQL, and Power BI, I explored monthly spending trends, budget variance by account, and audit completion status to help stakeholders make data-driven decisions.

## 📂 Data Source
- **Source:** Synthetic dataset generated using Python for the purpose of this analysis
- **Size:** 150,000 financial records

## 🛠️ Tools & Skills Used
- **Python** - Data validation, cleaning and transformation 
- **Excel** – Financial analysis, pivot tables, initial exploration
- **SQL** – Data extraction, aggregation, and analysis queries
- **Power BI** – Interactive dashboard and data visualization

## 📈 Key Metrics (KPIs)
- **Total Budget Allocated:** $2.03bn
- **Total Sales:** 150K
- **Total Base Amount:** $2.00bn
- **Total Budget Variance:** ($12M)
- **Audit Completion:** 88.71% audited (133K of 150K), 9.84% pending review, remainder pending

## 🔍 Key Insights & Recommendations

**1. Monthly Spending Trend**
February spending dropped to $155M, $672K under budget, driven mainly by Engineering ($198K), Marketing ($143K), and Operations ($106K).
- *Action:* Monitor Engineering and Marketing weekly in Q1, since these two departments caused 50% of February's variance. Flag any project delays early to avoid cash flow gaps.

**2. Budget vs. Actual Spend by Department**
All 6 departments are under budget with no overspending. Sales shows the largest unused amount (-$2.33M), while HR shows the smallest (-$1.66M).
- *Action:* Reduce Sales' budget allocation for the next cycle and redistribute the funds to departments with tighter spend, such as HR and Operations.

**3. Budget Variance by Account**
Accounts 101000 and 410000 are significantly under budget (-$13M each), while 510000 is significantly over budget (+$13.27M). Other 
accounts stay within $120K variance.
- *Action:* These 3 accounts likely need a closer look — the size of the gap suggests either a data issue or a real budget planning gap.

**4. Audit Completion**
88.71% of transactions (133K of 150K) are audited, with the remaining ~11% pending.
- *Action:* Prioritize the pending transactions, since unaudited amounts carry a higher risk of undetected errors the longer they remain unreviewed.

## 📁 Repository Contents
- `SQL_script.sql` – Queries used for data extraction and analysis
- `Dashboard.pbix` – Interactive Power BI dashboard file
- `Screenshot.png` – Dashboard preview image
