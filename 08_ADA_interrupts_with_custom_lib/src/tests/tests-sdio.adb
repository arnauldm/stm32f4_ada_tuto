with system;      use system;
with interfaces;  use interfaces;
with ada.unchecked_deallocation;

with stm32f4.sdio.sd_card;
with serial;

package body tests.sdio is

   -- Buffer  used for DMA transfers must be 16 bytes aligned
   type dma_array is new stm32f4.byte_array with alignment => 16;
   type dma_array_access is access all dma_array;
   procedure free_dma_array is
      new ada.unchecked_deallocation (dma_array, dma_array_access);


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


   procedure read_with_dma 
     (lba   : in stm32f4.word;
      size  : in natural)
   is
      ok       : boolean;
      buf_a    : dma_array_access;
   begin
      serial.put_line ("--- TEST: sdio.sd_card.read_blocks_dma () ---");

      -- Allocate the input buffer
      buf_a := new dma_array (1 .. size);

      for i in buf_a'range loop
         buf_a(i) := 0;
      end loop;

      -- Reading
      stm32f4.sdio.sd_card.read_blocks_dma
        (lba, stm32f4.byte_array (buf_a.all), ok);

      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.read_blocks");
      end if;

      --serial.put_line ("buf:"); dump (buf);
      serial.put_line 
        ("cksum (buf):" & 
         stm32f4.word'image (cksum (stm32f4.byte_array (buf_a.all))));

      free_dma_array (buf_a); 

      serial.put_line ("--- /TEST ---");
   end read_with_dma;


   procedure write_with_dma 
     (lba   : in stm32f4.word;
      size  : in natural)
   is
      ok       : boolean;
      pattern  : stm32f4.byte;
      buf_a    : dma_array_access;
   begin
      serial.put_line ("--- TEST: sdio.sd_card.write_blocks_dma () ---");

      -- Allocate the input buffer
      buf_a := new dma_array (1 .. size);

      -- Set input buffer with a recognizable pattern
      pattern := 16#10#;
      for i in buf_a'range loop
         buf_a(i) := pattern;
         if i mod 8 = 0 then
            if pattern < 16#7D# then
               pattern := pattern + 1;
            else
               pattern := 16#10#;
            end if;
         end if;
      end loop;

      -- Display the expected cksum
      serial.put_line
        ("expected cksum (buf):" & 
         stm32f4.word'image (cksum (stm32f4.byte_array (buf_a.all))));

      -- Write the buffer 
      stm32f4.sdio.sd_card.write_blocks_dma 
        (lba, stm32f4.byte_array (buf_a.all), ok);

      if not ok then
         serial.put_line ("error: stm32f4.sdio.sd_card.write_blocks_dma");
      end if;

      free_dma_array (buf_a); 

      serial.put_line ("--- /TEST ---");
   end write_with_dma;


end tests.sdio;
