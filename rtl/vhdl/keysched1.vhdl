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
-- Description: First stage of key expansion
-- Ports:
--                      clk: System Clock
--                      roundkey: Current roundkey
--                      rcon: Rcon byte for the next byte
--                      fc3: Sbox(RotWord(column3 of rkey)) xor Rcon
--                      c0: column0 of rkey
--                      c1: column0 xor column1
--                      c2: column0 xor column1 xor column2
--                      c3: column0 xor column1 xor column2 xor column3
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.aes_pkg.all;

entity keysched1 is
  generic (
    rcon : std_logic_vector(7 downto 0)
    ); port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      roundkey : in  std_logic_vector(127 downto 0);
      fc3      : out std_logic_vector(31 downto 0);
      c        : out std_logic_vector(127 downto 0)
      );
end keysched1;

architecture rtl of keysched1 is
  signal subst, fc3_col         : blockcol;
  signal key0, key1, key2, key3 : std_logic_vector(7 downto 0);
  signal rk_block, c_blk        : datablock := zero_data;
begin

  rk_block <= slv2db(roundkey);

  l0 : for j in 3 downto 0 generate
    c_blk(0)(j) <= rk_block(0)(j);
    c_blk(1)(j) <= rk_block(0)(j) xor rk_block(1)(j);
    c_blk(2)(j) <= rk_block(0)(j) xor rk_block(1)(j) xor rk_block(2)(j);
    c_blk(3)(j) <= rk_block(0)(j) xor rk_block(1)(j) xor rk_block(2)(j) xor rk_block(3)(j);
  end generate;

  l1 : for i in 0 to 3 generate
    subst((i+3) mod 4) <= sbox(rk_block(3)(i));
  end generate;

  fc3_col(0) <= subst(0) xor rcon;
  fc3_col(1) <= subst(1);
  fc3_col(2) <= subst(2);
  fc3_col(3) <= subst(3);

  process(clk, rst)
  begin
    if(rst = '1') then
      c   <= (others => '0');
      fc3 <= (others => '0');
    elsif(rising_edge(clk)) then
      c   <= db2slv(c_blk);
      fc3 <= bc2slv(fc3_col);
    end if;
  end process;
end rtl;
