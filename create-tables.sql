-- ===========================================================
-- Decentralized Perpetual Exchange Analytics Platform
-- SQL CREATE TABLE Statements
-- ============================================================

-- ------------------------------------------------------------
-- 1. Trader
--    No foreign keys. TraderID is the primary key.
--    NOTE: total_pnl is a derived attribute (SUM of Trade.pnl_usd)
--          and is not stored. total_volume_usd is also derived
--          (SUM of Trade.size_usd) and is not stored.
-- ------------------------------------------------------------
CREATE TABLE Trader (
    TraderID          INT             NOT NULL,
    wallet_address    VARCHAR(100)    NOT NULL,
    joined_date       DATE            NOT NULL,
    PRIMARY KEY (TraderID)
);

-- ------------------------------------------------------------
-- 2. Blockchain
--    No foreign keys. BlockchainID is the primary key.
-- ------------------------------------------------------------
CREATE TABLE Blockchain (
    BlockchainID    INT             NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    avg_gas_fee     DECIMAL(20, 2)  NOT NULL,
    node_count      INT             NOT NULL,
    finality_time   DECIMAL(10, 3)  NOT NULL,  -- average seconds to finality
    PRIMARY KEY (BlockchainID)
);

-- ------------------------------------------------------------
-- 3. Protocol
--    Runs on exactly one Blockchain (total participation → NOT NULL FK).
--    NOTE: total_volume_usd, total_fees_usd, open_interest_usd are
--          derived attributes and are not stored as columns.
-- ------------------------------------------------------------
CREATE TABLE Protocol (
    ProtocolID      INT     NOT NULL,
    launch_date     DATE    NOT NULL,
    BlockchainID    INT     NOT NULL,   -- FK, NOT NULL: total participation
    PRIMARY KEY (ProtocolID),
    FOREIGN KEY (BlockchainID) REFERENCES Blockchain(BlockchainID)
);

-- ------------------------------------------------------------
-- 4. Market
--    Hosted by exactly one Protocol (total participation → NOT NULL FK).
-- ------------------------------------------------------------
CREATE TABLE Market (
    MarketID        INT             NOT NULL,
    base_asset      VARCHAR(20)     NOT NULL,
    quote_asset     VARCHAR(20)     NOT NULL,
    max_leverage    DECIMAL(5, 2)   NOT NULL,
    ProtocolID      INT             NOT NULL,   -- FK, NOT NULL: total participation
    PRIMARY KEY (MarketID),
    FOREIGN KEY (ProtocolID) REFERENCES Protocol(ProtocolID)
);

-- ------------------------------------------------------------
-- 5. Positions
--    Listed on exactly one Market  (total → NOT NULL FK).
--    Opened by exactly one Trader  (total → NOT NULL FK).
--    NOTE: Renamed to Positions to avoid conflict with reserved
--          word Position in some SQL dialects.
-- ------------------------------------------------------------
CREATE TABLE Positions (
    PositionID      INT             NOT NULL,
    direction       VARCHAR(5)      NOT NULL CHECK (direction IN ('LONG', 'SHORT')),
    size_usd        DECIMAL(20, 2)  NOT NULL,
    leverage        DECIMAL(5, 2)   NOT NULL,
    open_price      DECIMAL(20, 8)  NOT NULL,   -- high precision for crypto prices
    pos_status      VARCHAR(6)      NOT NULL CHECK (pos_status IN ('OPEN', 'CLOSED')),
    TraderID        INT             NOT NULL,   -- FK, NOT NULL: total participation
    MarketID        INT             NOT NULL,   -- FK, NOT NULL: total participation
    PRIMARY KEY (PositionID),
    FOREIGN KEY (TraderID)  REFERENCES Trader(TraderID),
    FOREIGN KEY (MarketID)  REFERENCES Market(MarketID)
);

-- ------------------------------------------------------------
-- 6. Trade
--    Executed by exactly one Trader   (total → NOT NULL FK).
--    Part of exactly one Position     (total → NOT NULL FK).
--    NOTE: 'timestamp' and 'type' are reserved words in SQL;
--          renamed to trade_timestamp and trade_type.
--          pnl_usd is NULL for OPEN trades (no realized PnL yet).
-- ------------------------------------------------------------
CREATE TABLE Trade (
    TradeID           INT             NOT NULL,
    trade_timestamp   DATETIME        NOT NULL,
    trade_type        VARCHAR(15)     NOT NULL CHECK (trade_type IN ('OPEN', 'CLOSE', 'PARTIAL_CLOSE')),
    fee_usd           DECIMAL(20, 2)  NOT NULL,
    pnl_usd           DECIMAL(20, 2),            -- NULL allowed: no PnL on OPEN trades
    TraderID          INT             NOT NULL,   -- FK, NOT NULL: total participation
    PositionID        INT             NOT NULL,   -- FK, NOT NULL: total participation
    PRIMARY KEY (TradeID),
    FOREIGN KEY (TraderID)    REFERENCES Trader(TraderID),
    FOREIGN KEY (PositionID)  REFERENCES Positions(PositionID)
);

-- ------------------------------------------------------------
-- 7. Liquidation
--    Triggered by exactly one Position (total → NOT NULL FK).
--    1:1 with Positions — enforced by UNIQUE on PositionID.
--    NOTE: trade_timestamp renamed to liq_timestamp for clarity.
-- ------------------------------------------------------------
CREATE TABLE Liquidation (
    LiquidationID         INT             NOT NULL,
    liq_timestamp         DATETIME        NOT NULL,
    trigger_price         DECIMAL(20, 8)  NOT NULL,   -- high precision for crypto prices
    collateral_lost_usd   DECIMAL(20, 2)  NOT NULL,
    liquidation_fee_usd   DECIMAL(20, 2)  NOT NULL,
    PositionID            INT             NOT NULL UNIQUE,  -- FK + UNIQUE enforces 1:1
    PRIMARY KEY (LiquidationID),
    FOREIGN KEY (PositionID) REFERENCES Positions(PositionID)
);

-- ============================================================
-- End of schema
-- ============================================================
