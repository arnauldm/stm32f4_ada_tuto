with ada.unchecked_conversion;

--
-- SD Memory Card 
--

package stm32f4.sdio.sd_card is

   -----------------
   -- SD commands --
   -----------------

   -- Ref.: 
   --  . SD Specifications, Part 1 Physical Layer Simplified Specification,
   --    version 4.10, 2013
   --  . Simplified SDIO card spec, version 3.0, 2011

   CMD0_GO_IDLE_STATE         : constant sdio.t_cmd_index := 0;
   CMD1_SEND_OP_COND          : constant sdio.t_cmd_index := 1;
   CMD2_ALL_SEND_CID          : constant sdio.t_cmd_index := 2;
   CMD3_SEND_RELATIVE_ADDR    : constant sdio.t_cmd_index := 3;
   CMD5_IO_SEND_OP_COND       : constant sdio.t_cmd_index := 5;
   ACMD6_SET_BUS_WIDTH        : constant sdio.t_cmd_index := 6;
   CMD7_SELECT_CARD           : constant sdio.t_cmd_index := 7;
   CMD8_SEND_IF_COND          : constant sdio.t_cmd_index := 8;
   CMD9_SEND_CSD              : constant sdio.t_cmd_index := 9;
   CMD12_STOP_TRANSMISSION    : constant sdio.t_cmd_index := 12;
   CMD13_SEND_STATUS          : constant sdio.t_cmd_index := 13;
   CMD15_GO_INACTIVE_STATE    : constant sdio.t_cmd_index := 15;
   CMD16_SET_BLOCKLEN         : constant sdio.t_cmd_index := 16;
   CMD17_READ_SINGLE_BLOCK    : constant sdio.t_cmd_index := 17;
   CMD18_READ_MULTIPLE_BLOCK  : constant sdio.t_cmd_index := 18;
   CMD24_WRITE_BLOCK          : constant sdio.t_cmd_index := 24;
   CMD25_WRITE_BLOCKS         : constant sdio.t_cmd_index := 25;
   ACMD41_SD_APP_OP_COND      : constant sdio.t_cmd_index := 41;
   ACMD51_SEND_SCR            : constant sdio.t_cmd_index := 51;
   CMD52_IO_RW_DIRECT         : constant sdio.t_cmd_index := 52;
   CMD55_APP_CMD              : constant sdio.t_cmd_index := 55;

   ------------------
   -- SD responses --
   ------------------

   subtype t_short_response is sdio.t_SDIO_RESPx;
   
   type t_long_response is record
      RESP4 : sdio.t_SDIO_RESPx;
      RESP3 : sdio.t_SDIO_RESPx;
      RESP2 : sdio.t_SDIO_RESPx;
      RESP1 : sdio.t_SDIO_RESPx;
   end record
      with pack;

   --------------------
   -- SD card status --
   --------------------

   -- The SD card status is transmitted by SDIO in the short response
   -- (periphs.SDIO_CARD.RESP1 register)
   -- Reference :
   --   SD Specifications Part 1 Physical Layer Simplified Specification,
   --   Version 4.10, January 22, 2013, p. 99-102

   type t_card_state is
     (CARD_STATE_IDLE,
      CARD_STATE_READY,
      CARD_STATE_IDENT,
      CARD_STATE_STBY,
      CARD_STATE_TRAN,
      CARD_STATE_DATA,
      CARD_STATE_RCV,
      CARD_STATE_PRG,
      CARD_STATE_DIS)
      with size => 4;

   for t_card_state use
     (CARD_STATE_IDLE   => 0,
      CARD_STATE_READY  => 1,
      CARD_STATE_IDENT  => 2,
      CARD_STATE_STBY   => 3,
      CARD_STATE_TRAN   => 4,
      CARD_STATE_DATA   => 5,
      CARD_STATE_RCV    => 6,
      CARD_STATE_PRG    => 7,
      CARD_STATE_DIS    => 8);

   type t_card_status is record
      reserved_0_2      : uint3;
      AKE_SEQ_ERROR     : boolean; -- Sequence of the authentication process error
      reserved_4        : bit;
      APP_CMD           : boolean; -- The card will expect ACMD
      reserved_6_7      : uint2;
      READY_FOR_DATA    : boolean;
      CURRENT_STATE     : t_card_state;
      ERASE_RESET       : bit;
      CARD_ECC_DISABLED : bit;
      WP_ERASE_SKIP     : boolean;
      CSD_OVERWRITE     : boolean; 
      reserved_17_18    : uint2;
      ERROR             : boolean; -- General/unknown error
      CC_ERROR          : boolean; -- Internal card controller error
      CARD_ECC_FAILED   : boolean; -- ECC failed to correct the data
      ILLEGAL_COMMAND   : boolean; -- Illegal command
      COM_CRC_ERROR     : boolean; -- CRC check of the previous command failed
      LOCK_UNLOCK_FAILED : boolean; -- Sequence or password error in lock/unlock
                                    -- command
      CARD_IS_LOCKED    : boolean; -- Card locked by the host
      WP_VIOLATION      : boolean; -- Write protection violation
      ERASE_PARAM       : boolean; -- Invalid selection of write-blocks for erase
      ERASE_SEQ_ERROR   : boolean; -- Error in the sequence of erase command
      BLOCK_LEN_ERROR   : boolean; -- Block length is not allowed / transferred
                                   -- bytes does not match the block length
      ADDRESS_ERROR     : boolean; -- Misaligned address (did not match block length)
      OUT_OF_RANGE      : boolean; -- Out of range command's argument 
   end record
      with pack, size => 32;

   function to_card_status is new ada.unchecked_conversion
     (t_short_response, t_card_status);

   -----------------------------------------
   -- Operation conditions register (OCR) --
   -----------------------------------------

   -- Card Capacity Status
   type t_CCS is (SDSC, SDHC_or_SDXC) with size => 1;
   for t_CCS use
     (SDSC           => 0,
      SDHC_or_SDXC   => 1);

   type t_OCR is record
      reserved_0_7   : byte      := 0;
      reserved_8_14  : uint7     := 0;
      VDD_2_DOT_8    : boolean   := false;
      VDD_2_DOT_9    : boolean   := false;
      VDD_3_DOT_0    : boolean   := false;
      VDD_3_DOT_1    : boolean   := false;
      VDD_3_DOT_2    : boolean   := false;
      VDD_3_DOT_3    : boolean   := false;
      VDD_3_DOT_4    : boolean   := false;
      VDD_3_DOT_5    : boolean   := false;
      VDD_3_DOT_6    : boolean   := false;
      VDD_1_DOT_8    : boolean   := false;
      reserved_25_28 : uint4     := 0;
      UHS_II_status  : bit       := 0;
      CCS            : t_CCS     := SDSC;
      power_up       : bit       := 0;
   end record
      with size => 32;

   for t_OCR use record
      reserved_0_7   at 0 range 0 .. 7;
      reserved_8_14  at 0 range 8 .. 14;
      VDD_2_DOT_8    at 0 range 15 .. 15;
      VDD_2_DOT_9    at 0 range 16 .. 16;
      VDD_3_DOT_0    at 0 range 17 .. 17;
      VDD_3_DOT_1    at 0 range 18 .. 18;
      VDD_3_DOT_2    at 0 range 19 .. 19;
      VDD_3_DOT_3    at 0 range 20 .. 20;
      VDD_3_DOT_4    at 0 range 21 .. 21;
      VDD_3_DOT_5    at 0 range 22 .. 22;
      VDD_3_DOT_6    at 0 range 23 .. 23;
      VDD_1_DOT_8    at 0 range 24 .. 24;
      reserved_25_28 at 0 range 25 .. 28;
      UHS_II_status  at 0 range 29 .. 29;
      CCS            at 0 range 30 .. 30;
      power_up       at 0 range 31 .. 31;
   end record;

   function to_ocr is new ada.unchecked_conversion
     (t_short_response, t_OCR);

   ----------------------------------------
   -- Card IDentification (CID) register --
   ----------------------------------------

   -- The SD card status is transmitted by SDIO in the long response

   subtype t_product_name is string (1 .. 5);

   subtype t_oem_id is string (1 .. 2);

   type t_CID is record
      unused         : bit := 1; -- Not used, always 1
      CRC7           : uint7;    -- CRC7 checksum
      MDT            : uint12;   -- Manufacturing date
      reserved_20_23 : uint4;
      PSN            : word;     -- Product serial number
      PRV            : byte;     -- Product revision
      PNM            : t_product_name; 
      OID            : t_oem_id; -- card OEM id
      MID            : byte;     -- Manufacturer ID
   end record
      with size => 128;

   for t_CID use record
      unused         at 0 range 0 .. 0;
      CRC7           at 0 range 1 .. 7;
      MDT            at 0 range 8 .. 19;
      reserved_20_23 at 0 range 20 .. 23;
      PSN            at 0 range 24 .. 55;
      PRV            at 0 range 56 .. 63;
      PNM            at 0 range 64 .. 103;
      OID            at 0 range 104 .. 119;
      MID            at 0 range 120 .. 127;
   end record;

   function to_cid is new ada.unchecked_conversion
     (t_long_response, t_CID);

   ---------------------------------
   -- Relative Card Address (RCA) --
   ---------------------------------

   type t_RCA is record
      reserved_0_2      : uint3;
      AKE_SEQ_ERROR     : bit; -- Sequence of the authentication process error
      reserved_4        : bit;
      APP_CMD           : boolean; -- The card will expect ACMD
      reserved_6_7      : uint2;
      READY_FOR_DATA    : boolean;
      CURRENT_STATE     : t_card_state;
      ERROR             : bit; -- General/unknown error
      ILLEGAL_COMMAND   : bit; -- Illegal command
      COM_CRC_ERROR     : bit; -- CRC check of the previous command failed
      RCA               : short;
   end record
      with pack, size => 32;

   function to_rca is new ada.unchecked_conversion
     (t_short_response, t_RCA);

   ------------------------------------------
   -- SD CARD Configuration Register (SCR) --
   ------------------------------------------

   type t_SCR is record
      reserved_0_31  : word;
      CMD_SUPPORT    : uint4;
      reserved_36_41 : uint6;
      SD_SPEC4       : bit;   -- Spec. Version 4.00 or higher
      EX_SECURITY    : uint4; -- Extended security support
      SD_SPEC3       : bit;   -- Spec. Version 3.00 or higher
      SD_BUS_WIDTHS  : uint4; -- DAT Bus widths supported
      SD_SECURITY    : uint3; -- CPRM Security Support
      DATA_STAT_AFTER_ERASE   : bit;
      SD_SPEC        : uint4; -- Spec. Version 1.0 to 2.00 or higher
      SCR_STRUCTURE  : uint4;
   end record
      with pack, size => 64;

   ---------------------------------------
   -- Card Specific Data register (CSD) --
   ---------------------------------------

   type t_CSD_version_2 is record
      CRC                  : uint7;
      TMP_WRITE_PROTECT    : boolean;
         -- Temporarily protects the entire card content from being overwritten
         -- or erased. 
      PERM_WRITE_PROTECT   : boolean;
      COPY                 : bit;
         -- Defines whether the contents is original (0) or has been copied (1)
      WRITE_BL_PARTIAL     : boolean;
         -- Fixed to 0, which indicates only unit of block access is allowed
      WRITE_BL_LEN         : uint4;
         -- Fixed to 512 bytes
      R2W_FACTOR           : uint3;
         -- Fixed to 4 multiples
      C_SIZE               : uint22;
         -- User data area capacity in the SD memory card (not include the
         -- protected area) : (C_SIZE+1) * 512KByte
      DSR_IMP              : bit;
         -- Driver stage register (DSR)
      CCC                  : uint12;
         -- Defines which command classes are supported by this card
      TRAN_SPEED           : byte;
         -- Maximum data transfer rate per one data line. Values:
         --  . 0Bh (100Mbit/sec) in SDR50 and DDR50 mode
         --  . 2Bh (200Mbit/sec) in SDR104 mode.
         --  . Reset to 32h when CMD0 is received
         --  . UHS-II mode is not related to this field.
      CSD_STRUCTURE        : uint2;
   end record
      with size => 128;

   for t_CSD_version_2 use record
      CRC                  at 0 range 1 .. 7;
      TMP_WRITE_PROTECT    at 0 range 12 .. 12;
      PERM_WRITE_PROTECT   at 0 range 13 .. 13;
      COPY                 at 0 range 14 .. 14;
      WRITE_BL_PARTIAL     at 0 range 21 .. 21;
      WRITE_BL_LEN         at 0 range 22 .. 25;
      R2W_FACTOR           at 0 range 26 .. 28;
      C_SIZE               at 0 range 48 .. 69;
      DSR_IMP              at 0 range 76 .. 76;
      CCC                  at 0 range 84 .. 95;
      TRAN_SPEED           at 0 range 96 .. 103;
      CSD_STRUCTURE        at 0 range 126 .. 127;
   end record;

   function to_csd is new ada.unchecked_conversion
     (t_long_response, t_CSD_version_2);

   ---------------
   -- Utilities --
   ---------------

   procedure initialize
     (success : out boolean);

   procedure send_command
     (cmd_index      : in  sdio.t_cmd_index;
      argument       : in  sdio.t_SDIO_ARG;
      response_type  : in  sdio.t_waitresp);

   procedure send_app_command
     (cmd55_arg      : in  sdio.t_SDIO_ARG;
      cmd_index      : in  sdio.t_cmd_index;
      cmd_arg        : in  sdio.t_SDIO_ARG;
      cmd_resp_type  : in  sdio.t_waitresp;
      success        : out boolean);

   function get_short_response return t_short_response;
   function get_long_response return t_long_response;

   -- R1 (normal response command)
   procedure check_R1
     (cmd_index      : in  sdio.t_cmd_index;
      sdio_status    : out sdio.t_SDIO_STA;
      card_status    : out t_card_status;
      success        : out boolean);

   -- R2 (CID, CSD register)
   procedure check_R2
     (cmd_index      : in  sdio.t_cmd_index;
      sdio_status    : out sdio.t_SDIO_STA;
      long_response  : out t_long_response;
      success        : out boolean);

   -- R3 (OCR register)
   procedure check_R3
     (cmd_index   : in  sdio.t_cmd_index;
      sdio_status : out sdio.t_SDIO_STA;
      ocr         : out t_OCR;
      success     : out boolean);

   -- R6 (Published RCA response)
   procedure check_R6
     (cmd_index   : in  sdio.t_cmd_index;
      sdio_status : out sdio.t_SDIO_STA;
      rca         : out t_RCA;
      success     : out boolean);

   -- R7 (Card interface condition)
   procedure check_R7
     (cmd_index   : in  sdio.t_cmd_index;
      sdio_status : out sdio.t_SDIO_STA;
      success     : out boolean);

   procedure get_card_status
     (card_status : out t_card_status;
      success     : out boolean);

   function card_status_error
     (card_status : t_card_status)
      return boolean;

   procedure display_card_status_error
     (card_status : t_card_status);

   procedure read_blocks_dma
     (bl_num   : in  word;       -- block number
      output   : out byte_array; -- output
      success  : out boolean);

   procedure write_blocks_dma
     (bl_num   : in  word;       -- block number
      input    : in  byte_array; -- output
      success  : out boolean);

end stm32f4.sdio.sd_card;
