with system;      use system;
with interfaces;  use interfaces;
with ada.unchecked_conversion;

package stm32f4 is

   subtype byte  is unsigned_8;
   subtype short is unsigned_16;
   subtype word  is unsigned_32;

   type byte_array  is array (natural range <>) of byte;
   type short_array is array (natural range <>) of short;
   type word_array  is array (natural range <>) of word;

   type bit    is mod 2**1 with size => 1;
   type uint2  is mod 2**2 with size => 2;
   type uint3  is mod 2**3 with size => 3;
   type uint4  is mod 2**4 with size => 4;
   type uint5  is mod 2**5 with size => 5;
   type uint6  is mod 2**6 with size => 6;
   type uint9  is mod 2**9 with size => 9;
   type uint12 is mod 2**12 with size => 12;

end stm32f4;
