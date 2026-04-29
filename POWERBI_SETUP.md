# Power BI Dashboard Setup Guide
## Nifty 50 Sector Rotation & Anomaly Detection

---

## Step 1 — Connect Power BI to MySQL

1. Open Power BI Desktop
2. Click **Get Data** → **MySQL Database**
3. Server: `localhost` | Database: `nifty_analysis`
4. Import these tables:
   - `stock_data` (main table)
   - Or connect directly to your CSV files from `data/` folder

---

## Page 1 — Sector Overview (Monthly Return Heatmap)

**Visual:** Matrix
- Rows: `Sector`
- Columns: `Month`
- Values: `Monthly_Return_Pct` (Average)
- Conditional formatting on values:
  - Red = negative returns
  - White = near zero
  - Green = positive returns

**Insight this shows:** Which sectors had strong/weak months at a glance

---

## Page 2 — Volatility Comparison

**Visual:** Horizontal Bar Chart
- Y-axis: `Ticker`
- X-axis: `Avg_Volatility_Pct`
- Color by: `Sector`
- Sort: Descending by volatility

**Add:** Slicer for `Sector` so user can filter by sector

**Insight this shows:** Which stocks are highest/lowest risk

---

## Page 3 — Sector Rotation

**Visual:** Line Chart
- X-axis: `Quarter`
- Y-axis: `Quarterly_Return_Pct`
- Legend: `Sector` (one line per sector)

**Add:** Data labels on highest point of each line

**Insight this shows:** Which sector led/lagged each quarter over 3 years

---

## Page 4 — Anomaly Event Log

**Visual:** Table
- Columns: `Date`, `Ticker`, `Sector`, `Return_Pct`, `Volume`, `Anomaly_Direction`
- Conditional formatting:
  - `Anomaly_Direction = Positive Spike` → Green background
  - `Anomaly_Direction = Negative Crash` → Red background

**Add:** Card visuals at top showing:
- Total anomalies detected
- Most anomalous sector
- Largest single-day move

**Insight this shows:** Complete log of statistically unusual market events

---

## DAX Measures to Create

```
Total Anomalies = COUNTROWS(FILTER(stock_data, stock_data[Anomaly] = TRUE))

Avg Monthly Return = AVERAGE(stock_data[Monthly_Return_Pct])

Most Volatile Stock = 
    FIRSTNONBLANK(
        TOPN(1, VALUES(stock_data[Ticker]), 
        CALCULATE(AVERAGE(stock_data[Volatility_30D]))), 1
    )
```

