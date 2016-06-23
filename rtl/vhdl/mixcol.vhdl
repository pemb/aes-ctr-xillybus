----------------------------------------------------------------------
----                                                              ----
---- Pipelined Aes IP Core                                        ----
----                                                              ----
---- This file is part of the Pipelined AES project               ----
---- http://www.opencores.org/cores/aes_pipe/                     ----
----                                                              ----
---- Description                                                  ----
---- Implementation of AES IP core according to                   ----
---- FIPS PUB 197 specification document.                         ----
----                                                              ----
---- To Do:                                                       ----
----   -                                                          ----
----                                                              ----
---- Author:                                                      ----
----      - Subhasis Das, subhasis256@gmail.com                   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
------------------------------------------------------
-- Project: AESFast
-- Author: Subhasis
-- Last Modified: 25/03/10
-- Email: subhasis256@gmail.com
------------------------------------------------------
--
-- Description: The MixColumns operation
-- Ports:
--                      clk: System Clock
--                      in0: Byte 0 of a column
--                      in1: Byte 1 of a column
--                      in2: Byte 2 of a column
--                      in3: Byte 3 of a column
--                      out0: Byte 0 of output column
--                      out1: Byte 1 of output column
--                      out2: Byte 2 of output column
--                      out3: Byte 3 of output column
--                      keyblock: Input Key Blocks three at a time
--                      ciphertext: Output Cipher Block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.aes_pkg.all;

entity mixcol is
  port(
    din  : in  std_logic_vector(31 downto 0);
    dout : out std_logic_vector(31 downto 0)
    );
end mixcol;

architecture rtl of mixcol is
  signal xored              : std_logic_vector(7 downto 0);
  signal col_in, col_out, sh, d, t   : blockcol;
begin

  col_in <= slv2bc(din);

  xored <= col_in(0) xor col_in(1) xor col_in(2) xor col_in(3);

  shift : for i in 0 to 3 generate
    -----------------------------------------------------
    -- In GF(2^8) 2*x = (x << 1) xor 0x1b if x(7) = '1'
    --                  (x << 1) else
    -- This just left shifts each byte by 1.

    sh(i) <= col_in(i)(6 downto 0) & "0";

    -- Conditional XOR'ing
    d(i) <= sh(i) xor X"1b" when col_in(i)(7) = '1' else sh(i);

    ----------------------------------------------------
    -- 3*x = 2*x xor x
    ----------------------------------------------------

    t(i) <= d(i) xor col_in(i);
    col_out(i) <= xored xor t(i) xor d((i+1) mod 4);
  end generate;

  dout <= bc2slv(col_out);

end rtl;
