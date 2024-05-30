with stm32f4;           use stm32f4;
with stm32f4.gpio;      use stm32f4.gpio;
with stm32f4.periphs;   use stm32f4.periphs;
with serial;

package body last_chance_handler
   with spark_mode => on
is

   procedure put (ptr : system.address);

   ---------
   -- put --
   ---------

   procedure put (ptr : system.address) is

      pragma warnings (off, "indirect writes * through a potential alias are ignored");
      pragma warnings (off, "is assumed to have no effects on other non-volatile objects");
      pragma warnings (off, "assuming no concurrent accesses to non-atomic object");
      pragma warnings (off, "assuming valid reads from object");

      msg_str : array (natural) of character with import, address => ptr;

      pragma warnings (on);

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
      periphs.RCC.AHB1ENR.GPIODEN := true;
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

      turn_on (LED_RED);

      loop
         null;
      end loop;
   end last_chance_handler;

end last_chance_handler;

