<img width="1672" height="941" alt="1) SECTOR OVERVIEW SS" src="https://github.com/user-attachments/assets/cbc1067c-2f05-426a-8074-f58b7c7f4cf7" />
# Nifty 50 Sector Rotation & Anomaly Detection

## Overview
End-to-end financial analytics project analyzing Indian large-cap equities across multiple sectors using Python, SQL, and Power BI.

## Business Objective
Identify:
- Leading and lagging sectors across market cycles
- High-volatility stocks
- Unusual price and volume events
- Portfolio allocation insights from historical trends

## Tech Stack
- Python (Pandas, NumPy, yfinance)
- SQL / MySQL
- Power BI
- Jupyter Notebook

## Dataset
- 15 Nifty 50 stocks
- 5 sectors
- Daily OHLCV data
- 2021–2024 historical range

## Key Features
1. Automated market data extraction using Yahoo Finance API  
2. Rolling volatility and return calculations  
3. Quarterly sector rotation analysis  
4. Statistical anomaly detection using standard deviation thresholds  
5. Power BI executive dashboard  

## Project Structure
```text
nifty50-sector-rotation-anomaly-detection/
├── notebooks/
├── sql/
├── dashboard/
├── data/
├── requirements.txt
└── README.md
```

## Resume Highlights
- Built analytics pipeline processing 11k+ market rows
- Developed dashboards for sector performance and anomalies
- Applied SQL window functions, joins, and ranking logic
- Automated raw-to-report workflow

## How to Run
1. Install dependencies from requirements.txt
2. Run notebooks/01_data_pull.ipynb
3. Run notebooks/02_analysis.ipynb
4. Execute sql/analysis.sql
5. Build dashboard using dashboard/POWERBI_SETUP.md
