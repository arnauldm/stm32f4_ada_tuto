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

   -- Annotation for gnatprove
   pragma Annotate (GNATprove, False_Positive,
      "* might not be initialized after elaboration of main program",
      "components uses MMIO accesses which don't need to be initialized");

   loop

      timer.wait (200);

      board.toggle_green_led;

      -- Annotation for gnatprove
      pragma Annotate (GNATprove, False_Positive,
         "* might not be initialized after elaboration of main program",
         "components uses MMIO accesses which don't need to be initialized");

      board.put ("[" & integer'image(counter) & "]  hello, world!" & ASCII.CR);

      -- Buggy! The counter will overflow
      counter := counter + 1;

   end loop;

end main;
