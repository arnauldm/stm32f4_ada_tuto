static  unsigned uwTick;
void NMI_Handler(void)
{}

void HardFault_Handler(void)
{
    /* Go to infinite loop when Hard Fault exception occurs */
      while (1)
	  {}
}

void MemManage_Handler(void)
{
    /* Go to infinite loop when Memory Manage exception occurs */
      while (1)
	  {}
}
void BusFault_Handler(void)
{
    /* Go to infinite loop when Bus Fault exception occurs */
      while (1)
	  {}
}
void UsageFault_Handler(void)
{
    /* Go to infinite loop when Usage Fault exception occurs */
      while (1)
	  {}
}

void DebugMon_Handler(void)
{}

void SVC_Handler(void)
{}

void PendSV_Handler(void)
{}

void SysTick_Handler(void)
{
    uwTick++;
}

//void EXTI0_IRQHandler(void)
//{
//    HAL_GPIO_EXTI_IRQHandler(USER_BUTTON_PIN);
//}

