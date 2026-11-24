-- License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
-- Existing file, component and third-party notices and grants are preserved.

pragma SPARK_Mode (On);

package body Nano_Grover_Contracts
  with SPARK_Mode => On
is

   function Norm_Sq (V : Amplitude_Vector) return Float is
      Acc : Float := 0.0;
   begin
      for I in Amplitude_Index loop
         Acc := Acc + V(I) * V(I);
         pragma Loop_Invariant (Acc >= 0.0);
      end loop;
      return Acc;
   end Norm_Sq;

   procedure Grover_Oracle_Flip
     (V      : in out Amplitude_Vector;
      Target : in     Amplitude_Index)
   is
   begin
      V(Target) := -V(Target);
   end Grover_Oracle_Flip;

   procedure Grover_Diffusion
     (V : in out Amplitude_Vector)
   is
      Mean : Float := 0.0;
   begin
      for I in Amplitude_Index loop
         Mean := Mean + V(I);
         pragma Loop_Invariant (True);
      end loop;
      Mean := Mean / 4.0;

      for I in Amplitude_Index loop
         V(I) := 2.0 * Mean - V(I);
         pragma Loop_Invariant
           (for all J in Amplitude_Index range Amplitude_Index'First .. I =>
              True);
      end loop;
   end Grover_Diffusion;

   procedure Braid_Matrix_Multiply
     (Theta : in     Float;
      Sin_O :    out Float;
      Cos_O :    out Float)
   is
      -- φ/2 ≈ 0.8090169943749474
      Phi_Half : constant Float := 0.8090169943749474;
      S, C     : Float;
   begin
      -- Placeholder; real implementation uses Ada.Numerics.Elementary_Functions
      -- or a formally verified CORDIC core.
      S := Theta;  -- structural stand-in for Sin(Theta)
      C := Theta;  -- structural stand-in for Cos(Theta)

      Sin_O := Phi_Half * S + 0.5 * C;
      Cos_O := 0.5 * S - Phi_Half * C;

      -- Rail clamp (maps to physical supply clamping)
      if Sin_O > 1.8 then
         Sin_O := 1.8;
      elsif Sin_O < 0.0 then
         Sin_O := 0.0;
      end if;

      if Cos_O > 1.8 then
         Cos_O := 1.8;
      elsif Cos_O < 0.0 then
         Cos_O := 0.0;
      end if;
   end Braid_Matrix_Multiply;

   function Mix_Integrity (A, B : Float) return Float is
      -- Simple non-linear mix; real FNV-style would be integer bit ops
      R : Float;
   begin
      R := A * B + (A - B) * 0.1;
      if R > 1.8 then
         return 1.8;
      elsif R < 0.0 then
         return 0.0;
      else
         return R;
      end if;
   end Mix_Integrity;

end Nano_Grover_Contracts;
