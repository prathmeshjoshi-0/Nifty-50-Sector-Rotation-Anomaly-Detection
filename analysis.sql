-- ============================================================
-- Nifty 50 Sector Rotation & Anomaly Detection
-- SQL Analysis Queries
-- Author: Prathmesh Joshi
-- Database: MySQL
-- ============================================================

-- SETUP: Create database and table
-- ============================================================

CREATE DATABASE IF NOT EXISTS nifty_analysis;
USE nifty_analysis;

CREATE TABLE IF NOT EXISTS stock_data (
    Date            DATE,
    Open            FLOAT,
    High            FLOAT,
    Low             FLOAT,
    Close           FLOAT,
    Volume          BIGINT,
    Ticker          VARCHAR(20),
    Sector          VARCHAR(20),
    Daily_Return    FLOAT,
    Rolling_30D_Return FLOAT,
    Volatility_30D  FLOAT,
    Anomaly         BOOLEAN,
    Anomaly_Direction VARCHAR(20),
    Quarter         VARCHAR(10),
    Month           VARCHAR(10)
);

-- Load data via MySQL Workbench Table Import Wizard
-- File: data/nifty_processed.csv


-- ============================================================
-- QUERY 1: Monthly Return Ranking Within Each Sector
-- Shows which stock led its sector every month
-- Demonstrates: CTE + Window Functions (RANK)
-- ============================================================

WITH monthly_returns AS (
    SELECT
        Ticker,
        Sector,
        Month,
        SUM(Daily_Return) AS Monthly_Return
    FROM stock_data
    GROUP BY Ticker, Sector, Month
),
ranked AS (
    SELECT
        Ticker,
        Sector,
        Month,
        ROUND(Monthly_Return * 100, 2) AS Monthly_Return_Pct,
        RANK() OVER (
            PARTITION BY Sector, Month
            ORDER BY Monthly_Return DESC
        ) AS Sector_Rank
    FROM monthly_returns
)
SELECT *
FROM ranked
ORDER BY Month, Sector, Sector_Rank;


-- ============================================================
-- QUERY 2: Volume Anomaly Detection
-- Flags days where trading volume exceeded 2x the stock average
-- High volume often signals institutional activity or news events
-- Demonstrates: CTE + JOIN + calculated ratio
-- ============================================================

WITH avg_volume AS (
    SELECT
        Ticker,
        AVG(Volume) AS Avg_Volume
    FROM stock_data
    GROUP BY Ticker
)
SELECT
    s.Date,
    s.Ticker,
    s.Sector,
    s.Volume                                        AS Daily_Volume,
    ROUND(a.Avg_Volume, 0)                          AS Avg_Volume,
    ROUND(s.Volume / a.Avg_Volume, 2)               AS Volume_Ratio,
    ROUND(s.Daily_Return * 100, 2)                  AS Return_Pct
FROM stock_data s
JOIN avg_volume a ON s.Ticker = a.Ticker
WHERE s.Volume > 2 * a.Avg_Volume
ORDER BY Volume_Ratio DESC
LIMIT 50;


-- ============================================================
-- QUERY 3: Sector Rotation by Quarter
-- Which sector outperformed each quarter over 3 years?
-- Key insight for understanding market cycles
-- Demonstrates: CTE + Window Function (RANK) + aggregation
-- ============================================================

WITH quarterly_returns AS (
    SELECT
        Sector,
        Quarter,
        SUM(Daily_Return)               AS Total_Return,
        ROUND(SUM(Daily_Return)*100, 2) AS Return_Pct
    FROM stock_data
    GROUP BY Sector, Quarter
),
ranked AS (
    SELECT
        Sector,
        Quarter,
        Return_Pct,
        RANK() OVER (
            PARTITION BY Quarter
            ORDER BY Total_Return DESC
        ) AS Quarter_Rank
    FROM quarterly_returns
)
SELECT *
FROM ranked
ORDER BY Quarter, Quarter_Rank;


-- ============================================================
-- QUERY 4: Top Anomaly Events
-- Most extreme price moves across all stocks in 3 years
-- Demonstrates: filtering + ordering + absolute value
-- ============================================================

SELECT
    Date,
    Ticker,
    Sector,
    ROUND(Daily_Return * 100, 2)    AS Return_Pct,
    Volume,
    Anomaly_Direction
FROM stock_data
WHERE Anomaly = TRUE
ORDER BY ABS(Daily_Return) DESC
LIMIT 30;


-- ============================================================
-- QUERY 5: Year-over-Year Sector Performance Comparison
-- Compare each sector's annual return across 2021, 2022, 2023
-- Demonstrates: CASE WHEN pivot + GROUP BY + subquery
-- ============================================================

SELECT
    Sector,
    ROUND(SUM(CASE WHEN YEAR(Date) = 2021 THEN Daily_Return ELSE 0 END) * 100, 2) AS Return_2021_Pct,
    ROUND(SUM(CASE WHEN YEAR(Date) = 2022 THEN Daily_Return ELSE 0 END) * 100, 2) AS Return_2022_Pct,
    ROUND(SUM(CASE WHEN YEAR(Date) = 2023 THEN Daily_Return ELSE 0 END) * 100, 2) AS Return_2023_Pct
FROM stock_data
GROUP BY Sector
ORDER BY Return_2023_Pct DESC;


-- ============================================================
-- QUERY 6: Volatility Ranking with Sector Average
-- Ranks each stock by risk and compares to its sector average
-- Demonstrates: Window Function (AVG OVER PARTITION)
-- ============================================================

WITH stock_vol AS (
    SELECT
        Ticker,
        Sector,
        AVG(Volatility_30D) AS Avg_Volatility
    FROM stock_data
    WHERE Volatility_30D IS NOT NULL
    GROUP BY Ticker, Sector
)
SELECT
    Ticker,
    Sector,
    ROUND(Avg_Volatility * 100, 4)  AS Avg_Volatility_Pct,
    ROUND(AVG(Avg_Volatility * 100) OVER (
        PARTITION BY Sector
    ), 4)                            AS Sector_Avg_Volatility_Pct,
    RANK() OVER (
        ORDER BY Avg_Volatility DESC
    )                                AS Overall_Risk_Rank
FROM stock_vol
ORDER BY Overall_Risk_Rank;
