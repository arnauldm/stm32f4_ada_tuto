with ada.interrupts.names;
with interfaces.STM32.RCC;
with interfaces.STM32.SYSCFG;
with interfaces.STM32.GPIO;
with system.STM32;

with registers;

package body blue_button is

   procedure initialize is
   begin
      -- Enable GPIOA periph clock
      interfaces.STM32.RCC.RCC_Periph.AHB1ENR.GPIOAEN := 1;

      -- Set GPIOA pin to input mode
      interfaces.STM32.GPIO.GPIOA_Periph.MODER.arr (user_button)
         := System.STM32.Mode_IN;

      -- Push-pull mode
      interfaces.STM32.GPIO.GPIOA_Periph.OTYPER.OT.arr (user_button)
         := System.STM32.Push_Pull;

      -- Pull-down
      interfaces.STM32.GPIO.GPIOA_Periph.PUPDR.arr (user_button)
         := System.STM32.Pull_Down;

      -- High speed
      interfaces.STM32.GPIO.GPIOA_Periph.OSPEEDR.arr (user_button)
         := System.STM32.Speed_100MHz;

      -- The system configuration controller manages the external interrupt
      -- line connection to the GPIOs (cf. STM32F4xx RM0090 Reference Manual).
      -- EXTICR1 is an array of 4 external interrupts (from EXTI0 to EXTI3):
      --    - index 0 selects EXTI0
      --    - the value 2#0000#, on 4 bits, selects GPIO port A.
      interfaces.STM32.SYSCFG.SYSCFG_Periph.EXTICR1.EXTI.arr (0) := 2#0000#;

      -- Unmask interrupts
      registers.EXTI.IMR (0) := 1;

      -- Falling edge trigerring (when button is released)
      registers.EXTI.RTSR (0) := 0;
      registers.EXTI.FTSR (0) := 1;

   end initialize;


   procedure has_been_pressed (ret : out boolean) is
   begin
      ret      := pressed;
      pressed  := false;
   end has_been_pressed;


   function has_been_pressed return boolean
   is
      ret : boolean;
   begin
      has_been_pressed (ret);
      return ret;
   end has_been_pressed;


   -----------------------------------------
   -- Interrupt handler MUST be protected --
   -----------------------------------------

   protected button_handler
   is

      procedure handle_interrupt
         with attach_handler => ada.interrupts.names.EXTI0_Interrupt;

   end button_handler;
   pragma Unreferenced (button_handler);


   protected body button_handler is

      procedure handle_interrupt is
      begin
         registers.EXTI.PR (0)   := 1; --  Clear interrupt
         pressed  := true;
      end handle_interrupt;

   end button_handler;


end blue_button;
