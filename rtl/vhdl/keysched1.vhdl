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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity keysched1 is
  generic (
    rcon : std_logic_vector(7 downto 0)
    ); port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      roundkey : in  std_logic_vector(127 downto 0);
      fc3      : out blockcol;
      c0       : out blockcol;
      c1       : out blockcol;
      c2       : out blockcol;
      c3       : out blockcol
      );
end keysched1;

architecture rtl of keysched1 is
  signal subst                  : blockcol;
  signal key0, key1, key2, key3 : std_logic_vector(7 downto 0);
  signal rcon_d                 : std_logic_vector(7 downto 0);
  signal rk_block : datablock;
begin
  rk_block <= slv2db(roundkey);
  g0: for i in 0 to 3 generate
    sub : sbox port map(
      clk     => clk,
      rst     => rst,
      bytein  => rk_block(3)(i),
      byteout => subst((i+3) mod 4)
      );
  end generate;
  
  fc3(0) <= subst(0) xor rcon_d;
  fc3(1) <= subst(1);
  fc3(2) <= subst(2);
  fc3(3) <= subst(3);
  process(clk, rst)
  begin
    if(rst = '1') then
      rcon_d <= X"00";
      c0     <= zero_col;
      c1     <= zero_col;
      c2     <= zero_col;
      c3     <= zero_col;
    elsif(rising_edge(clk)) then
      rcon_d <= rcon;
      for j in 3 downto 0 loop
        c0(j) <= rk_block(0)(j);
        c1(j) <= rk_block(0)(j) xor rk_block(1)(j);
        c2(j) <= rk_block(0)(j) xor rk_block(1)(j) xor rk_block(2)(j);
        c3(j) <= rk_block(0)(j) xor rk_block(1)(j) xor rk_block(2)(j) xor rk_block(3)(j);
      end loop;
    end if;
  end process;
end rtl;
