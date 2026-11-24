-- License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
-- Existing file, component and third-party notices and grants are preserved.

pragma SPARK_Mode (On);

with Nano_Grover_Contracts;

package Braid_Chord_Contracts
  with SPARK_Mode => On
is

   subtype Chord_Id is Nano_Grover_Contracts.Chord_Select;

   -- IEEE-754 bit patterns as opaque words (source-of-truth from flop ROM)
   type Freq_Word is mod 2**32;

   Root_Freq  : constant Freq_Word := 16#43480000#; -- ~200 Hz
   Third_Freq : constant Freq_Word := 16#438C0000#; -- ~280 Hz
   Fifth_Freq : constant Freq_Word := 16#43AF8000#; -- ~351 Hz

   procedure Chord_Lookup
     (Sel   : in     Chord_Id;
      Freq  :    out Freq_Word;
      Valid :    out Boolean)
   with
     Global  => null,
     Depends => (Freq => Sel, Valid => Sel),
     Post    => (if Sel = 0 then Freq = Root_Freq  and then Valid
                 elsif Sel = 1 then Freq = Third_Freq and then Valid
                 elsif Sel = 2 then Freq = Fifth_Freq and then Valid
                 else not Valid);

end Braid_Chord_Contracts;
