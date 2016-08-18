
package body stm32f4.dma is


   function get_ISR
     (DMA_controller : t_DMA_controller;
      stream         : t_DMA_stream_index)
      return t_DMA_stream_interrupt_status
   is
      ISR : t_DMA_stream_interrupt_status;
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
   end get_ISR;


   function stream_interrupt_is_set
     (controller  : t_DMA_controller;
      stream      : t_DMA_stream_index;
      interrupt   : DMA_interrupts)
      return boolean
   is
      ISR : constant t_DMA_stream_interrupt_status
         := get_ISR (controller, stream);
   begin
      case interrupt is
         when FIFO_ERROR               => return ISR.FEIF  = 1;
         when DIRECT_MODE_ERROR        => return ISR.DMEIF = 1;
         when TRANSFER_ERROR           => return ISR.TEIF  = 1;
         when HALF_TRANSFER_COMPLETE   => return ISR.HTIF  = 1;
         when TRANSFER_COMPLETE        => return ISR.TCIF  = 1;
      end case;
   end stream_interrupt_is_set;


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


   procedure clear_stream_interrupt
     (controller  : in out t_DMA_controller;
      stream      : t_DMA_stream_index;
      interrupt   : DMA_interrupts)
   is
      IFCR : t_DMA_stream_clear_interrupts := (others => 0);
   begin

      case interrupt is
         when FIFO_ERROR               => IFCR.CFEIF  := 1;
         when DIRECT_MODE_ERROR        => IFCR.CDMEIF := 1;
         when TRANSFER_ERROR           => IFCR.CTEIF  := 1;
         when HALF_TRANSFER_COMPLETE   => IFCR.CHTIF  := 1;
         when TRANSFER_COMPLETE        => IFCR.CTCIF  := 1;
      end case;

      set_IFCR (controller, stream, IFCR);

   end clear_stream_interrupt;


   procedure clear_stream_interrupts
     (controller  : in out t_DMA_controller;
      stream      : t_DMA_stream_index)
   is
      IFCR : constant t_DMA_stream_clear_interrupts :=
        (CFEIF       => 1,
         reserved_1  => 0,
         CDMEIF      => 1,
         CTEIF       => 1,
         CHTIF       => 1,
         CTCIF       => 1);
   begin
      set_IFCR (controller, stream, IFCR);
   end clear_stream_interrupts;


end stm32f4.dma;
