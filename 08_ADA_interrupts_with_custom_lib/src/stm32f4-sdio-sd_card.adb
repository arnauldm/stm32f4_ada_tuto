with ada.real_time; use ada.real_time;
with system; use system;
with stm32f4.periphs;
with serial;

package body stm32f4.sdio.sd_card is

   DEBUG    : constant boolean := true;

   type t_sd_card is record
      ccs   : t_CCS;    -- Card Capacity Status
      ocr   : t_OCR;    -- Operating Condition Register
      cid   : t_CID;    -- Card IDentification register 

      -- Relative Card Address (RCA) formatted to fit in the SDIO_ARG
      -- register 
      id    : sdio.t_SDIO_ARG;
   end record;

   sd_card : t_sd_card;

   ----------------
   -- Initialize --
   ----------------

   procedure initialize is

      function to_sdio_arg is new ada.unchecked_conversion
        (t_OCR, sdio.t_SDIO_ARG);

      success     : boolean;
      sdio_status : sdio.t_SDIO_STA;

   begin

      --
      -- Low level settings 
      --

      -- Set up GPIO pins, SDIO clock and also set up interrupt handler
      sdio.initialize;

      -- DMA2 clock enable
      periphs.RCC.AHB1ENR.DMA2EN := 1;

      --
      -- Card identification process 
      --

      -- Go idle state (CMD0)
      serial.put_line ("GO_IDLE_STATE (CMD0)");
      send_command (CMD0, 0, sdio.NO_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      -- Initialize SD Memory Cards compliant to the Physical Layer
      -- Specification Version 2.00 or later (CMD8)
      --  Argument:
      --  - [31:12]: reserved, shall be set to '0'
      --  - [11:8]:  Supply voltage (VHS) 0x1 (range: 2.7-3.6V)
      --  - [7:0]:   Check Pattern (recommended 0xAA)
      serial.put_line ("SEND_IF_COND (CMD8)"); 
      send_command (CMD8, 16#1AA#, sdio.SHORT_RESPONSE, sdio_status, success);

      if not success then
         serial.put_line
           ("No SD memory card OR v1.x SD memory card OR voltage mismatch");
         goto bad_return;
      end if;

      if get_short_response /= 16#1AA# then
         serial.put_line ("Unusable card");
         goto bad_return;
      end if;

      -- Initialization Command (ACMD41)
      serial.put_line ("SD_APP_OP_COND (ACMD41)");

      for i in 1 .. 100 loop
         sd_card.ocr :=
           (VDD_3_DOT_3 => true, CCS => SDHC_or_SDXC, power_up => 0,
            others => <>);

         -- ACMD41 expect an R3 response : failed CRC and wrong RESPCMD must be
         -- ignored!
         send_app_command
           (0, ACMD41, to_sdio_arg (sd_card.ocr), sdio.SHORT_RESPONSE,
            sdio_status, success);

         sd_card.ocr := to_ocr (get_short_response);
         exit when sd_card.ocr.power_up = 1;
      end loop;

      if sd_card.ocr.power_up /= 1 then
         serial.put_line ("Unusable card");
         goto bad_return;
      end if;

      sd_card.ccs := sd_card.ocr.CCS;

      if sd_card.ccs = SDHC_or_SDXC then
         serial.put_line
           ("Ver2.00 or later High Capacity (SDHC) or Extended Capacity SD Memory Card (SDXC)");
      else
         serial.put_line
           ("Ver2.00 or later Standard Capacity SD Memory Card (SDSC)");
      end if;

      -- Asks any card to send the CID numbers on the CMD line (CMD2)
      serial.put_line ("ALL_SEND_CID (CMD2)"); 
      send_command (CMD2, 0, sdio.LONG_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;
         
      sd_card.cid := to_cid (get_long_response);

      -- Ask the card to publish a new relative RCA address (CMD3)
      serial.put_line ("SEND_RELATIVE_ADDR (CMD3)"); 
      send_command (CMD3, 0, sdio.SHORT_RESPONSE, sdio_status, success);

      declare
         function to_sdio_arg is new ada.unchecked_conversion
            (t_RCA, sdio.t_SDIO_ARG);
         rca : constant t_RCA := to_rca (get_short_response);
      begin
         sd_card.id := to_sdio_arg (rca) and 16#FFFF_0000#;
      end;

      if not success then
         goto bad_return;
      end if;

      -- Select the SD card
      serial.put_line ("SELECT_CARD (CMD7)"); 
      send_command (CMD7, sd_card.id, sdio.SHORT_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      -- Defines the data bus width (2#00# = 1 bit or 2#10# = 4 bits bus) to be
      -- used for data transfer.
      serial.put_line ("SET_BUS_WIDTH (ACMD6)"); 
      send_app_command
        (sd_card.id, ACMD6, 2#10#, sdio.SHORT_RESPONSE, sdio_status, success);
      
      if not success then
         goto bad_return;
      end if;

      -- Now use the card to nominal speed
      serial.put_line ("Change clock speed");
      delay until ada.real_time.clock + ada.real_time.microseconds (1);
      periphs.SDIO_CARD.CLKCR.CLKDIV   := 0;

   <<ok_return>>
      serial.put_line ("SD card initialized");
      return;

   <<bad_return>>
      serial.put_line ("SD card initialization failed!");
      return;

   end initialize;


   ---------------------------------
   -- Send command / Get response --
   ---------------------------------

   procedure send_command
     (cmd_index      : in  sdio.t_cmd_index;
      argument       : in  sdio.t_SDIO_ARG;
      response_type  : in  sdio.t_waitresp;
      status         : out sdio.t_SDIO_STA;
      success        : out boolean)
   is
      function to_mask is new ada.unchecked_conversion
        (word, sdio.t_SDIO_MASK);
      function to_word is new ada.unchecked_conversion
        (sdio.t_SDIO_RESPx, word);
      function to_word is new ada.unchecked_conversion
        (sdio.t_SDIO_RESPCMD, word);
      cmd : sdio.t_SDIO_CMD;
   begin

      cmd := periphs.SDIO_CARD.CMD;

      -- Clear status flags (cf. default value)
      periphs.SDIO_CARD.ICR  := (others => <>);

      -- Clear interrupts
      periphs.SDIO_CARD.MASK := to_mask (0);

      -- Set the command parameters
      periphs.SDIO_CARD.ARG   := argument;
      cmd.CMDINDEX            := cmd_index;
      cmd.WAITRESP            := response_type;
      cmd.CPSMEN              := 1;

      -- SDIO card host enabled to send a command
      periphs.SDIO_CARD.CMD   := cmd;

      -- Block till we get a response
      if response_type = sdio.NO_RESPONSE or
         response_type = sdio.NO_RESPONSE2 
      then
         loop
            exit when periphs.SDIO_CARD.STATUS.CMDSENT  or
                      periphs.SDIO_CARD.STATUS.CTIMEOUT;
         end loop;
      else
         loop
            exit when periphs.SDIO_CARD.STATUS.CMDREND  or
                      periphs.SDIO_CARD.STATUS.CCRCFAIL or
                      periphs.SDIO_CARD.STATUS.CTIMEOUT;
         end loop;
      end if;

      status := periphs.SDIO_CARD.STATUS;

      if DEBUG then
         serial.put_line
           ("RESPCMD: " & word'image (to_word (periphs.SDIO_CARD.RESPCMD)) &
            ", RESP1: " & word'image (to_word (periphs.SDIO_CARD.RESP1))   &
            ", RESP2: " & word'image (to_word (periphs.SDIO_CARD.RESP2))   &
            ", RESP3: " & word'image (to_word (periphs.SDIO_CARD.RESP3))   &
            ", RESP4: " & word'image (to_word (periphs.SDIO_CARD.RESP4)));
      end if;

      -- Timeout error
      if periphs.SDIO_CARD.STATUS.CTIMEOUT then
         serial.put_line ("timeout");
         success := false;
         return;
      end if;

      -- CRC fail
      if periphs.SDIO_CARD.STATUS.CCRCFAIL then
         if cmd_index = CMD1 or cmd_index = CMD5 then
            null;
         else
            serial.put_line ("CRC fail");
            success := false;
            return;
         end if;
      end if;

      success := true;
      
   end send_command;


   procedure send_app_command
     (cmd55_arg      : in  sdio.t_SDIO_ARG;
      cmd_index      : in  sdio.t_cmd_index;
      cmd_arg        : in  sdio.t_SDIO_ARG;
      response_type  : in  sdio.t_waitresp;
      status         : out sdio.t_SDIO_STA;
      success        : out boolean)
   is
      card_status : t_card_status;
   begin

      send_command
        (CMD55, cmd55_arg, sdio.SHORT_RESPONSE, status, success);

      if not success then
         serial.put_line ("error: CMD55");
         return;
      end if;

      card_status := to_card_status (get_short_response);
      if not card_status.APP_CMD or
         not card_status.READY_FOR_DATA 
      then
         serial.put_line ("unexpected error: CMD55");
         return;
      end if;

      send_command (cmd_index, cmd_arg, response_type, status, success);

   end send_app_command;


   function get_short_response return t_short_response
   is
   begin
      return periphs.SDIO_CARD.RESP1;
   end get_short_response;


   function get_long_response return t_long_response
   is
      response : t_long_response;
   begin
      response.RESP1 := periphs.SDIO_CARD.RESP1;
      response.RESP2 := periphs.SDIO_CARD.RESP2;
      response.RESP3 := periphs.SDIO_CARD.RESP3;
      response.RESP4 := periphs.SDIO_CARD.RESP4;
      return response;
   end get_long_response;


   --------------
   -- Transfer --
   --------------

   --procedure read_single_block;

end stm32f4.sdio.sd_card;
