with system; use system;

package stm32f4.layout
   with spark_mode => on
is

   --------------------
   -- BASE addresses --
   --------------------

   NVIC_BASE   : constant address := system'to_address (16#E000_E100#);

   USART2_BASE : constant address := system'to_address (16#4000_4400#); -- APB1
   USART3_BASE : constant address := system'to_address (16#4000_4800#); -- APB1
   UART4_BASE  : constant address := system'to_address (16#4000_4C00#); -- APB1
   UART5_BASE  : constant address := system'to_address (16#4000_5000#); -- APB1

   USART1_BASE : constant address := system'to_address (16#4001_1000#); -- APB2
   USART6_BASE : constant address := system'to_address (16#4001_1400#); -- APB2

   SDIO_BASE   : constant address := system'to_address (16#4001_2C00#); -- APB2

   SYSCFG_BASE : constant address := system'to_address (16#4001_3800#); -- APB2

   EXTI_BASE   : constant address := system'to_address (16#4001_3C00#); -- APB2

   GPIOA_BASE  : constant address := system'to_address (16#4002_0000#); -- AHB1
   GPIOB_BASE  : constant address := system'to_address (16#4002_0400#); -- AHB1
   GPIOC_BASE  : constant address := system'to_address (16#4002_0800#); -- AHB1
   GPIOD_BASE  : constant address := system'to_address (16#4002_0C00#); -- AHB1
   GPIOE_BASE  : constant address := system'to_address (16#4002_1000#); -- AHB1

   RCC_BASE    : constant address := system'to_address (16#4002_3800#); -- AHB1

end stm32f4.layout;
