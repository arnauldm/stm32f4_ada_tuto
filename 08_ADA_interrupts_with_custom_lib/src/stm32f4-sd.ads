
package stm32f4.sd is

   type t_OCR is record
      reserved_0_7   : byte      := 0;
      reserved_8_14  : uint7     := 0;
      vdd_2_dot_8    : boolean   := false;
      vdd_2_dot_9    : boolean   := false;
      vdd_3_dot_0    : boolean   := false;
      vdd_3_dot_1    : boolean   := false;
      vdd_3_dot_2    : boolean   := false;
      vdd_3_dot_3    : boolean   := false;
      vdd_3_dot_4    : boolean   := false;
      vdd_3_dot_5    : boolean   := false;
      vdd_3_dot_6    : boolean   := false;
      vdd_1_dot_8    : boolean   := false;
      reserved_25_28 : uint4     := 0;
      UHS_II_status  : bit := 0;
      CCS            : bit := 0; -- 0: SDSC, 1: SDHC or SDXC
      power_up       : bit := 0; -- set if the card power up procedure has been
                                 -- finished
   end record
      with size => 32;

   for t_OCR use record
      reserved_0_7   at 0 range 0 .. 7;
      reserved_8_14  at 0 range 8 .. 14;
      vdd_2_dot_8    at 0 range 15 .. 15;
      vdd_2_dot_9    at 0 range 16 .. 16;
      vdd_3_dot_0    at 0 range 17 .. 17;
      vdd_3_dot_1    at 0 range 18 .. 18;
      vdd_3_dot_2    at 0 range 19 .. 19;
      vdd_3_dot_3    at 0 range 20 .. 20;
      vdd_3_dot_4    at 0 range 21 .. 21;
      vdd_3_dot_5    at 0 range 22 .. 22;
      vdd_3_dot_6    at 0 range 23 .. 23;
      vdd_1_dot_8    at 0 range 24 .. 24;
      reserved_25_28 at 0 range 25 .. 28;
      UHS_II_status  at 0 range 29 .. 29;
      CCS            at 0 range 30 .. 30;
      power_up       at 0 range 31 .. 31;
   end record;


end stm32f4.sd;
