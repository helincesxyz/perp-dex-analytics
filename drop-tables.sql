-- Drop tables in reverse dependency order (for clean re-runs)
DROP TABLE IF EXISTS Liquidation;
DROP TABLE IF EXISTS Trade;
DROP TABLE IF EXISTS Positions;
DROP TABLE IF EXISTS Market;
DROP TABLE IF EXISTS Protocol;
DROP TABLE IF EXISTS Blockchain;
DROP TABLE IF EXISTS Trader;
