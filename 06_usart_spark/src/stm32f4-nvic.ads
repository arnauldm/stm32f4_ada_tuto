-- Nested vectored interrupt controller (NVIC)
-- (see STM32F4xxx Cortex-M4 Programming Manual, p. 194-205)

package stm32f4.nvic
   with spark_mode => on
is

   -- Up to 81 interrupts (see Cortex-M4 prog. manual, p. 194)
   type t_irq is new integer range 0 .. 80;

   -- /!\ pragma Attach_Handler directive takes in parameter
   --     Ada.Interrupts.Names.Interrupt_ID.


   ----------------
   -- Interrupts --
   ----------------
   -- (see RM0090, p. 374)

   EXTI_Line_0    : constant t_irq := 6;
   EXTI_Line_1    : constant t_irq := 7;
   EXTI_Line_2    : constant t_irq := 8;
   EXTI_Line_3    : constant t_irq := 9;
   EXTI_Line_4    : constant t_irq := 10;

   -------------------------------------------------
   -- Interrupt set-enable registers (NVIC_ISERx) --
   -------------------------------------------------

   type t_irq_state is (IRQ_DISABLED, IRQ_ENABLED) with size => 1;
   for t_irq_state use
     (IRQ_DISABLED => 0,
      IRQ_ENABLED  => 1);

   type t_irq_states is array (t_irq range <>) of t_irq_state
      with pack;

   subtype iser0_range is t_irq range 0 .. 31;
   subtype iser1_range is t_irq range 32 .. 63;
   subtype iser2_range is t_irq range 64 .. 80;

   -- ISER0
   type t_NVIC_ISER0 is record
      irq : t_irq_states (iser0_range);
   end record
      with pack, size => 32, volatile_full_access;

   -- ISER1
   type t_NVIC_ISER1 is record
      irq : t_irq_states (iser1_range);
   end record
      with pack, size => 32, volatile_full_access;

   -- ISER2
   type t_NVIC_ISER2 is record
      irq : t_irq_states (iser2_range);
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

   type t_IPRs is array (t_irq) of t_IPR
      with pack, size => 8 * 81;

   ----------
   -- NVIC --
   ----------

   type t_NVIC is record
      ISER0 : t_NVIC_ISER0;
      ISER1 : t_NVIC_ISER1;
      ISER2 : t_NVIC_ISER2;
      IPR   : t_IPRs;
   end record
      with volatile;

   for t_NVIC use record
      ISER0 at 16#00# range 0 .. 31;
      ISER1 at 16#04# range 0 .. 31;
      ISER2 at 16#08# range 0 .. 31;
      IPR   at 16#300# range 0 .. (8*81)-1;
   end record;

   procedure set_priority (irq : t_irq; priority : uint4);
   procedure enable_irq (irq : t_irq);

end stm32f4.nvic;
