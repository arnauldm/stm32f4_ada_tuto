with ada.real_time; use ada.real_time;
with interfaces; use interfaces;

with stm32f4.sdio.sd_card;
with serial;

package body tests.sdio is

   buf : stm32f4.byte_array (1 .. 512)
      with alignment => 16;

   procedure dump (buf : stm32f4.byte_array) is
      idx : integer := 0;
   begin

      serial.put (integer'image (idx) & " :");

      for i in buf'range loop

         serial.put (stm32f4.byte'image (buf(i)));
         idx := idx + 1;

         if i mod 16 = 0 then
            serial.new_line;
            if idx < buf'last then
               serial.put (integer'image (idx) & " :");
            end if;
         end if;

      end loop;

   end dump;


   procedure read is
      ok  : boolean;
   begin
      serial.put_line ("--- TEST: sdio.sd_card.read_blocks (0, ...) ---");

      stm32f4.sdio.sd_card.read_blocks (0, buf, ok);

      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.read_blocks");
      end if;

      serial.put_line ("buf:");
      dump (buf);
      serial.put_line ("cksum (buf):" & stm32f4.word'image (cksum(buf)));

      serial.put_line ("--- /TEST ---");
   end read;


   procedure read_with_dma is
      ok  : boolean;
      time_start : ada.real_time.time;
      time_end   : ada.real_time.time;
   begin
      serial.put_line ("--- TEST: sdio.sd_card.read_blocks_dma () ---");

      time_start  := ada.real_time.clock;

      stm32f4.sdio.sd_card.read_blocks_dma (0, buf, ok);

      time_end    := ada.real_time.clock;

      serial.put_line ("duration: " & 
         duration'image (to_duration (time_end - time_start)));

      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.read_blocks");
      end if;

      --serial.put_line ("buf:"); dump (buf);
      serial.put_line ("cksum (buf):" & stm32f4.word'image (cksum(buf)));

      serial.put_line ("--- /TEST ---");
   end read_with_dma;


   procedure write_with_dma is
      ok       : boolean;
      pattern  : stm32f4.byte;
   begin
      serial.put_line ("--- TEST: sdio.sd_card.write_blocks_dma () ---");

      -- Set input buffer with a recognizable pattern
      pattern := 16#30#;
      for i in buf'range loop
         buf(i) := pattern;
         if pattern < 16#7D# then
            pattern := pattern + 1;
         else
            pattern := 16#30#;
         end if;
      end loop;

      stm32f4.sdio.sd_card.write_blocks_dma (0, buf, ok);
      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.write_blocks_dma");
      end if;

      serial.put_line ("--- /TEST ---");
   end write_with_dma;


end tests.sdio;
