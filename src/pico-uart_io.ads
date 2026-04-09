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

------------------------------------------------------------------------------
--  Pico.UART_IO
--
--  Simple UART output helper for quick debugging on the Raspberry Pi Pico.
--
--  This package configures the RP2040's UART0 on GPIO 0 (TX) and GPIO 1 (RX) at 115200 baud, 8N1. These are exactly
--  the pins used by the Raspberry Pi Debug Probe when you connect it for UART communication.
--
--  Why this package exists
--  =======================
--  I tried using Ada.Text_IO with the standard Pico BSP, but it didn't produce any output on the Debug Probe. Rather
--  than spend ages debugging the runtime configuration, I created this tiny helper that lives inside the pico_xbsp
--  (extended board support package). It gives me immediate serial output while I develop the rest of the project.
--
--:  Usage with the Debug Probe
--:  ==========================
--:  1. Wire the Debug Probe:
--:       Debug Probe TX  →  Pico GP0 (physical pin 1)
--:       Debug Probe RX  →  Pico GP1 (physical pin 2)
--:       Debug Probe GND →  Pico GND
--
--:  2. Flash your program as usual.
--
--:  3. Open CoolTerm (or minicom, tio, screen, PuTTY …) with these settings:
--:       • Port: the one that appears when the Debug Probe is connected
--:       • Baud rate: 115200
--:       • 8 data bits, no parity, 1 stop bit, no flow control
--
--:  4. Call Pico.UART_IO.Init once at the start of your main procedure,
--:     then use Put and Put_Line freely. You will see the transmit LED
--:     flash on the Debug Probe exactly as you noticed earlier.
--
--:  Important notes
--:  ===============
--:  • This package deliberately uses UART0, the same peripheral that the
--:    USB serial console would normally use. That is intentional — it keeps
--:    debugging simple and consistent.
--:  • The package is deliberately minimal. It only provides output for now.
--:    Input (Get / Get_Line) can be added later if needed.
--:  • No buffering or advanced formatting is performed — what you Put is
--:    sent directly to the UART FIFO.
------------------------------------------------------------------------------

package Pico.UART_IO is

   --  Raised if the UART cannot be initialised (very rare on a Pico).
   IO_Error : exception;

   --  Initialises UART0 on GP0 (TX) and GP1 (RX) at 115200 baud. Must be called before any Put or Put_Line. Safe to
   --  call more than once — subsequent calls do nothing.
   procedure Initialise;

   --  Sends a string to the UART. No newline is added.
   procedure Put (Text : in String);

   --  Sends a string followed by a newline (CR + LF).
   procedure Put_Line (Text : in String);

end Pico.UART_IO;
--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
