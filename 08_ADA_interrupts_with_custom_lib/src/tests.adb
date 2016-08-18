with system;
with Ada.Interrupts.Names;
with ada.unchecked_conversion;

with stm32f4; use stm32f4;
with stm32f4.dma;
with stm32f4.periphs;
with stm32f4.nvic;
with serial;

package body tests is

   src : stm32f4.byte_array (1 .. 1024) := (others => 65); -- 'A'
   dst : stm32f4.byte_array (1 .. 1024) := (others => 0);

   DMA_controller : stm32f4.dma.t_DMA_controller
                        renames stm32f4.periphs.DMA2;
   stream : constant stm32f4.dma.t_stream_index := 3;

   --
   -- Interrupt handler 
   --

   protected handler is
      procedure has_been_interrupted (ret : out boolean);
   private
      interrupted : boolean := false;
      procedure interrupt_handler;
         pragma attach_handler
           (interrupt_handler,
            Ada.Interrupts.Names.DMA2_Stream3_Interrupt);
   end handler;

   protected body handler is

      procedure has_been_interrupted (ret : out boolean) is begin
         ret := interrupted;
      end has_been_interrupted;

      procedure interrupt_handler is begin
         serial.put ("DEBUG> DMA2 interrupt");
         serial.new_line;

         if DMA_controller.LISR.stream_3.FEIF = 1 then
            serial.put ("DEBUG> Stream FIFO error");
            serial.new_line;
            DMA_controller.LIFCR.stream_3.CFEIF := 1; 
         end if;

         if DMA_controller.LISR.stream_3.DMEIF = 1 then
            serial.put ("DEBUG> Stream direct mode error");
            serial.new_line;
            DMA_controller.LIFCR.stream_3.CDMEIF := 1; 
         end if;

         if DMA_controller.LISR.stream_3.TEIF = 1 then
            serial.put ("DEBUG> Stream transfer error");
            serial.new_line;
            DMA_controller.LIFCR.stream_3.CTEIF := 1; 
         end if;

         if DMA_controller.LISR.stream_3.HTIF = 1 then
            serial.put ("DEBUG> Stream half transfer interrupt");
            serial.new_line;
            DMA_controller.LIFCR.stream_3.CHTIF := 1; 
         end if;

         if DMA_controller.LISR.stream_3.TCIF = 1 then
            serial.put ("DEBUG> Stream transfer complete interrupt");
            serial.new_line;
            DMA_controller.LIFCR.stream_3.CTCIF := 1; 
         end if;

         interrupted := true;

      end interrupt_handler;

   end handler;

   function has_been_interrupted return boolean is
      ret : boolean;
   begin
      handler.has_been_interrupted (ret);
      return ret;
   end has_been_interrupted;

   --
   -- Test
   --

   procedure test_dma is

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
      DMA_controller.LIFCR.stream_3.CFEIF  := 1; -- FIFO error
      DMA_controller.LIFCR.stream_3.CDMEIF := 1; -- Direct mode error
      DMA_controller.LIFCR.stream_3.CTEIF  := 1; -- Transfer error
      DMA_controller.LIFCR.stream_3.CHTIF  := 1; -- Half transfer 
      DMA_controller.LIFCR.stream_3.CTCIF  := 1; -- Transfer complete

      -- Peripheral address
      DMA_controller.streams(stream).PAR  := to_word (src'address);

      -- Memory address
      DMA_controller.streams(stream).M0AR := to_word (dst'address);

      -- Total number of items to be tranferred
      DMA_controller.streams(stream).NDTR.NDT := short (src'size / 8);
      
      -- Select the DMA channel 
      DMA_controller.streams(stream).CR.CHSEL := 1; -- Channel 1

      -- Flow controler
      DMA_controller.streams(stream).CR.PFCTRL 
         := stm32f4.dma.DMA_FLOW_CONTROLLER;

      -- Priority
      DMA_controller.streams(stream).CR.PL   := stm32f4.dma.HIGH;

      -- DMA configuration
      DMA_controller.streams(stream).CR.DIR  := stm32f4.dma.MEMORY_TO_MEMORY;
      DMA_controller.streams(stream).CR.PSIZE   := stm32f4.dma.TRANSFER_BYTE;
      DMA_controller.streams(stream).CR.MSIZE   := stm32f4.dma.TRANSFER_BYTE;
      DMA_controller.streams(stream).CR.PINC    := 1;
      DMA_controller.streams(stream).CR.MINC    := 1;
      DMA_controller.streams(stream).CR.PINCOS  := stm32f4.dma.INCREMENT_PSIZE;
      DMA_controller.streams(stream).CR.PBURST  := stm32f4.dma.INCR_4_BEATS;
      DMA_controller.streams(stream).CR.MBURST  := stm32f4.dma.INCR_4_BEATS;

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

      -- Launch transfer!
      DMA_controller.streams(stream).CR.EN := 1;
      
      loop
         exit when has_been_interrupted;
      end loop;

      for i in dst'range loop
         serial.put (to_character (dst(i)));
      end loop;

   end test_dma;


end tests;
