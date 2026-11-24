/-
  License-ID: SL-AGPL3-001
  Linear device stamps (resistor, capacitor, inductor).
-/

namespace SpiceQasm.DeviceModels

structure Resistor where
  r : Float
  hr : r > 0

def conductance (R : Resistor) : Float := 1.0 / R.r

structure Capacitor where
  c : Float
  hc : c > 0

structure Inductor where
  l : Float
  hl : l > 0

/-- Ohm's law residual: V - I·R. -/
def ohmResidual (v i r : Float) : Float := v - i * r

/-- Capacitor constitutive: I - C·dV/dt residual (discrete). -/
def capResidual (i c dvdt : Float) : Float := i - c * dvdt

end SpiceQasm.DeviceModels
