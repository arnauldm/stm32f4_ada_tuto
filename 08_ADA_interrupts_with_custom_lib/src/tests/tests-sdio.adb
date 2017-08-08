with interfaces; use interfaces;

with stm32f4.sdio.sd_card;
with serial;

package body tests.sdio is

   buf : stm32f4.byte_array (1 .. 1024)
      with alignment => 16;

   buf_cksum : stm32f4.word;

   lba : constant stm32f4.word := 10;
   --lba : constant stm32f4.word := 30881792;

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


   procedure read_with_dma is
      ok             : boolean;
   begin
      serial.put_line ("--- TEST: sdio.sd_card.read_blocks_dma () ---");


      buf_cksum:= cksum (buf);
      serial.put_line ("expected cksum (buf):" & stm32f4.word'image (buf_cksum));

      stm32f4.sdio.sd_card.read_blocks_dma (lba, buf, ok);

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
      pattern := 16#10#;
      for i in buf'range loop
         buf(i) := pattern;
         if i mod 8 = 0 then
            if pattern < 16#7D# then
               pattern := pattern + 1;
            else
               pattern := 16#10#;
            end if;
         end if;
      end loop;

      stm32f4.sdio.sd_card.write_blocks_dma (lba, buf, ok);
      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.write_blocks_dma");
      end if;

      serial.put_line ("--- /TEST ---");
   end write_with_dma;


end tests.sdio;
