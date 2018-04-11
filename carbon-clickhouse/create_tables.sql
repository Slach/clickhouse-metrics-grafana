CREATE DATABASE IF NOT EXISTS carbon_clickhouse;
CREATE TABLE IF NOT EXISTS carbon_clickhouse.graphite (
  Path String,
  Value Float64,
  Time UInt32,
  Date Date,
  Timestamp UInt32
) ENGINE = GraphiteMergeTree(Date, (Path, Time), 8192, 'graphite_rollup');

-- optional table for faster metric search
CREATE TABLE IF NOT EXISTS carbon_clickhouse.graphite_tree (
  Date Date,
  Level UInt32,
  Path String,
  Deleted UInt8,
  Version UInt32
) ENGINE = ReplacingMergeTree(Date, (Level, Path), 8192, Version);

CREATE TABLE IF NOT EXISTS carbon_clickhouse.graphite_series (
   Date Date,
   Level UInt32,
   Path String,
   Deleted UInt8,
   Version UInt32
) ENGINE = ReplacingMergeTree(Date, (Level, Path, Date), 8192, Version);


CREATE TABLE IF NOT EXISTS carbon_clickhouse.graphite_tagged (
   Date Date,
   Tag1 String,
   Path String,
   Tags Array(String),
   Version UInt32,
   Deleted UInt8
) ENGINE = ReplacingMergeTree(Date, (Tag1, Path, Date), 8192, Version);
