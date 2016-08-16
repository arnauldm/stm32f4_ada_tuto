with ada.real_time;     use ada.real_time;
with ada.unchecked_conversion;

with stm32f4;           use stm32f4;
with stm32f4.gpio;      use stm32f4.gpio;
with stm32f4.periphs;   use stm32f4.periphs;
with serial;

package body last_chance_handler is

   procedure put (ptr : system.address);

   ---------
   -- put --
   ---------

   procedure put (ptr : system.address) is

      type c_string_ptr is access string (1 .. positive'last) with
        storage_size => 0, size => standard'address_size;

      function as_c_string_ptr is new ada.unchecked_conversion
        (system.address, c_string_ptr);

      msg_str : constant c_string_ptr := as_c_string_ptr (ptr);

   begin
      for j in msg_str'range loop
         exit when msg_str (j) = character'val (0);
         serial.put (msg_str (j));
      end loop;
   end put;

   -------------------------
   -- last_chance_handler --
   -------------------------

   procedure last_chance_handler (file : system.address; line : integer) is
   begin

      -- The leds are on GPIOD pins. We have to enable GPIOD clock 
      periphs.RCC.AHB1ENR.GPIODEN := 1;
      configure (LED_GREEN, MODE_OUT, PUSH_PULL, SPEED_HIGH, PULL_DOWN);
      configure (LED_ORANGE, MODE_OUT, PUSH_PULL, SPEED_HIGH, PULL_DOWN);
      configure (LED_RED, MODE_OUT, PUSH_PULL, SPEED_HIGH, PULL_DOWN);
      configure (LED_BLUE, MODE_OUT, PUSH_PULL, SPEED_HIGH, PULL_DOWN);

      turn_off (LED_GREEN);
      turn_off (LED_ORANGE);
      turn_off (LED_RED);
      turn_off (LED_BLUE);

      if serial.enabled then
         if line /= 0 then
            serial.put (">>> exception at ");
            put (file);
            serial.put (" line");
            serial.put (line'img);
         else
            serial.put (">>> user-defined exception, message: ");
            put (file);
         end if;
   
         serial.put (ASCII.CR);
      end if;

      loop
         turn_on (LED_RED);
         delay until clock + milliseconds (500);
         turn_off (LED_RED);
         delay until clock + milliseconds (500);
      end loop;
   end last_chance_handler;

end last_chance_handler;

