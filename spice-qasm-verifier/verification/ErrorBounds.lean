/-
  License-ID: SL-AGPL3-001
  Explicit error sources: discretization, measurement, conditioning.
-/

namespace SpiceQasm.ErrorBounds

/-- Backward-Euler local truncation error O(dt²). -/
def beTruncation (dt : Float) : Float := dt * dt

/-- Measurement statistical error (Hoeffding-style placeholder). -/
def measurementError (shots : Nat) (delta : Float) : Float :=
  -- √(ln(2/δ)/(2n)) shape; concrete constants omitted
  1.0 / Float.ofNat shots

/-- Total verification ε budget. -/
def totalEps (dt : Float) (shots : Nat) (delta : Float) (cond : Float) : Float :=
  beTruncation dt + measurementError shots delta + cond

end SpiceQasm.ErrorBounds
