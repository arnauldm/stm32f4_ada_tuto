with stm32f4.sdio.sd_card;
with serial;

package body tests.sdio is

   buf : stm32f4.byte_array (1 .. 512);

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

      stm32f4.sdio.sd_card.initialize;
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
   begin
      serial.put_line ("--- TEST: sdio.sd_card.read_blocks_dma (0, ...) ---");

      stm32f4.sdio.sd_card.initialize;
      stm32f4.sdio.sd_card.read_blocks_dma (0, buf, ok);

      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.read_blocks");
      end if;

      serial.put_line ("buf:");
      dump (buf);
      serial.put_line ("cksum (buf):" & stm32f4.word'image (cksum(buf)));

      serial.put_line ("--- /TEST ---");
   end read_with_dma;

end tests.sdio;
