/-
  License-ID: SL-AGPL3-001
  Kirchhoff laws as Lean 4 propositions (zero-dependency core).
-/

namespace SpiceQasm.Kirchhoff

/-- Current conservation at a node: sum of branch currents = 0. -/
def KCL (currents : List Float) : Prop :=
  currents.foldl (· + ·) 0.0 = 0.0

/-- Voltage conservation around a loop: sum of branch voltages = 0. -/
def KVL (voltages : List Float) : Prop :=
  voltages.foldl (· + ·) 0.0 = 0.0

/-- Residual form used by numerical backends. -/
def kclResidual (currents : List Float) : Float :=
  currents.foldl (· + ·) 0.0

theorem kcl_zero_of_empty : KCL [] := by
  simp [KCL]

end SpiceQasm.Kirchhoff
