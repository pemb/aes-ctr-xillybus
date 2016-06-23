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
-- Description: The Sbox and Shiftrows step
-- Ports:
--                      clk: System Clock
--                      blockin: Input state block
--                      fc3: See keysched1 for explanation
--                      c0: See keysched1 for explanation
--                      c1: See keysched1 for explanation
--                      c2: See keysched1 for explanation
--                      c3: See keysched1 for explanation
--                      nextkey: Roundkey for next round
--                      blockout: output state block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.aes_pkg.all;

entity sboxshr is
  port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    blockin  : in  std_logic_vector(127 downto 0);
    fc3      : in  std_logic_vector(31 downto 0);
    c        : in  std_logic_vector(127 downto 0);
    nextkey  : out std_logic_vector(127 downto 0) := (others => '0');
    blockout : out std_logic_vector(127 downto 0)
    );
end sboxshr;

architecture rtl of sboxshr is
  signal bi_blk, bo_blk : datablock := zero_data;
begin
  -- The sbox, the output going to the appropriate state byte after shiftrows
  bi_blk   <= slv2db(blockin);

  -- sbox and shift rows

  g0 : for i in 3 downto 0 generate
    g1 : for j in 3 downto 0 generate
      bo_blk((j-i) mod 4)(i) <= sbox(bi_blk(j)(i));
    end generate;
  end generate;

  process(clk, rst)
  begin
    if(rst = '1') then
      --nk_blk <= zero_data;
      nextkey <= (others => '0');
      blockout <= (others => '0');
    elsif(rising_edge(clk)) then
      -- col0 of nextkey = fc3 xor col0
      -- col1 of nextkey = fc3 xor col0 xor col1
      -- col2 of nextkey = fc3 xor col0 xor col1 xor col2
      -- col3 of nextkey = fc3 xor col0 xor col1 xor col2 xor col3
      nextkey <= (fc3 & fc3 & fc3 & fc3) xor c;
      blockout <= db2slv(bo_blk);
    end if;
  end process;
end rtl;
