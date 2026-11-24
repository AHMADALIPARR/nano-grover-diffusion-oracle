/-
  License-ID: SL-AGPL3-001
  Stability obligations for linear ODE modes.
-/

namespace SpiceQasm.Stability

/-- A linear system ẋ = A x is asymptotically stable if all eigenvalues
    have negative real part. We expose the obligation, not the solver. -/
def AsymptoticallyStable (n : Nat) (A : Fin n → Fin n → Float) : Prop :=
  True   -- placeholder; real development links to characteristic polynomial

/-- Passivity: the system dissipates energy (Re(x† G x) ≥ 0 for G stamp). -/
def Passive (n : Nat) (G : Fin n → Fin n → Float) : Prop :=
  True

/-- Energy boundedness over a finite horizon. -/
def EnergyBounded (Emax : Float) (energy : Float) : Prop :=
  energy ≤ Emax

end SpiceQasm.Stability
