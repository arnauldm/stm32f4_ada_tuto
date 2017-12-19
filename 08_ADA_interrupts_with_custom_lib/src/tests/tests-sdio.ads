
package tests.sdio is

   procedure read_with_dma
     (lba   : in stm32f4.word;
      size  : in natural);

   procedure write_with_dma
     (lba   : in stm32f4.word;
      size  : in natural);

end tests.sdio;
