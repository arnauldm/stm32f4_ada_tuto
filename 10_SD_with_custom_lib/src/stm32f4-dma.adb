with system; use system;
with stm32f4.periphs;

package body stm32f4.dma is

   function get_stream_ISR
     (DMA_controller : t_DMA_controller;
      stream         : t_DMA_stream_index)
      return t_DMA_stream_ISR
   is
      ISR : t_DMA_stream_ISR;
   begin
      case stream is
         when 0 => ISR := DMA_controller.LISR.stream_0;
         when 1 => ISR := DMA_controller.LISR.stream_1;
         when 2 => ISR := DMA_controller.LISR.stream_2;
         when 3 => ISR := DMA_controller.LISR.stream_3;
         when 4 => ISR := DMA_controller.HISR.stream_4;
         when 5 => ISR := DMA_controller.HISR.stream_5;
         when 6 => ISR := DMA_controller.HISR.stream_6;
         when 7 => ISR := DMA_controller.HISR.stream_7;
      end case;
      return ISR;
   end get_stream_ISR;


   procedure set_IFCR
     (DMA_controller : in out t_DMA_controller;
      stream         : t_DMA_stream_index;
      IFCR           : t_DMA_stream_clear_interrupts)
   is
   begin
      case stream is
         when 0 => DMA_controller.LIFCR.stream_0 := IFCR;
         when 1 => DMA_controller.LIFCR.stream_1 := IFCR;
         when 2 => DMA_controller.LIFCR.stream_2 := IFCR;
         when 3 => DMA_controller.LIFCR.stream_3 := IFCR;
         when 4 => DMA_controller.HIFCR.stream_4 := IFCR;
         when 5 => DMA_controller.HIFCR.stream_5 := IFCR;
         when 6 => DMA_controller.HIFCR.stream_6 := IFCR;
         when 7 => DMA_controller.HIFCR.stream_7 := IFCR;
      end case;
   end set_IFCR;


   procedure clear_interrupt_flag
     (controller  : in out t_DMA_controller;
      stream      : t_DMA_stream_index;
      interrupt   : t_DMA_interrupts)
   is
      IFCR : t_DMA_stream_clear_interrupts := (others => false);
   begin

      case interrupt is
         when FIFO_ERROR         => IFCR.CLEAR_FIFO_ERROR_IF := true;
         when DIRECT_MODE_ERROR  => IFCR.CLEAR_DIRECT_MODE_ERROR_IF := true;
         when TRANSFER_ERROR     => IFCR.CLEAR_TRANSFER_ERROR_IF := true;
         when HALF_TRANSFER_COMPLETE => IFCR.CLEAR_HALF_TRANSFER_IF := true;
         when TRANSFER_COMPLETE  => IFCR.CLEAR_TRANSFER_COMPLETE_IF := true;
      end case;

      set_IFCR (controller, stream, IFCR);

   end clear_interrupt_flag;


   procedure clear_interrupt_flags
     (controller  : in out t_DMA_controller;
      stream      : t_DMA_stream_index)
   is
      IFCR : constant t_DMA_stream_clear_interrupts := (others => true);
   begin
      set_IFCR (controller, stream, IFCR);
   end clear_interrupt_flags;


   function get_irq_number
     (DMA_controller : t_DMA_controller;
      stream         : t_DMA_stream_index)
      return nvic.interrupt
   is
      irq : nvic.interrupt;
   begin
      if DMA_controller'address = periphs.DMA1'address then
         case stream is
            when 0 => irq := nvic.DMA1_Stream_0;
            when 1 => irq := nvic.DMA1_Stream_1;
            when 2 => irq := nvic.DMA1_Stream_2;
            when 3 => irq := nvic.DMA1_Stream_3;
            when 4 => irq := nvic.DMA1_Stream_4;
            when 5 => irq := nvic.DMA1_Stream_5;
            when 6 => irq := nvic.DMA1_Stream_6;
            when 7 => irq := nvic.DMA1_Stream_7;
         end case;
      elsif DMA_controller'address = periphs.DMA2'address then
         case stream is
            when 0 => irq := nvic.DMA2_Stream_0;
            when 1 => irq := nvic.DMA2_Stream_1;
            when 2 => irq := nvic.DMA2_Stream_2;
            when 3 => irq := nvic.DMA2_Stream_3;
            when 4 => irq := nvic.DMA2_Stream_4;
            when 5 => irq := nvic.DMA2_Stream_5;
            when 6 => irq := nvic.DMA2_Stream_6;
            when 7 => irq := nvic.DMA2_Stream_7;
         end case;
      else
         raise program_error;
      end if;
      return irq;
   end get_irq_number;


end stm32f4.dma;
