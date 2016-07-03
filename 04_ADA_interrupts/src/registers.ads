with Interfaces.Bit_Types;
with System;

package registers is

   type Bits_32x1 is array (0 .. 31) of Interfaces.Bit_Types.Bit
      with Pack, Size => 32;

   type EXTI_Register is record
      IMR   : Bits_32x1;
      EMR   : Bits_32x1;
      RTSR  : Bits_32x1;
      FTSR  : Bits_32x1;
      SWIER : Bits_32x1;
      PR    : Bits_32x1;
   end record;

   for EXTI_Register use record
      IMR   at 0  range 0 .. 31;
      EMR   at 4  range 0 .. 31;
      RTSR  at 8  range 0 .. 31;
      FTSR  at 12 range 0 .. 31;
      SWIER at 16 range 0 .. 31;
      PR    at 20 range 0 .. 31;
   end record;

   EXTI : EXTI_Register with
     Volatile,
     Address => System'To_Address (16#40013C00#), -- EXTI_Base
     Import;

end registers;
