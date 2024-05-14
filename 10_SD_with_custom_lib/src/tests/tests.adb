with interfaces; use interfaces;
with serial;

package body tests is

   function cksum (buf : stm32f4.byte_array) return stm32f4.word
   is
      ret : stm32f4.word := 0;
   begin
      for n in buf'range
      loop
         ret := shift_right (ret, 1) + shift_left ((ret and 1), 15);
         ret := ret + (16#ff# and stm32f4.word (buf(n)));
         ret := ret and 16#ffff#;
      end loop;
      return ret;
   end cksum;

end tests;
