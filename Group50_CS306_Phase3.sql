-- ============================================================
-- CS306 Spring 2025-2026 — Project Phase 3
-- Decentralized Perpetual Exchange Analytics Platform
-- ============================================================
-- SQL Queries
-- ============================================================
-- PART 2: SQL QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Query 1 (Category A)
-- Description: Show wallet address and joined date of traders
--              who joined after January 1, 2023.
-- ------------------------------------------------------------
SELECT wallet_address, joined_date
FROM Trader
WHERE joined_date > '2023-01-01';

-- ------------------------------------------------------------
-- Query 2 (Category A)
-- Description: Retrieve all currently open positions.
-- ------------------------------------------------------------
SELECT *
FROM Positions
WHERE pos_status = 'OPEN';

-- ------------------------------------------------------------
-- Query 3 (Category B)
-- Description: List all positions that were liquidated,
--              showing position ID, direction, size, and
--              the collateral lost in the liquidation.
-- ------------------------------------------------------------
SELECT P.PositionID, P.direction, P.size_usd, L.collateral_lost_usd, L.liq_timestamp
FROM Positions P
JOIN Liquidation L ON P.PositionID = L.PositionID;

-- ------------------------------------------------------------
-- Query 4 (Category B)
-- Description: Show total trading volume per protocol by
--              joining Protocol, Market, and Trade tables.
-- ------------------------------------------------------------
SELECT PR.ProtocolID, SUM(T.size_usd) AS total_volume_usd
FROM Protocol PR
JOIN Market M   ON PR.ProtocolID = M.ProtocolID
JOIN Positions P ON M.MarketID   = P.MarketID
JOIN Trade T    ON P.PositionID  = T.PositionID
GROUP BY PR.ProtocolID
ORDER BY total_volume_usd DESC;

-- ------------------------------------------------------------
-- Query 5 (Category C)
-- Description: Find the traders with the highest total
--              realized PnL across all their trades.
-- ------------------------------------------------------------
SELECT T.TraderID, T.wallet_address, SUM(TR.pnl_usd) AS total_pnl
FROM Trader T
JOIN Trade TR ON T.TraderID = TR.TraderID
WHERE TR.pnl_usd IS NOT NULL
GROUP BY T.TraderID, T.wallet_address
ORDER BY total_pnl DESC;

-- ------------------------------------------------------------
-- Query 6 (Category C)
-- Description: Find the total fee revenue collected
--              across all trades.
-- ------------------------------------------------------------
SELECT SUM(fee_usd) AS total_fee_revenue
FROM Trade;

-- ------------------------------------------------------------
-- Query 7 (Category C)
-- Description: Find the largest open position by size in USD.
-- ------------------------------------------------------------
SELECT MAX(size_usd) AS largest_position_usd
FROM Positions
WHERE pos_status = 'OPEN';

-- ------------------------------------------------------------
-- Query 8 (Category D)
-- Description: List blockchains ordered by average gas fee
--              from lowest to highest.
-- ------------------------------------------------------------
SELECT name, avg_gas_fee
FROM Blockchain
ORDER BY avg_gas_fee ASC;

-- ------------------------------------------------------------
-- Query 9 (Category D)
-- Description: List liquidations ordered by collateral lost
--              from highest to lowest.
-- ------------------------------------------------------------
SELECT L.LiquidationID, P.direction, P.size_usd,
       L.collateral_lost_usd, L.trigger_price
FROM Liquidation L
JOIN Positions P ON L.PositionID = P.PositionID
ORDER BY L.collateral_lost_usd DESC;

-- ------------------------------------------------------------
-- Query 10 (Category E)
-- Description: Find which market has the most positions
--              listed on it.
-- ------------------------------------------------------------
SELECT M.MarketID, M.base_asset, M.quote_asset,
       COUNT(P.PositionID) AS position_count
FROM Market M
JOIN Positions P ON M.MarketID = P.MarketID
GROUP BY M.MarketID, M.base_asset, M.quote_asset
ORDER BY position_count DESC;

-- ------------------------------------------------------------
-- Query 11 (Category E)
-- Description: Find which market generates the most fee
--              revenue from trades.
-- ------------------------------------------------------------
SELECT M.MarketID, M.base_asset, M.quote_asset,
       SUM(T.fee_usd) AS total_fees
FROM Market M
JOIN Positions P ON M.MarketID  = P.MarketID
JOIN Trade T     ON P.PositionID = T.PositionID
GROUP BY M.MarketID, M.base_asset, M.quote_asset
ORDER BY total_fees DESC;

-- ------------------------------------------------------------
-- Query 12 (Category E)
-- Description: Find all positions with a size larger than
--              the average position size (subquery).
-- ------------------------------------------------------------
SELECT PositionID, direction, size_usd, leverage, pos_status
FROM Positions
WHERE size_usd > (
    SELECT AVG(size_usd)
    FROM Positions
);

-- ------------------------------------------------------------
-- Query 13 (Category C — COUNT)
-- Description: Count the total number of trades per trader.
-- ------------------------------------------------------------
SELECT TraderID, COUNT(TradeID) AS trade_count
FROM Trade
GROUP BY TraderID
ORDER BY trade_count DESC;

-- ------------------------------------------------------------
-- Query 14 (Category C — AVG)
-- Description: Find the average leverage used across
--              all open positions.
-- ------------------------------------------------------------
SELECT AVG(leverage) AS avg_leverage
FROM Positions
WHERE pos_status = 'OPEN';

-- ------------------------------------------------------------
-- Query 15 (Category C — MIN)
-- Description: Find the smallest position size ever opened
--              per market.
-- ------------------------------------------------------------
SELECT MarketID, MIN(size_usd) AS min_position_size
FROM Positions
GROUP BY MarketID
ORDER BY MarketID;

-- ------------------------------------------------------------
-- Query 16 (Category C — HAVING)
-- Description: Find traders who have spent more than
--              $200 total in fees.
-- ------------------------------------------------------------
SELECT TraderID, SUM(fee_usd) AS total_fees_paid
FROM Trade
GROUP BY TraderID
HAVING SUM(fee_usd) > 200
ORDER BY total_fees_paid DESC;

-- ------------------------------------------------------------
-- Query 17 (Category E — IN)
-- Description: List all trades that belong to currently
--              open positions.
-- ------------------------------------------------------------
SELECT TradeID, trade_timestamp, trade_type, fee_usd, pnl_usd
FROM Trade
WHERE PositionID IN (
    SELECT PositionID
    FROM Positions
    WHERE pos_status = 'OPEN'
);

-- ------------------------------------------------------------
-- Query 18 (Category E — EXISTS)
-- Description: List all traders who have at least one
--              liquidated position.
-- ------------------------------------------------------------
SELECT TraderID, wallet_address
FROM Trader T
WHERE EXISTS (
    SELECT 1
    FROM Positions P
    JOIN Liquidation L ON P.PositionID = L.PositionID
    WHERE P.TraderID = T.TraderID
);

-- ============================================================
-- End of Phase 3
-- ============================================================
