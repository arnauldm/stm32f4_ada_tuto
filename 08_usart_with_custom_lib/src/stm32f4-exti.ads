
--
-- External interrupt/event controller (EXTI) registers
-- Ref. : RM0090, p. 373-389
--

package stm32f4.exti is

   subtype EXTI_line_index is natural range 0 .. 22;

   --
   -- Interrupt mask register (EXTI_IMR)
   --

   type t_mask is (MASKED, NOT_MASKED) with size => 1;
   for t_mask use
     (MASKED      => 0,
      NOT_MASKED  => 1);

   type t_masks is array (EXTI_line_index) of t_mask
      with pack, size => 23;

   type t_EXTI_IMR is record
      line : t_masks;
   end record
      with size => 32, volatile_full_access;

   for t_EXTI_IMR use record
      line at 0 range 0 .. 22;
   end record;

   --
   -- Event mask register (EXTI_EMR)
   --

   type t_EXTI_EMR is record
      line : t_masks;
   end record
      with size => 32, volatile_full_access;

   for t_EXTI_EMR use record
      line at 0 range 0 .. 22;
   end record;

   --
   -- Rising trigger selection register (EXTI_RTSR) 
   --

   type t_trigger is (TRIGGER_DISABLED, TRIGGER_ENABLED) with size => 1;
   for t_trigger use
     (TRIGGER_DISABLED => 0,
      TRIGGER_ENABLED  => 1);

   type t_triggers is array (EXTI_line_index) of t_trigger
      with pack, size => 23;

   type t_EXTI_RTSR is record
      line : t_triggers;
   end record
      with size => 32, volatile_full_access;

   for t_EXTI_RTSR use record
      line at 0 range 0 .. 22;
   end record;

   --
   -- Falling trigger selection register (EXTI_RTSR) 
   --

   type t_EXTI_FTSR is record
      line : t_triggers;
   end record
      with size => 32, volatile_full_access;

   for t_EXTI_FTSR use record
      line at 0 range 0 .. 22;
   end record;

   --
   -- Pending register (EXTI_PR)
   --

   type t_request is (NO_REQUEST, PENDING_REQUEST) with size => 1;
   for t_request use
     (NO_REQUEST        => 0,
      PENDING_REQUEST   => 1);

   -- Set the bit to '1' to clear it!
   CLEAR_REQUEST : constant t_request := PENDING_REQUEST;

   type t_requests is array (EXTI_line_index) of t_request
      with pack, size => 23;

   type t_EXTI_PR is record
      line : t_requests;
   end record
      with size => 32, volatile_full_access;

   for t_EXTI_PR use record
      line at 0 range 0 .. 22;
   end record;

   --
   -- EXTI peripheral
   --

   type t_EXTI_periph is record
      IMR   : t_EXTI_IMR;
      EMR   : t_EXTI_EMR;
      RTSR  : t_EXTI_RTSR;
      FTSR  : t_EXTI_FTSR;
      PR    : t_EXTI_PR;
   end record;

   for t_EXTI_periph use record
      IMR   at 16#00# range 0 .. 31;
      EMR   at 16#04# range 0 .. 31;
      RTSR  at 16#08# range 0 .. 31;
      FTSR  at 16#0C# range 0 .. 31;
      PR    at 16#14# range 0 .. 31;
   end record;

end stm32f4.exti;

