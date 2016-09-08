with ada.real_time; use ada.real_time;
with interfaces; use interfaces;
with ada.unchecked_conversion;
with ada.interrupts.names;

with stm32f4; use stm32f4;
with stm32f4.dma;
with stm32f4.dma.interrupts;
with stm32f4.periphs;
with stm32f4.nvic;
with serial;

package body tests.dma is

   src : stm32f4.byte_array (1 .. 1024) := (others => 65); -- 'A'
   dst : stm32f4.byte_array (1 .. 1024) := (others => 0);

   DMA_controller : stm32f4.dma.t_DMA_controller renames stm32f4.periphs.DMA2;
   stream         : constant stm32f4.dma.t_DMA_stream_index := 1;

   irq_handler    : 
      stm32f4.dma.interrupts.handler
        (stm32f4.periphs.DMA2'access,
         1,
         Ada.Interrupts.Names.DMA2_Stream1_Interrupt);

   start_time  : ada.real_time.time;
   end_time    : ada.real_time.time;

   --
   -- Test
   --

   procedure transfer_memory_to_memory is

      function to_unsigned_64 is new ada.unchecked_conversion
        (ada.real_time.time_span, unsigned_64);

      function to_character is new ada.unchecked_conversion
         (byte, character);

   begin

      -- DMA2 clock enable
      stm32f4.periphs.RCC.AHB1ENR.DMA2EN := true;

      -- Reset the stream
      --    (AN4031 p. 14-15)
      if DMA_controller.streams(stream).CR.EN then
         DMA_controller.streams(stream).CR.EN := false;
         loop
            exit when DMA_controller.streams(stream).CR.EN = false;
         end loop;
      end if;

      -- Clear interrupts flags
      stm32f4.dma.clear_interrupt_flags (DMA_controller, stream);

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
      DMA_controller.streams(stream).CR.PINC    := true;
      DMA_controller.streams(stream).CR.MINC    := true;
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
      DMA_controller.streams(stream).FCR.FIFO_ERROR            := true;
      DMA_controller.streams(stream).CR.DIRECT_MODE_ERROR      := true;
      DMA_controller.streams(stream).CR.TRANSFER_ERROR         := true;
      DMA_controller.streams(stream).CR.HALF_TRANSFER_COMPLETE := true;
      DMA_controller.streams(stream).CR.TRANSFER_COMPLETE      := true;

      stm32f4.nvic.set_priority (stm32f4.nvic.DMA2_Stream_3, 0);
      stm32f4.nvic.enable_irq (stm32f4.nvic.DMA2_Stream_3);

      --
      -- Launch transfer!
      --

      start_time := ada.real_time.clock;
      DMA_controller.streams(stream).CR.EN := true;
      
      loop
         declare 
            interrupted : boolean;
            status      : stm32f4.dma.t_DMA_stream_ISR;
         begin

            irq_handler.has_been_interrupted (interrupted);

            if interrupted then
               end_time := ada.real_time.clock;
               status    := irq_handler.get_saved_ISR;

               if status.FIFO_ERROR then
                  serial.put_line ("FIFO error");
               end if;

               if status.DIRECT_MODE_ERROR then
                  serial.put_line ("Direct mode error");
               end if;

               if status.TRANSFER_ERROR then
                  serial.put_line ("Transfer error");
               end if;

               if status.HALF_TRANSFER_COMPLETE then
                  serial.put_line ("Half transfer"); 
               end if;

               if status.TRANSFER_COMPLETE then
                  serial.put_line ("Transfer complete");
                  exit;
               end if;

            end if;

         end;
      end loop;

      serial.put ("Elapsed time: " &
         unsigned_64'image (to_unsigned_64 (end_time - start_time)));
      serial.new_line;

      for i in dst'range loop
         serial.put (to_character (dst(i)));
      end loop;

   end transfer_memory_to_memory;


end tests.dma;
