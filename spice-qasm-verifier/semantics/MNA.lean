/-
  License-ID: SL-AGPL3-001
  Modified Nodal Analysis skeleton.
  Linear form: C ẋ + G x = b(t)
-/

namespace SpiceQasm.MNA

/-- Dense matrix of floats (row-major list of lists). -/
def Matrix (n : Nat) := Fin n → Fin n → Float
def Vector (n : Nat) := Fin n → Float

/-- Zero matrix. -/
def zeroMatrix (n : Nat) : Matrix n := fun _ _ => 0.0
def zeroVector (n : Nat) : Vector n := fun _ => 0.0

/-- Stamp a conductance between nodes i and j into G. -/
def stampConductance (n : Nat) (G : Matrix n) (i j : Fin n) (g : Float) : Matrix n :=
  fun a b =>
    let v := G a b
    if a = i ∧ b = i then v + g
    else if a = j ∧ b = j then v + g
    else if a = i ∧ b = j then v - g
    else if a = j ∧ b = i then v - g
    else v

/-- Stamp a capacitance into the C matrix (same pattern). -/
def stampCapacitance (n : Nat) (C : Matrix n) (i j : Fin n) (c : Float) : Matrix n :=
  stampConductance n C i j c

/-- Linear DAE residual: C ẋ + G x - b. -/
def residual (n : Nat) (C G : Matrix n) (x xdot b : Vector n) : Vector n :=
  fun i =>
    let cx := (List.range n).foldl (fun acc j =>
      acc + C i ⟨j, by sorry⟩ * xdot ⟨j, by sorry⟩) 0.0
    let gx := (List.range n).foldl (fun acc j =>
      acc + G i ⟨j, by sorry⟩ * x ⟨j, by sorry⟩) 0.0
    cx + gx - b i

/-- Backward-Euler discrete system: (G + C/Δt) x_{k+1} = b + (C/Δt) x_k -/
def backwardEulerMatrix (n : Nat) (G C : Matrix n) (dt : Float) : Matrix n :=
  fun i j => G i j + C i j / dt

end SpiceQasm.MNA
