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

--  @summary
--  Simple driver for a common-cathode RGB LED connected to the Raspberry Pi Pico using PWM on three analogue outputs.
--
--  @description
--  This package provides an easy-to-use interface for controlling the colour of an RGB LED. You pass an array of three
--  PWM points (one for each colour channel) and the desired intensity for red, green and blue.
--
--  The LED is assumed to be common-cathode; the PWM duty cycle directly controls the brightness of each channel (0 =
--  off, 255 = full brightness on the Pico's 12-bit PWM).
--
--  There are two set function one where the three colour level are separate and one where the colour is set as a
--  standard 24 bit value.
--
package Pico.Analog.RGB_LED is

   --  @summary
   --  24-bit RGB colour value (8 bits red, 8 bits green, 8 bits blue).
   --
   --  @description
   --  Values range from 0 (black) to 16#FFFFFF# (white). The type uses modular arithmetic, so adding or subtracting
   --  colours automatically wraps around — perfect for simple colour arithmetic in a tutorial.
   type RGB_Color is mod 2**24;

   --  The three colour channels we can drive.
   type Color_Type is
      (Red,
       Green,
       Blue);

   --  Convenience array type so you can keep the three PWM pins together. Example usage:
   --     My_LED : constant Color_Array :=
   --        (Red   => PWM_GPIO_2,
   --         Green => PWM_GPIO_3,
   --         Blue  => PWM_GPIO_4);
   type Color_Array is
      array (Color_Type)
      of Pico.Analog.PWM_Point;

   --  @summary
   --  Set the colour of the RGB LED by adjusting the PWM duty cycle on each channel.
   --
   --  @param LED
   --    Array holding the three PWM points connected to the red, green and
   --    blue anodes of the LED.
   --
   --  @param Red_Value
   --    Brightness for the red channel (0 = off … Analog_Level'Last = full on).
   --
   --  @param Green_Value
   --    Brightness for the green channel.
   --
   --  @param Blue_Value
   --    Brightness for the blue channel.
   --
   --  @example
   --    --  Full white at medium brightness
   --    Set_Colour (My_LED, 128, 128, 128);
   --
   --    --  Pure red
   --    Set_Colour (My_LED, 255,  255,  255);
   procedure Set_Color
      (LED         : in Color_Array;
       Red_Value   : in Pico.Analog.Analog_Level;
       Green_Value : in Pico.Analog.Analog_Level;
       Blue_Value  : in Pico.Analog.Analog_Level);

   --  @summary
   --  Set the RGB LED to a single 24-bit colour.
   --
   --  @param LED
   --    The three PWM points wired to the red, green and blue channels
   --    of your common-cathode RGB LED.
   --
   --  @param Color
   --    The desired 24-bit RGB colour.  The high 8 bits are ignored
   --    (they are masked away internally).
   --
   --  @example
   --    --  Pure red at full brightness
   --    Set_Color (My_LED, 16#FF0000#);
   --
   --    --  Medium white
   --    Set_Color (My_LED, 16#808080#);
   --
   --    --  Using named numbers for clarity
   --    Set_Color (My_LED, 16#00FF00#);  --  full green
   procedure Set_Color (LED : in Color_Array; Color : in RGB_Color);

end Pico.Analog.RGB_LED;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
