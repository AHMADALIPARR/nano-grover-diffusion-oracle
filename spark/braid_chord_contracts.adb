-- License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
-- Existing file, component and third-party notices and grants are preserved.

pragma SPARK_Mode (On);

package body Braid_Chord_Contracts
  with SPARK_Mode => On
is

   procedure Chord_Lookup
     (Sel   : in     Chord_Id;
      Freq  :    out Freq_Word;
      Valid :    out Boolean)
   is
   begin
      case Sel is
         when 0 =>
            Freq  := Root_Freq;
            Valid := True;
         when 1 =>
            Freq  := Third_Freq;
            Valid := True;
         when 2 =>
            Freq  := Fifth_Freq;
            Valid := True;
      end case;
   end Chord_Lookup;

end Braid_Chord_Contracts;
