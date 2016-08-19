with system;
with ada.unchecked_conversion;
with interfaces;  use interfaces;

package stm32f4 is

   subtype byte  is unsigned_8;
   subtype short is unsigned_16;
   subtype word  is unsigned_32;

   function to_word is new ada.unchecked_conversion
     (system.address, word);

   type byte_array  is array (natural range <>) of byte  with pack;
   type short_array is array (natural range <>) of short with pack;
   type word_array  is array (natural range <>) of word  with pack;

   type byte_array_access  is access all byte_array;
   type short_array_access is access all short_array;
   type word_array_access  is access all word_array;

   type bit    is mod 2**1 with size => 1;
   type uint2  is mod 2**2 with size => 2;
   type uint3  is mod 2**3 with size => 3;
   type uint4  is mod 2**4 with size => 4;
   type uint5  is mod 2**5 with size => 5;
   type uint6  is mod 2**6 with size => 6;
   type uint7  is mod 2**7 with size => 7;
   type uint9  is mod 2**9 with size => 9;
   type uint12 is mod 2**12 with size => 12;
   type uint24 is mod 2**24 with size => 24;
   type uint25 is mod 2**25 with size => 25;

end stm32f4;
