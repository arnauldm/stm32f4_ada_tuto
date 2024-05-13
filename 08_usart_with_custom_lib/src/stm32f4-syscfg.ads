--
-- Ref. : RM0090, p. 373-389
--
package stm32f4.syscfg is

   -- 
   -- SYSCFG external interrupt configuration registers
   -- 

   type t_exti_port is
     (GPIOA, GPIOB, GPIOC, GPIOD, GPIOE, GPIOF, GPIOG, GPIOH, GPIOI)
      with size => 4;

   for t_exti_port use
     (GPIOA => 0, GPIOB => 1, GPIOC => 2, GPIOD => 3,
      GPIOE => 4, GPIOF => 5, GPIOG => 6, GPIOH => 7,
      GPIOI => 8);

   type t_SYSCFG_EXTICR1 is record
      EXTI0    : t_exti_port;
      EXTI1    : t_exti_port;
      EXTI2    : t_exti_port;
      EXTI3    : t_exti_port;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   type t_SYSCFG_EXTICR2 is record
      EXTI4    : t_exti_port;
      EXTI5    : t_exti_port;
      EXTI6    : t_exti_port;
      EXTI7    : t_exti_port;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   type t_SYSCFG_EXTICR3 is record
      EXTI8    : t_exti_port;
      EXTI9    : t_exti_port;
      EXTI10   : t_exti_port;
      EXTI11   : t_exti_port;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   type t_SYSCFG_EXTICR4 is record
      EXTI12   : t_exti_port;
      EXTI13   : t_exti_port;
      EXTI14   : t_exti_port;
      EXTI15   : t_exti_port;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   type t_SYSCFG_periph is record
      EXTICR1 : t_SYSCFG_EXTICR1;
      EXTICR2 : t_SYSCFG_EXTICR2;
      EXTICR3 : t_SYSCFG_EXTICR3;
      EXTICR4 : t_SYSCFG_EXTICR4;
   end record;

   for t_SYSCFG_periph use record
      EXTICR1 at 16#08# range 0 .. 31;
      EXTICR2 at 16#0C# range 0 .. 31;
      EXTICR3 at 16#10# range 0 .. 31;
      EXTICR4 at 16#14# range 0 .. 31;
   end record;

end stm32f4.syscfg;

