--------------------------------------------------------------- {{{1 ----------
--: Copyright © 2026 … 2026 Martin Krischik «krischik@users.sourceforge.net»
------------------------------------------------------------------------------
--: This library is free software; you can redistribute it and/or modify it
--: under the terms of the GNU Library General Public License as published by
--: the Free Software Foundation; either version 2 of the License, or (at your
--: option) any later version.
--:
--: This library is distributed in the hope that it will be useful, but
--: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
--: or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public
--: License for more details.
--:
--: You should have received a copy of the GNU Library General Public License
--: along with this library; if not, write to the Free Software Foundation,
--: Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--------------------------------------------------------------- }}}1 ----------
pragma License (Modified_Gpl);
pragma Ada_2022;
pragma Extensions_Allowed (On);

with HAL.UART;
with RP.Device;
with RP.GPIO;
with RP.UART;

package body Pico.UART_IO with
   Spark_Mode => Off
is
   use type HAL.UART.UART_Status;
   use type HAL.UInt8;

   --  UART setup usually used with a Raspberry Pi Debug Probe, but can be used with any USB-to-Serial adapter
   --  connected to the UART pins.
   UART           : RP.UART.UART_Port renames RP.Device.UART_0;
   TX_Pin         : RP.GPIO.GPIO_Point renames Pico.GP0;   -- UART0 TX
   RX_Pin         : RP.GPIO.GPIO_Point renames Pico.GP1;   -- UART0 RX
   Is_Initialised : Boolean := False;

   protected Transmitter is
      procedure Transmit
         (Text_Bytes :        HAL.UART.UART_Data_8b;
          Status     :    out HAL.UART.UART_Status;
          Timeout    : in     Natural := 1_000);
   private
      UART : access RP.UART.UART_Port := UART_IO.UART'Access;
   end Transmitter;

   protected Receiver is
      procedure Receive
         (Text_Bytes :    out HAL.UART.UART_Data_8b;
          Status     :    out HAL.UART.UART_Status;
          Timeout    : in     Natural := 1_000);
   private
      --  UART setup usually used with a Raspberry Pi Debug Probe, but can be used with any USB-to-Serial adapter
      --  connected to the UART pins.
      UART : access RP.UART.UART_Port := UART_IO.UART'Access;
   end Receiver;

   protected body Transmitter is
      procedure Transmit
         (Text_Bytes :        HAL.UART.UART_Data_8b;
          Status     :    out HAL.UART.UART_Status;
          Timeout    : in     Natural := 1_000)
      is
      begin
         UART.Transmit (Text_Bytes, Status, Timeout);
      end Transmit;
   end Transmitter;

   protected body Receiver is
      procedure Receive
         (Text_Bytes :    out HAL.UART.UART_Data_8b;
          Status     :    out HAL.UART.UART_Status;
          Timeout    : in     Natural := 1_000)
      is
      begin
         UART.Receive (Text_Bytes, Status, Timeout);
      end Receive;
   end Receiver;

   procedure Initialise is
   begin
      if not Is_Initialised then
         --  if not already enabled, enable the peripheral clock for UART and Timer, as they are required for UART
         --  operation.
         if not RP.Clock.Enabled (RP.Clock.PERI) then
            RP.Clock.Enable (RP.Clock.PERI);
         end if;

         --  If not already enabled, enable the timer, as it is required for UART operation .
         if not RP.Device.Timer.Enabled then
            RP.Device.Timer.Enable;
         end if;

         --  Enable GPIO, as it is required for UART operation. Does nothing if already enabled.
         RP.GPIO.Enable;

         TX_Pin.Configure
            (Mode => RP.GPIO.Output,
             Pull => RP.GPIO.Pull_Up,
             Func => RP.GPIO.UART);
         RX_Pin.Configure
            (Mode => RP.GPIO.Input,
             Pull => RP.GPIO.Floating,
             Func => RP.GPIO.UART);
         UART.Configure
            (Config =>
                (Baud      => 115_200,
                 Word_Size => 8,
                 Parity    => False,
                 Stop_Bits => 1,
                 others    => <>));
         Is_Initialised := True;
      end if;
   end Initialise;

   procedure Put (Text : in Character) is
      Text_Bytes : constant HAL.UART.UART_Data_8b (1 .. 1) := [1 => Character'Pos (Text)];
      Status     : HAL.UART.UART_Status;
   begin
      Transmitter.Transmit (Text_Bytes, Status);

      if Status /= HAL.UART.Ok then
         raise IO_Error with "UART transmit failed with status " & Status'Image;
      end if;
   end Put;

   procedure Put (Text : in String) is
      Text_Bytes : HAL.UART.UART_Data_8b (1 .. Text'Length);
      Status     : HAL.UART.UART_Status;
   begin
      for I in Text'Range loop
         Text_Bytes (I) := Character'Pos (Text (I));
      end loop;

      Transmitter.Transmit (Text_Bytes, Status);

      if Status /= HAL.UART.Ok then
         raise IO_Error with "UART transmit failed with status " & Status'Image;
      end if;
   end Put;

   procedure Put_Line (Text : in String) is
   begin
      Put (Text & ASCII.LF);
   end Put_Line;

   function Get (Timeout : in  Duration := 60.0) return Character is
      Text_Bytes : HAL.UART.UART_Data_8b (1 .. 1);
      Status     : HAL.UART.UART_Status;
   begin
      Receiver.Receive (Text_Bytes, Status, Natural (Timeout * 1_000));

      if Status /= HAL.UART.Ok then
         raise IO_Error with "UART receive failed with status " & Status'Image;
      end if;

      return Character'Val (Text_Bytes (1));
   end Get;

   procedure Get (Text : out String; Timeout : in  Duration := 60.0) is
      Text_Bytes : HAL.UART.UART_Data_8b (1 .. Text'Length);
      Status     : HAL.UART.UART_Status;
   begin
      Receiver.Receive (Text_Bytes, Status, Natural (Timeout * 1_000));

      if Status /= HAL.UART.Ok then
         raise IO_Error with "UART receive failed with status " & Status'Image;
      end if;

      for I in Text'Range loop
         Text (I) := Character'Val (Text_Bytes (I));
      end loop;
   end Get;

   procedure Get_Line (Text : out String) is
      Text_Bytes : HAL.UART.UART_Data_8b (1 .. 1);
      Status     : HAL.UART.UART_Status;
      Pos        : Natural := Text'First;
   begin
      loop
         Receiver.Receive (Text_Bytes, Status, 10_000);

         if Status not in HAL.UART.Ok | HAL.UART.Err_Timeout then
            raise IO_Error with "UART receive failed with status " & Status'Image;
         end if;

         if Status /= HAL.UART.Err_Timeout then
            declare
               Char : constant Character := Character'Val (Text_Bytes (1));
            begin
               if Char in ASCII.CR | ASCII.LF then
                  exit;
               end if;

               if Pos <= Text'Last then
                  Text (Pos) := Char;
                  Pos        := Pos + 1;
               end if;
            end;
         end if;
      end loop;

      Text (Pos .. Text'Last) := [others => ' '];
   end Get_Line;

   procedure Read_Line (Text : out String) is
      Text_Bytes : HAL.UART.UART_Data_8b (1 .. 1);
      Status     : HAL.UART.UART_Status;
      Pos        : Natural := Text'First;
   begin
      loop
         Receiver.Receive (Text_Bytes, Status, 10_000);

         if Status not in HAL.UART.Ok | HAL.UART.Err_Timeout then
            raise IO_Error with "UART receive failed with status " & Status'Image;
         end if;

         if Status /= HAL.UART.Err_Timeout then
            declare
               Char : constant Character := Character'Val (Text_Bytes (1));
            begin
               Put (Char);

               if Char in ASCII.CR | ASCII.LF then
                  exit;
               elsif Char = ASCII.BS then
                  if Pos > Text'First then
                     Pos := Pos - 1;
                     Put (' ');
                     Put (ASCII.BS);
                  end if;
               elsif Pos <= Text'Last then
                  Text (Pos) := Character'Val (Text_Bytes (1));
                  Pos        := Pos + 1;
               end if;
            end;
         end if;
      end loop;

      Text (Pos .. Text'Last) := [others => ' '];
   end Read_Line;
end Pico.UART_IO;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
