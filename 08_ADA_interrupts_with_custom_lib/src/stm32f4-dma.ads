--
-- Ref. : RM0090, p. 304-340
--        AN4031, "Using the STM32Fx Series DMA controller"
--

package stm32f4.dma is

   --------------------------------------------------
   -- DMA low interrupt status register (DMA_LISR) --
   --------------------------------------------------

   type t_DMA_stream_interrupt_status is record
      FEIF        : bit;   -- Stream FIFO error interrupt flag
      reserved_1  : bit;
      DMEIF       : bit;   -- Stream direct mode error interrupt flag
      TEIF        : bit;   -- Stream transfer error interrupt flag
      HTIF        : bit;   -- Stream half transfer interrupt flag
      TCIF        : bit;   -- Stream transfer complete interrupt flag
   end record
      with pack, size => 6;

   type t_DMA_LISR is record
      stream_0       : t_DMA_stream_interrupt_status;
      stream_1       : t_DMA_stream_interrupt_status;
      reserved_12_15 : uint4;
      stream_2       : t_DMA_stream_interrupt_status;
      stream_3       : t_DMA_stream_interrupt_status;
      reserved_28_31 : uint4;
   end record
      with pack, size => 32, volatile_full_access;

   ---------------------------------------------------
   -- DMA high interrupt status register (DMA_HISR) --
   ---------------------------------------------------

   type t_DMA_HISR is record
      stream_4       : t_DMA_stream_interrupt_status;
      stream_5       : t_DMA_stream_interrupt_status;
      reserved_12_15 : uint4;
      stream_6       : t_DMA_stream_interrupt_status;
      stream_7       : t_DMA_stream_interrupt_status;
      reserved_28_31 : uint4;
   end record
      with pack, size => 32, volatile_full_access;

   -------------------------------------------------------
   -- DMA low interrupt flag clear register (DMA_LIFCR) --
   -------------------------------------------------------

   type t_DMA_stream_clear_interrupts is record
      CFEIF       : bit; -- Stream clear FIFO error interrupt flag
      reserved_1  : bit;
      CDMEIF      : bit; -- Stream clear direct mode error interrupt flag
      CTEIF       : bit; -- Stream clear transfer error interrupt flag
      CHTIF       : bit; -- Stream clear half transfer interrupt flag
      CTCIF       : bit; -- Stream clear transfer complete interrupt flag
   end record
      with pack, size => 6;

   type t_DMA_LIFCR is record
      stream_0       : t_DMA_stream_clear_interrupts;
      stream_1       : t_DMA_stream_clear_interrupts;
      reserved_12_15 : uint4;
      stream_2       : t_DMA_stream_clear_interrupts;
      stream_3       : t_DMA_stream_clear_interrupts;
      reserved_28_31 : uint4;
   end record
      with pack, size => 32, volatile_full_access;

   --------------------------------------------------------
   -- DMA high interrupt flag clear register (DMA_HIFCR) --
   --------------------------------------------------------

   type t_DMA_HIFCR is record
      stream_4       : t_DMA_stream_clear_interrupts;
      stream_5       : t_DMA_stream_clear_interrupts;
      reserved_12_15 : uint4;
      stream_6       : t_DMA_stream_clear_interrupts;
      stream_7       : t_DMA_stream_clear_interrupts;
      reserved_28_31 : uint4;
   end record
      with pack, size => 32, volatile_full_access;


   ----------------------------------------------------
   -- DMA stream x configuration register (DMA_SxCR) --
   ----------------------------------------------------

   type t_flow_controller is (DMA_FLOW_CONTROLLER, PERIPH_FLOW_CONTROLLER)
      with size => 1;
   for t_flow_controller use
     (DMA_FLOW_CONTROLLER     => 0,
      PERIPH_FLOW_CONTROLLER  => 1);

   type t_data_transfer_dir is
     (PERIPHERAL_TO_MEMORY, MEMORY_TO_PERIPHERAL, MEMORY_TO_MEMORY)
      with size => 2;
   for t_data_transfer_dir use
     (PERIPHERAL_TO_MEMORY => 2#00#,
      MEMORY_TO_PERIPHERAL => 2#01#,
      MEMORY_TO_MEMORY     => 2#10#);

   type t_data_transfer_size is
     (TRANSFER_BYTE, TRANSFER_HALF_WORD, TRANSFER_WORD)
      with size => 2;
   for t_data_transfer_size use
     (TRANSFER_BYTE        => 2#00#,
      TRANSFER_HALF_WORD   => 2#01#,
      TRANSFER_WORD        => 2#10#);
      
   type t_increment_offset_size is (INCREMENT_PSIZE, INCREMENT_WORD) 
      with size => 1;
   for t_increment_offset_size use
     (INCREMENT_PSIZE   => 0,
      INCREMENT_WORD    => 1);

   type t_priority_level is (LOW, MEDIUM, HIGH, VERY_HIGH) with size => 2;
   for t_priority_level use
     (LOW         => 2#00#, 
      MEDIUM      => 2#01#, 
      HIGH        => 2#10#, 
      VERY_HIGH   => 2#11#);

   type t_current_target is (MEMORY_0, MEMORY_1) with size => 1;
   for t_current_target use
     (MEMORY_0 => 0,
      MEMORY_1 => 1);

   type t_burst_size is
     (SINGLE_TRANSFER, INCR_4_BEATS, INCR_8_BEATS, INCR_16_BEATS)
      with size => 2;
   for t_burst_size use
     (SINGLE_TRANSFER   => 2#00#,
      INCR_4_BEATS      => 2#01#,
      INCR_8_BEATS      => 2#10#,
      INCR_16_BEATS     => 2#11#);

   type t_DMA_SxCR is record
      EN       : bit;   -- Stream enable / flag stream ready when read low
      DMEIE    : bit;   -- Direct mode error interrupt enable
      TEIE     : bit;   -- Transfer error interrupt enable
      HTIE     : bit;   -- Half transfer interrupt enable
      TCIE     : bit;   -- Transfer complete interrupt enable
      PFCTRL   : t_flow_controller; -- Peripheral flow controller
      DIR      : t_data_transfer_dir; -- Data transfer direction
      CIRC     : bit;   -- Circular mode enable
      PINC     : bit;   -- Peripheral increment mode enable
      MINC     : bit;   -- Memory increment mode enable
      PSIZE    : t_data_transfer_size; -- Peripheral data size
      MSIZE    : t_data_transfer_size; -- Memory data size
      PINCOS   : t_increment_offset_size; -- Peripheral increment offset size
      PL       : t_priority_level; -- Priority level
      DBM      : bit;   -- Double buffer mode
      CT       : t_current_target; -- Current target
      reserved_20    : bit;
      PBURST   : t_burst_size; -- Peripheral burst transfer configuration
      MBURST   : t_burst_size; -- Memory burst transfer configuration
      CHSEL    : uint3; -- Channel selection (0..7)
      reserved_28_31 : uint4;
   end record
      with pack, size => 32, volatile_full_access;

   -------------------------------------------------------
   -- DMA stream x number of data register (DMA_SxNDTR) --
   -------------------------------------------------------

   type t_DMA_SxNDTR is record
      NDT : short;
         -- Number of data items to be transferred (0 up to 65535)
      reserved_16_31 : short;
   end record
      with pack, size => 32, volatile_full_access;

   ----------------------------------------------------------
   -- DMA stream x peripheral address register (DMA_SxPAR) --
   ----------------------------------------------------------

   subtype t_DMA_SxPAR is word;

   ---------------------------------------------------------
   -- DMA stream x memory 0 address register (DMA_SxM0AR) --
   ---------------------------------------------------------

   subtype t_DMA_SxM0AR is word;

   ---------------------------------------------------------
   -- DMA stream x memory 1 address register (DMA_SxM1AR) --
   ---------------------------------------------------------

   subtype t_DMA_SxM1AR is word;

   ----------------------------------------------------
   -- DMA stream x FIFO control register (DMA_SxFCR) --
   ----------------------------------------------------

   type t_FIFO_threshold is
     (FIFO_1DIV4_FULL, FIFO_1DIV2_FULL, FIFO_3DIV4_FULL, FIFO_FULL)
      with size => 2;
   for t_FIFO_threshold use
     (FIFO_1DIV4_FULL   => 2#00#,
      FIFO_1DIV2_FULL   => 2#01#,
      FIFO_3DIV4_FULL   => 2#10#,
      FIFO_FULL         => 2#11#);

   type t_FIFO_status is
     (FIFO_LESS_1DIV4, FIFO_LESS_1DIV2, FIFO_LESS_3DIV4, FIFO_IS_EMPTY,
      FIFO_IS_FULL)
      with size => 3;
   for t_FIFO_status use
     (FIFO_LESS_1DIV4   => 2#001#,
      FIFO_LESS_1DIV2   => 2#010#,
      FIFO_LESS_3DIV4   => 2#011#,
      FIFO_IS_EMPTY     => 2#100#,
      FIFO_IS_FULL      => 2#101#);

   type t_DMA_SxFCR is record
      FTH         : t_FIFO_threshold;  -- FIFO threshold selection
      DMDIS       : bit;               -- Direct mode disable
      FS          : t_FIFO_status;     -- FIFO status
      reserved_6  : bit;
      FEIE        : bit;               -- FIFO error interrupt enable
      reserved_8_15  : byte;
      reserved_16_31 : short;
   end record
      with pack, size => 32, volatile_full_access;

   --------------------
   -- DMA Controller --
   --------------------

   subtype t_DMA_stream_index is natural range 0 .. 7;

   type t_stream_registers is record
      CR    : t_DMA_SxCR;     -- Control register
      NDTR  : t_DMA_SxNDTR;   -- Number of data register
      PAR   : t_DMA_SxPAR;    -- Peripheral address register
      M0AR  : t_DMA_SxM0AR;   -- memory 0 address register
      M1AR  : t_DMA_SxM1AR;   -- memory 1 address register
      FCR   : t_DMA_SxFCR;    -- FIFO control register
   end record;

   for t_stream_registers use record
      CR    at 16#00# range 0 .. 31;
      NDTR  at 16#04# range 0 .. 31;
      PAR   at 16#08# range 0 .. 31;
      M0AR  at 16#0C# range 0 .. 31;
      M1AR  at 16#10# range 0 .. 31;
      FCR   at 16#14# range 0 .. 31;
   end record;

   type t_streams_registers is array (t_DMA_stream_index) of t_stream_registers
      with pack;

   type t_DMA_controller is record
      LISR     : t_DMA_LISR;  -- Interrupt status register (0 .. 3)
      HISR     : t_DMA_HISR;  -- Interrupt status register (4 .. 7)
      LIFCR    : t_DMA_LIFCR; -- Interrupt clear register (0 .. 3)
      HIFCR    : t_DMA_HIFCR; -- Interrupt clear register (4 .. 7)
      streams  : t_streams_registers;
   end record;

   for t_DMA_controller use record
      LISR     at 16#00# range 0 .. 31;
      HISR     at 16#04# range 0 .. 31;
      LIFCR    at 16#08# range 0 .. 31;
      HIFCR    at 16#0C# range 0 .. 31;
      streams  at 16#10# range 0 .. (32 * 6 * 8) - 1;
   end record;

   type t_DMA_controller_access is access all t_DMA_controller;

   ---------------
   -- Utilities --
   ---------------

   type DMA_interrupts is
     (FIFO_ERROR, DIRECT_MODE_ERROR, TRANSFER_ERROR,
      HALF_TRANSFER_COMPLETE, TRANSFER_COMPLETE);

   function get_ISR
     (DMA_controller : t_DMA_controller;
      stream         : t_DMA_stream_index)
      return t_DMA_stream_interrupt_status;

   function stream_interrupt_is_set
     (controller  : t_DMA_controller;
      stream      : t_DMA_stream_index;
      interrupt   : DMA_interrupts)
      return boolean;

   procedure clear_stream_interrupt
     (controller  : in out t_DMA_controller;
      stream      : t_DMA_stream_index;
      interrupt   : DMA_interrupts);

   procedure clear_stream_interrupts
     (controller  : in out t_DMA_controller;
      stream      : t_DMA_stream_index);

end stm32f4.dma;
