pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__main.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__main.adb");
pragma Suppress (Overflow_Check);

package body ada_main is

   E005 : Short_Integer; pragma Import (Ada, E005, "ada__real_time_E");
   E127 : Short_Integer; pragma Import (Ada, E127, "system__tasking__protected_objects_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "system__tasking__protected_objects__multiprocessors_E");
   E138 : Short_Integer; pragma Import (Ada, E138, "system__tasking__restricted__stages_E");
   E157 : Short_Integer; pragma Import (Ada, E157, "cortex_m__cache_E");
   E180 : Short_Integer; pragma Import (Ada, E180, "cs43l22_E");
   E077 : Short_Integer; pragma Import (Ada, E077, "lis3dsh_E");
   E182 : Short_Integer; pragma Import (Ada, E182, "lis3dsh__spi_E");
   E083 : Short_Integer; pragma Import (Ada, E083, "ravenscar_time_E");
   E159 : Short_Integer; pragma Import (Ada, E159, "sdmmc_init_E");
   E093 : Short_Integer; pragma Import (Ada, E093, "stm32__adc_E");
   E099 : Short_Integer; pragma Import (Ada, E099, "stm32__dac_E");
   E131 : Short_Integer; pragma Import (Ada, E131, "stm32__dma__interrupts_E");
   E112 : Short_Integer; pragma Import (Ada, E112, "stm32__exti_E");
   E149 : Short_Integer; pragma Import (Ada, E149, "stm32__power_control_E");
   E146 : Short_Integer; pragma Import (Ada, E146, "stm32__rtc_E");
   E169 : Short_Integer; pragma Import (Ada, E169, "stm32__spi_E");
   E171 : Short_Integer; pragma Import (Ada, E171, "stm32__spi__dma_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "stm32__gpio_E");
   E118 : Short_Integer; pragma Import (Ada, E118, "stm32__i2c_E");
   E123 : Short_Integer; pragma Import (Ada, E123, "stm32__i2c__dma_E");
   E142 : Short_Integer; pragma Import (Ada, E142, "stm32__i2s_E");
   E165 : Short_Integer; pragma Import (Ada, E165, "stm32__sdmmc_interrupt_E");
   E154 : Short_Integer; pragma Import (Ada, E154, "stm32__sdmmc_E");
   E110 : Short_Integer; pragma Import (Ada, E110, "stm32__syscfg_E");
   E175 : Short_Integer; pragma Import (Ada, E175, "stm32__usarts_E");
   E088 : Short_Integer; pragma Import (Ada, E088, "stm32__device_E");
   E086 : Short_Integer; pragma Import (Ada, E086, "stm32__setup_E");
   E074 : Short_Integer; pragma Import (Ada, E074, "stm32__board_E");
   E070 : Short_Integer; pragma Import (Ada, E070, "serial_E");
   E068 : Short_Integer; pragma Import (Ada, E068, "last_chance_handler_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);


   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");

      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");

      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      Main_Priority := 0;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;


      Ada.Real_Time'Elab_Body;
      E005 := E005 + 1;
      System.Tasking.Protected_Objects'Elab_Body;
      E127 := E127 + 1;
      System.Tasking.Protected_Objects.Multiprocessors'Elab_Body;
      E129 := E129 + 1;
      System.Tasking.Restricted.Stages'Elab_Body;
      E138 := E138 + 1;
      E157 := E157 + 1;
      E180 := E180 + 1;
      E077 := E077 + 1;
      E182 := E182 + 1;
      Ravenscar_Time'Elab_Body;
      E083 := E083 + 1;
      E159 := E159 + 1;
      STM32.ADC'ELAB_SPEC;
      E093 := E093 + 1;
      E099 := E099 + 1;
      E131 := E131 + 1;
      E112 := E112 + 1;
      E149 := E149 + 1;
      E146 := E146 + 1;
      E169 := E169 + 1;
      E171 := E171 + 1;
      E165 := E165 + 1;
      E105 := E105 + 1;
      STM32.DEVICE'ELAB_SPEC;
      E088 := E088 + 1;
      E118 := E118 + 1;
      E123 := E123 + 1;
      E142 := E142 + 1;
      E154 := E154 + 1;
      E110 := E110 + 1;
      E175 := E175 + 1;
      E086 := E086 + 1;
      STM32.BOARD'ELAB_SPEC;
      E074 := E074 + 1;
      E070 := E070 + 1;
      E068 := E068 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_main");

   procedure main is
      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      adainit;
      Ada_Main_Program;
   end;

--  BEGIN Object file/option list
   --   /tmp/stm32f4_ada_tuto/06_USART/build/serial.o
   --   /tmp/stm32f4_ada_tuto/06_USART/build/last_chance_handler.o
   --   /tmp/stm32f4_ada_tuto/06_USART/build/main.o
   --   -L/tmp/stm32f4_ada_tuto/06_USART/build/
   --   -L/tmp/stm32f4_ada_tuto/06_USART/build/
   --   -L/tmp/stm32f4_ada_tuto/Ada_Drivers_Library/boards/stm32f407_discovery/obj/sfp_lib_Debug/
   --   -L/home/arnauld/local/gnat_arm_elf_12.2.1_9be2ca0e/arm-eabi/lib/gnat/light-tasking-stm32f4/adalib/
   --   -static
   --   -lgnarl
   --   -lgnat
--  END Object file/option list   

end ada_main;
