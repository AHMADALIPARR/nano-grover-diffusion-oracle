-- License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
-- Existing file, component and third-party notices and grants are preserved.

-- =====================================================================
-- nano_grover_contracts.ads
-- SPARK contracts for Nano-Grover / braid trigonometric domain.
-- Formal inversion target: continuous-time DAEs in Verilog-A.
-- =====================================================================

pragma SPARK_Mode (On);

package Nano_Grover_Contracts
  with SPARK_Mode => On
is

   -- -----------------------------------------------------------------
   -- Bounded integer range  (maps to Voltage Rails 0V .. V_dd)
   -- -----------------------------------------------------------------
   subtype Amplitude_Index is Integer range 0 .. 3;  -- N=4 computational basis
   subtype Chord_Select    is Integer range 0 .. 2;  -- Root / Third / Fifth

   subtype Voltage_Rail is Float range 0.0 .. 1.8;
   -- SPARK Bound <-> Supply clamping / saturation limits

   -- -----------------------------------------------------------------
   -- State vector (discrete image of node voltages)
   -- -----------------------------------------------------------------
   type Amplitude_Vector is array (Amplitude_Index) of Float;

   -- State invariant: squared norm conserved up to O(eps^2)
   function Norm_Sq (V : Amplitude_Vector) return Float
     with
       Global => null,
       Post   => Norm_Sq'Result >= 0.0;

   -- -----------------------------------------------------------------
   -- Pre / Post contracts for one Grover iteration
   -- {Pre(S)} Cmd {Post(S, S')}
   -- -----------------------------------------------------------------

   procedure Grover_Oracle_Flip
     (V      : in out Amplitude_Vector;
      Target : in     Amplitude_Index)
   with
     Global  => null,
     Depends => (V => (V, Target)),
     Pre     => (for all I in Amplitude_Index =>
                   V(I) in Voltage_Rail),
     Post    => (for all I in Amplitude_Index =>
                   (if I = Target then V(I) = -V'Old(I)
                    else V(I) = V'Old(I)))
                and then
                (for all I in Amplitude_Index =>
                   V(I) in Voltage_Rail);

   procedure Grover_Diffusion
     (V : in out Amplitude_Vector)
   with
     Global  => null,
     Depends => (V => V),
     Pre     => (for all I in Amplitude_Index =>
                   V(I) in Voltage_Rail),
     Post    => (for all I in Amplitude_Index =>
                   V(I) in Voltage_Rail);
     -- Post-condition maps to steady-state nodal balance (dV/dt = 0)
     -- after the mean-reflection Poincaré section.

   -- -----------------------------------------------------------------
   -- Matrix multiplier contract  (ρ(σ_k) braid generator)
   -- Maps to VCVS / Gilbert cell / Translinear loop
   -- -----------------------------------------------------------------

   procedure Braid_Matrix_Multiply
     (Theta : in     Float;
      Sin_O :    out Float;
      Cos_O :    out Float)
   with
     Global  => null,
     Depends => (Sin_O => Theta, Cos_O => Theta),
     Pre     => Theta in -3.14159265359 .. 3.14159265359,
     Post    => Sin_O in Voltage_Rail and then Cos_O in Voltage_Rail;

   -- -----------------------------------------------------------------
   -- Hash / integrity mixing  (FNV-1a style non-linear stage)
   -- Maps to cross-coupled mixer with exponential response
   -- -----------------------------------------------------------------

   function Mix_Integrity (A, B : Float) return Float
     with
       Global => null,
       Pre    => A in Voltage_Rail and then B in Voltage_Rail,
       Post   => Mix_Integrity'Result in Voltage_Rail;

   -- -----------------------------------------------------------------
   -- Semiconductor / thermal bounds (ghost constants for contracts)
   -- -----------------------------------------------------------------

   Thermal_Voltage_mV : constant Float := 25.85;  -- V_T = kT/q at 300 K
   Max_Transit_Freq   : constant Float := 1.0e11; -- illustrative f_T bound

end Nano_Grover_Contracts;
