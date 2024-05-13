with ada.interrupts;

-- Nested vectored interrupt controller (NVIC)
-- (see STM32F4xxx Cortex-M4 Programming Manual, p. 194-205)

package stm32f4.nvic
   with spark_mode => off
is

   -- Up to 81 interrupts (see Cortex-M4 prog. manual, p. 194)
   type interrupt is new ada.interrupts.interrupt_id range 0 .. 80;

   -- /!\ pragma Attach_Handler directive takes in parameter
   --     Ada.Interrupts.Names.Interrupt_ID.


   ----------------
   -- Interrupts --
   ----------------
   -- (see RM0090, p. 374)

   EXTI_Line_0    : constant interrupt := 6;
   EXTI_Line_1    : constant interrupt := 7;
   EXTI_Line_2    : constant interrupt := 8;
   EXTI_Line_3    : constant interrupt := 9;
   EXTI_Line_4    : constant interrupt := 10;

   DMA1_Stream_0  : constant interrupt := 11;
   DMA1_Stream_1  : constant interrupt := 12;
   DMA1_Stream_2  : constant interrupt := 13;
   DMA1_Stream_3  : constant interrupt := 14;
   DMA1_Stream_4  : constant interrupt := 15;
   DMA1_Stream_5  : constant interrupt := 16;
   DMA1_Stream_6  : constant interrupt := 17;
   DMA1_Stream_7  : constant interrupt := 47;

   SDIO           : constant interrupt := 49;

   DMA2_Stream_0  : constant interrupt := 56;
   DMA2_Stream_1  : constant interrupt := 57;
   DMA2_Stream_2  : constant interrupt := 58;
   DMA2_Stream_3  : constant interrupt := 59;
   DMA2_Stream_4  : constant interrupt := 60;
   DMA2_Stream_5  : constant interrupt := 68;
   DMA2_Stream_6  : constant interrupt := 69;
   DMA2_Stream_7  : constant interrupt := 70;

   -------------------------------------------------
   -- Interrupt set-enable registers (NVIC_ISERx) --
   -------------------------------------------------

   type t_interrupt is (IRQ_DISABLED, IRQ_ENABLED) with size => 1;
   for t_interrupt use
     (IRQ_DISABLED => 0,
      IRQ_ENABLED  => 1);

   type t_interrupts is array (interrupt range <>) of t_interrupt
      with pack;

   --
   -- ISER0
   --


   type t_NVIC_ISER0 is record
      irq : t_interrupts(0..31);
   end record
      with pack, size => 32, volatile_full_access;

   --
   -- ISER1
   --

   type t_NVIC_ISER1 is record
      irq : t_interrupts(32..63);
   end record
      with pack, size => 32, volatile_full_access;

   --
   -- ISER2
   --

   type t_NVIC_ISER2 is record
      irq : t_interrupts(64..80);
   end record
      with size => 32, volatile_full_access;

   for t_NVIC_ISER2 use record
      irq at 0 range 0 .. 16;
   end record;

   ----------------------------------------------
   -- Interrupt priority registers (NVIC_IPRx) --
   ----------------------------------------------

   -- NVIC_IPR0-IPR80 registers provide an 8-bit priority field for each
   -- interrupt.

   type t_IPR is record
      reserved : uint4;
      priority : uint4;
   end record
      with pack, size => 8, volatile_full_access;

   type t_IPRs is array (interrupt) of t_IPR
      with pack, size => 8 * 81;

   ----------
   -- NVIC --
   ----------

   type t_NVIC is record
      ISER0 : t_NVIC_ISER0;
      ISER1 : t_NVIC_ISER1;
      ISER2 : t_NVIC_ISER2;
      IPR   : t_IPRs;
   end record;

   for t_NVIC use record
      ISER0 at 16#00# range 0 .. 31;
      ISER1 at 16#04# range 0 .. 31;
      ISER2 at 16#08# range 0 .. 31;
      IPR   at 16#300# range 0 .. (8*81)-1;
   end record;

   procedure set_priority (irq : interrupt; priority : uint4);
   procedure enable_irq (irq : interrupt);

end stm32f4.nvic;
