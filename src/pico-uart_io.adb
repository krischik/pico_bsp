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

package body Pico.UART_IO is
   use type HAL.UART.UART_Status;

   UART   : RP.UART.UART_Port renames RP.Device.UART_0;
   TX_Pin : RP.GPIO.GPIO_Point renames Pico.GP0;   -- UART0 TX
   RX_Pin : RP.GPIO.GPIO_Point renames Pico.GP1;   -- UART0 RX

   procedure Initialise is
   begin
      TX_Pin.Configure
         (Mode => RP.GPIO.Output,
          Pull => RP.GPIO.Pull_Up,
          Func => RP.GPIO.UART);
      RX_Pin.Configure
         (Mode => RP.GPIO.Input,
          Pull => RP.GPIO.Pull_Up,
          Func => RP.GPIO.UART);
      UART.Configure
         (Config =>
             (Baud      => 115_200,
              Word_Size => 8,
              Parity    => False,
              Stop_Bits => 1,
              others    => <>));
   end Initialise;

   procedure Put (Text : in String) is
      Text_Bytes : HAL.UART.UART_Data_8b (1 .. Text'Length);
      Status     : HAL.UART.UART_Status;
   begin
      for I in Text'Range loop
         Text_Bytes (I) := Character'Pos (Text (I));
      end loop;

      UART.Transmit (Text_Bytes, Status);

      if Status /= HAL.UART.Ok then
         raise IO_Error with "UART transmit failed with status " & Status'Image;
      end if;
   end Put;

   procedure Put_Line (Text : in String) is
   begin
      Put (Text & ASCII.LF);
   end Put_Line;

end Pico.UART_IO;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
