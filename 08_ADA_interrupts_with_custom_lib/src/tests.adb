with system;
with ada.real_time; use ada.real_time;
with ada.unchecked_conversion;
with ada.interrupts.names;

with stm32f4; use stm32f4;
with stm32f4.dma;
with stm32f4.dma.interrupts;
with stm32f4.periphs;
with stm32f4.nvic;
with serial;

package body tests is

   src : stm32f4.byte_array (1 .. 1024) := (others => 65); -- 'A'
   dst : stm32f4.byte_array (1 .. 1024) := (others => 0);

   DMA_controller : stm32f4.dma.t_DMA_controller renames stm32f4.periphs.DMA2;
   stream         : constant stm32f4.dma.t_DMA_stream_index := 3;

   irq_handler : 
      stm32f4.dma.interrupts.handler
        (DMA_controller'access,
         stream,
         Ada.Interrupts.Names.DMA2_Stream3_Interrupt);

   start_time  : ada.real_time.time;
   end_time    : ada.real_time.time;

   --
   -- Test
   --

   procedure test_dma_mem_to_mem is

      function to_word is new ada.unchecked_conversion
        (ada.real_time.time_span, stm32f4.word);

      function to_word is new ada.unchecked_conversion
        (system.address, stm32f4.word);

      function to_character is new ada.unchecked_conversion
         (byte, character);

   begin

      -- DMA2 clock enable
      stm32f4.periphs.RCC.AHB1ENR.DMA2EN := 1;

      -- Reset the stream
      --    (AN4031 p. 14-15)
      if (DMA_controller.streams(stream).CR.EN = 1) then
         DMA_controller.streams(stream).CR.EN := 0;
         loop
            exit when DMA_controller.streams(stream).CR.EN = 0;
         end loop;
      end if;

      -- Clear interrupts flags
      stm32f4.dma.clear_stream_interrupts (DMA_controller, stream);

      -- Transfer direction
      DMA_controller.streams(stream).CR.DIR  := stm32f4.dma.MEMORY_TO_MEMORY;
      -- Peripheral address
      DMA_controller.streams(stream).PAR  := to_word (src'address);

      -- Memory address
      DMA_controller.streams(stream).M0AR := to_word (dst'address);

      -- Total number of items to be tranferred
      DMA_controller.streams(stream).NDTR.NDT := short (src'size / 8);

      -- Items size
      DMA_controller.streams(stream).CR.PSIZE   := stm32f4.dma.TRANSFER_BYTE;
      DMA_controller.streams(stream).CR.MSIZE   := stm32f4.dma.TRANSFER_BYTE;
      DMA_controller.streams(stream).CR.PINC    := 1;
      DMA_controller.streams(stream).CR.MINC    := 1;
      DMA_controller.streams(stream).CR.PINCOS  := stm32f4.dma.INCREMENT_PSIZE;
      
      -- Select the DMA channel 
      DMA_controller.streams(stream).CR.CHSEL := 1; -- Channel 1

      -- Flow controler
      DMA_controller.streams(stream).CR.PFCTRL 
         := stm32f4.dma.DMA_FLOW_CONTROLLER;

      -- Priority
      DMA_controller.streams(stream).CR.PL   := stm32f4.dma.HIGH;

      -- DMA bursts
      DMA_controller.streams(stream).CR.PBURST  := stm32f4.dma.INCR_16_BEATS;
      DMA_controller.streams(stream).CR.MBURST  := stm32f4.dma.INCR_16_BEATS;

      -- Direct mode disable, RM0090 p. 336: "This bit is set by hardware
      -- if the memory-to-memory mode is selected [...] because the direct
      -- mode is not allowed in the memory-to-memory configuration"
      DMA_controller.streams(stream).FCR.DMDIS  := 1;

      -- FIFO threshold
      DMA_controller.streams(stream).FCR.FTH    := stm32f4.dma.FIFO_FULL;

      --
      -- Enable interrupts
      --

      -- FIFO error interrupt enable
      DMA_controller.streams(stream).FCR.FEIE   := 1;
      DMA_controller.streams(stream).CR.DMEIE   := 1;
      DMA_controller.streams(stream).CR.TEIE    := 1;
      DMA_controller.streams(stream).CR.HTIE    := 1;
      DMA_controller.streams(stream).CR.TCIE    := 1;

      stm32f4.periphs.NVIC.IPR(stm32f4.nvic.DMA2_Stream_3).priority := 0;
      stm32f4.periphs.NVIC.ISER1.irq(stm32f4.nvic.DMA2_Stream_3)
         := stm32f4.nvic.IRQ_ENABLED;

      --
      -- Launch transfer!
      --

      start_time := ada.real_time.clock;
      DMA_controller.streams(stream).CR.EN := 1;
      
      loop
         declare 
            interrupted : boolean;
            flags       : stm32f4.dma.interrupts.t_interrupt_flags;
         begin

            irq_handler.has_been_interrupted (interrupted);

            if interrupted then
               end_time := ada.real_time.clock;
               flags    := irq_handler.get_flags;

               if flags.FIFO_ERROR then
                  serial.put ("FIFO error"); serial.new_line;
               end if;

               if flags.DIRECT_MODE_ERROR then
                  serial.put ("Direct mode error"); serial.new_line;
               end if;

               if flags.TRANSFER_ERROR then
                  serial.put ("Transfer error"); serial.new_line;
               end if;

               if flags.HALF_TRANSFER_COMPLETE then
                  serial.put ("Half transfer"); 
                  serial.new_line;
               end if;

               if flags.TRANSFER_COMPLETE then
                  serial.put ("Transfer complete"); serial.new_line;
                  exit;
               end if;

            end if;

         end;
      end loop;

      serial.put ("Elapsed time: " &
         word'image (to_word (end_time - start_time)));
      serial.new_line;

      for i in dst'range loop
         serial.put (to_character (dst(i)));
      end loop;

   end test_dma_mem_to_mem;


end tests;
