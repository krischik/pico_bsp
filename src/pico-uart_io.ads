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

---
--  @summary
--  Simple UART output (and input) helper for quick debugging on the Raspberry Pi Pico.
--
--  @description
--  This package configures UART0 on GPIO 0 (TX) / GPIO 1 (RX) at 115200 baud, 8N1 — exactly the pins used by the
--  Raspberry Pi Debug Probe.
--
--  Why this package exists
--  =======================
--  The standard Ada.Text_IO did not produce output on the Debug Probe with the light runtime. This tiny helper gives
--  immediate serial I/O while the rest of the BSP is still being developed.
--
--  Usage with the Debug Probe
--  ==========================
--  1. Wire the Debug Probe:
--     * Debug Probe TX  → Pico GP0 (pin 1)
--     * Debug Probe RX  → Pico GP1 (pin 2)
--     * Debug Probe GND → Pico GND
--
--  2. Flash your program.
--  3. Open CoolTerm / minicom / tio / screen / PuTTY at 115200 8N1.
--  4. Call `Initialise` once at the start of your main procedure, then use `Put` / `Put_Line` freely.
--
--  Important notes
--  ===============
--  * Uses UART0 (the same peripheral the USB serial console normally uses).
--  * No buffering or advanced formatting — data goes straight to the UART FIFO.
--  * `Get_Line` and `Read_Line` block until a newline arrives (intended for unit tests and interactive input, not for
--     concurrent tasks).
--  * Two variants exist: a small, fast, non-task-safe version for the light runtime and a protected, thread-safe
--    version for the full runtime. Select via the Alire/GPR parameter `pico_xbsp.Variant`.
--
package Pico.UART_IO with
   Spark_Mode => Off
is
   ---
   --  Raised on any UART initialisation or communication error.
   IO_Error : exception;

   ---
   --  Initialises UART0 on GP0/GP1 at 115200 baud. Safe to call more than once.
   --" @exception IO_Error
   procedure Initialise;

   ---
   --  Sends a single character.
   --
   --" @param Text The character to send.
   --" @exception IO_Error
   procedure Put (Text : in Character);

   ---
   --  Sends a string (no newline added).
   --
   --" @param Text The string to send.
   --" @exception IO_Error
   procedure Put (Text : in String);

   ---
   --  Sends a string followed by a newline.
   --
   --" @param Text The string to send.
   --" @exception IO_Error
   procedure Put_Line (Text : in String);

   ---
   --  Reads one character. Raises IO_Error on timeout or hardware error.
   --
   --" @param Timeout Maximum wait time (default 60 s). 
   --" @return Character read
   --" @exception IO_Error
   function Get (Timeout : in Duration := 60.0) return Character;

   ---
   --  Reads characters into the string. On timeout the remainder is padded with spaces.
   --
   --" @param Text The string received.
   --" @param Timeout Maximum wait time (default 60 s).
   --" @exception IO_Error
   procedure Get (Text : out String; Timeout : in Duration := 60.0);

   ---
   --  Reads characters until a newline is received. The string is padded with spaces if the line is shorter than
   --  Text'Length. Blocks indefinitely.
   --
   --" @param Text The string received.
   --" @exception IO_Error
   procedure Get_Line (Text : out String);

   ---
   --  Reads a line with local echo and backspace support. Blocks until newline.
   --  The string is space-padded to Text'Length.
   --
   --" @param Text The string received.
   --" @exception IO_Error
   procedure Read_Line (Text : out String);

end Pico.UART_IO;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
