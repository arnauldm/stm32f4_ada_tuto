with system;

package registers is

   type bit is range 0 .. 1;
   for bit'size use 1;

   type bits_32 is array (0 .. 31) of bit
      with pack, size => 32;

   type EXTI_register is record
      IMR   : bits_32;
      EMR   : bits_32;
      RTSR  : bits_32;
      FTSR  : bits_32;
      SWIER : bits_32;
      PR    : bits_32;
   end record;

   for EXTI_register use record
      IMR   at 0  range 0 .. 31;
      EMR   at 4  range 0 .. 31;
      RTSR  at 8  range 0 .. 31;
      FTSR  at 12 range 0 .. 31;
      SWIER at 16 range 0 .. 31;
      PR    at 20 range 0 .. 31;
   end record;

   EXTI : EXTI_register with
     volatile,
     address => system'to_address (16#40013C00#), -- EXTI_Base
     import;

end registers;
