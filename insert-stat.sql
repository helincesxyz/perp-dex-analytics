-- ============================================================
-- CS306 Spring 2025-2026 — Project Phase 3
-- Decentralized Perpetual Exchange Analytics Platform

-- ============================================================
-- INSERT Statements
-- ============================================================
-- PART 1: POPULATE THE DATABASE
-- ============================================================

-- ------------------------------------------------------------
-- Blockchain (5 rows)
-- ------------------------------------------------------------
INSERT INTO Blockchain (BlockchainID, name, avg_gas_fee, node_count, finality_time) VALUES
(1, 'Hyperliquid L1', 0.00, 4,    0.200),
(2, 'Arbitrum',       0.05, 1200, 0.300),
(3, 'Solana',         0.00, 2000, 0.400),
(4, 'BNB Chain',      0.03, 1800, 0.750),
(5, 'Base',           0.04, 950,  0.350);

-- ------------------------------------------------------------
-- Protocol (5 rows)
-- ------------------------------------------------------------
INSERT INTO Protocol (ProtocolID, launch_date, BlockchainID) VALUES
(1, '2023-11-01', 1),  -- Hyperliquid on its own L1
(2, '2024-03-15', 2),  -- Lighter on Arbitrum (zk-rollup)
(3, '2021-12-01', 2),  -- GMX on Arbitrum
(4, '2024-06-01', 4),  -- Aster on BNB Chain
(5, '2024-09-10', 5);  -- EdgeX on Base

-- ------------------------------------------------------------
-- Market (5 rows)
-- Leverage limits verified against DefiLlama/Hyperliquid docs:
-- HL reduced BTC from 50x to 40x, ETH from 50x to 25x in 2025
-- HYPE perp launched after HYPE token launch (Nov 2024)
-- ------------------------------------------------------------
INSERT INTO Market (MarketID, base_asset, quote_asset, max_leverage, ProtocolID) VALUES
(1, 'BTC',  'USD',  40.00, 1),  -- Hyperliquid BTC (40x post-exploit)
(2, 'ETH',  'USD',  25.00, 1),  -- Hyperliquid ETH (25x post-exploit)
(3, 'SOL',  'USD',  20.00, 1),  -- Hyperliquid SOL
(4, 'HYPE', 'USD',  10.00, 1),  -- Hyperliquid HYPE (launched Nov 2024)
(5, 'BTC',  'USD',  50.00, 2);  -- Lighter BTC

-- ------------------------------------------------------------
-- Trader (6 rows — all joined 2023 or later)
-- ------------------------------------------------------------
INSERT INTO Trader (TraderID, wallet_address, joined_date) VALUES
(1, '0xA1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2', '2023-11-10'),
(2, '0xB2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3', '2023-11-25'),
(3, '0xC3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4', '2024-01-08'),
(4, '0xD4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5', '2024-02-14'),
(5, '0xE5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6', '2024-06-01'),
(6, '0xF6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1', '2025-01-15');

-- ------------------------------------------------------------
-- Positions (8 rows)
-- Note: HYPE market (MarketID=4) positions must be after Nov 2024
-- ------------------------------------------------------------
INSERT INTO Positions (PositionID, direction, size_usd, leverage, open_price, pos_status, TraderID, MarketID) VALUES
(1,  'LONG',  50000.00, 10.00, 42000.00, 'CLOSED', 1, 1),  -- BTC on HL
(2,  'SHORT', 20000.00,  5.00,  2800.00, 'CLOSED', 1, 2),  -- ETH on HL
(3,  'LONG',  75000.00, 20.00, 45000.00, 'OPEN',   2, 1),  -- BTC on HL
(4,  'LONG',  15000.00,  3.00,   120.00, 'OPEN',   2, 3),  -- SOL on HL
(5,  'SHORT', 30000.00, 10.00,  2900.00, 'CLOSED', 3, 2),  -- ETH on HL
(6,  'LONG',  10000.00,  2.00,    12.50, 'OPEN',   4, 4),  -- HYPE on HL (post Nov 2024)
(7,  'LONG',  90000.00, 25.00, 43000.00, 'OPEN',   5, 5),  -- BTC on Lighter
(8,  'SHORT', 12000.00,  5.00,  2750.00, 'CLOSED', 6, 2);  -- ETH on HL

-- ------------------------------------------------------------
-- Trade (10 rows)
-- Note: Trades on HYPE (PositionID=6) must be after Nov 2024
-- ------------------------------------------------------------
INSERT INTO Trade (TradeID, trade_timestamp, trade_type, fee_usd, pnl_usd, TraderID, PositionID) VALUES
(1,  '2023-11-12 10:00:00', 'OPEN',           50.00,    NULL,    1, 1),
(2,  '2024-01-15 14:30:00', 'CLOSE',         500.00,  8000.00,  1, 1),
(3,  '2023-12-01 09:00:00', 'OPEN',           20.00,    NULL,    1, 2),
(4,  '2024-02-10 16:00:00', 'CLOSE',         200.00, -3000.00,  1, 2),
(5,  '2023-12-05 11:00:00', 'OPEN',           75.00,    NULL,    2, 3),
(6,  '2024-03-12 13:00:00', 'PARTIAL_CLOSE', 150.00,  2500.00,  2, 3),
(7,  '2024-01-10 08:00:00', 'OPEN',           15.00,    NULL,    2, 4),
(8,  '2024-02-20 17:00:00', 'CLOSE',         300.00, -5000.00,  3, 5),
(9,  '2024-06-05 10:00:00', 'OPEN',           90.00,    NULL,    5, 7),
(10, '2024-12-01 12:00:00', 'OPEN',           10.00,    NULL,    4, 6);  -- HYPE trade post-launch

-- ------------------------------------------------------------
-- Liquidation (5 rows)
-- ------------------------------------------------------------
INSERT INTO Liquidation (LiquidationID, liq_timestamp, trigger_price, collateral_lost_usd, liquidation_fee_usd, PositionID) VALUES
(1, '2024-02-11 10:00:00',  2600.00, 18000.00, 180.00, 2),
(2, '2024-02-21 09:30:00',  3100.00, 28000.00, 280.00, 5),
(3, '2024-01-16 15:00:00', 38000.00,  5000.00,  50.00, 1),
(4, '2024-02-10 08:30:00',    95.00,  3000.00,  30.00, 4),
(5, '2025-01-21 13:00:00',  2600.00, 11000.00, 110.00, 8);