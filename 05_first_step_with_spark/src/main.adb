with last_chance_handler;  pragma unreferenced (last_chance_handler);

with board;
with timer;

procedure main
   with spark_mode => on
is
   subtype small is natural range 0 .. 1000;
   counter : small := 0;
begin

   board.init;

   -- That annotation for gnatprove suppress the warning message (1st quote)
   -- and gives an explanation (2nd quote)
   pragma Annotate (GNATprove, False_Positive,
      "* might not be initialized after elaboration of main program",
      "components uses MMIO accesses which don't need to be initialized");

   loop

      timer.wait (200);

      -- Blink the green led
      board.toggle_green_led;

      pragma Annotate (GNATprove, False_Positive,
         "* might not be initialized after elaboration of main program",
         "components uses MMIO accesses which don't need to be initialized");

      -- Display a message on the USART
      board.put ("[" & integer'image(counter) & "]  hello, world!" & ASCII.CR);

      -- Buggy! The counter will overflow
      counter := counter + 1;

   end loop;

end main;
