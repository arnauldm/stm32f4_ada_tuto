with ada.unchecked_conversion;
with stm32f4.sdio;

package stm32f4.sd is

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
      AKE_SEQ_ERROR     : bit; -- Sequence of the authentication process error
      reserved_4        : bit;
      APP_CMD           : boolean; -- The card will expect ACMD
      reserved_6_7      : uint2;
      READY_FOR_DATA    : boolean;
      CURRENT_STATE     : t_card_state;
      ERASE_RESET       : bit;
      CARD_ECC_DISABLED : bit;
      WP_ERASE_SKIP     : bit;
      CSD_OVERWRITE     : bit; 
      reserved_17_18    : uint2;
      ERROR             : bit; -- General/unknown error
      CC_ERROR          : bit; -- Internal card controller error
      CARD_ECC_FAILED   : bit; -- ECC failed to correct the data
      ILLEGAL_COMMAND   : bit; -- Illegal command
      COM_CRC_ERROR     : bit; -- CRC check of the previous command failed
      LOCK_UNLOCK_FAILED   : bit; -- Sequence or password error in lock/unlock
                                  -- command
      CARD_IS_LOCKED    : bit; -- Card locked by the host
      WP_VIOLATION      : bit; -- Write protection violation
      ERASE_PARAM       : bit; -- Invalid selection of write-blocks for erase
      ERASE_SEQ_ERROR   : bit; -- Error in the sequence of erase command
      BLOCK_LEN_ERROR   : bit; -- Block length is not allowed / transferred
                               -- bytes does not match the block length
      ADDRESS_ERROR     : bit; -- Misaligned address (did not match block length)
      OUT_OF_RANGE      : bit; -- Out of range command's argument 
   end record
      with pack, size => 32;

   function to_card_status is new ada.unchecked_conversion
     (sdio.t_short_response, t_card_status);

   -----------------------------------------
   -- Operation conditions register (OCR) --
   -----------------------------------------

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
      UHS_II_status  : bit := 0;
      CCS            : bit := 0; -- 0: SDSC, 1: SDHC or SDXC
      power_up       : bit := 0; -- set if the card power up procedure has been
                                 -- finished
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
     (sdio.t_short_response, t_OCR);

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
     (sdio.t_long_response, t_CID);

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
      ID                : short; -- RCA
   end record
      with pack, size => 32;

   function to_rca is new ada.unchecked_conversion
     (sdio.t_short_response, t_RCA);

end stm32f4.sd;
