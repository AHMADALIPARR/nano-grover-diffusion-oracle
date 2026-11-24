-- License-ID: SL-AGPL3-001
-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Minimal SPICE netlist parser skeleton (Haskell).
-- Produces an abstract netlist AST for MNA stamping.

module SpiceNetlist
  ( Element(..)
  , Netlist(..)
  , parseNetlist
  ) where

import Data.Char (isSpace)
import Data.List (foldl')

data Element
  = Resistor   { name :: String, n1 :: String, n2 :: String, value :: Double }
  | Capacitor  { name :: String, n1 :: String, n2 :: String, value :: Double }
  | Inductor   { name :: String, n1 :: String, n2 :: String, value :: Double }
  | VSource    { name :: String, n1 :: String, n2 :: String, dc :: Double }
  | MOSFET     { name :: String, nd :: String, ng :: String, ns :: String, nb :: String, model :: String }
  deriving (Show, Eq)

data Netlist = Netlist
  { elements :: [Element]
  , analysis :: [String]   -- raw .tran / .ac lines
  } deriving (Show, Eq)

-- Extremely small line-oriented parser (no full SPICE grammar).
parseLine :: String -> Maybe Element
parseLine raw =
  let ws = words (takeWhile (/= '*') raw)  -- strip comments
  in case ws of
       (n:a:b:v:_) | head n == 'R' || head n == 'r' ->
         Just $ Resistor n a b (read v)
       (n:a:b:v:_) | head n == 'C' || head n == 'c' ->
         Just $ Capacitor n a b (parseCap v)
       (n:a:b:v:_) | head n == 'L' || head n == 'l' ->
         Just $ Inductor n a b (parseInd v)
       (n:a:b:_:v:_) | (head n == 'V' || head n == 'v') && (ws !! 3 == "DC" || ws !! 3 == "dc") ->
         Just $ VSource n a b (read v)
       _ -> Nothing
  where
    parseCap s | last s == 'u' || last s == 'U' = read (init s) * 1e-6
               | last s == 'n' || last s == 'N' = read (init s) * 1e-9
               | last s == 'p' || last s == 'P' = read (init s) * 1e-12
               | otherwise = read s
    parseInd s | last s == 'm' || last s == 'M' = read (init s) * 1e-3
               | last s == 'u' || last s == 'U' = read (init s) * 1e-6
               | otherwise = read s

parseNetlist :: String -> Netlist
parseNetlist src =
  let ls = filter (not . null) . map (dropWhile isSpace) $ lines src
      es = [ e | l <- ls, Just e <- [parseLine l] ]
      an = [ l | l <- ls, head l == '.' ]
  in Netlist es an
