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
-- Description: The AddKey step
-- Ports:
--                      clk: System Clock
--                      roundkey: The RoundKey block for this round
--                      datain: Input State block
--                      rcon: The rcon byte corresponding to the current stage
--                      dataout: datain xor roundkey
--                      fc3: See keysched1 for explanation
--                      c0: See keysched1 for explanation
--                      c1: See keysched1 for explanation
--                      c2: See keysched1 for explanation
--                      c3: See keysched1 for explanation
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.aes_pkg.all;

entity addkey is
  generic (
    rcon : std_logic_vector(7 downto 0)
    ); port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      roundkey : in  std_logic_vector(127 downto 0);
      datain   : in  std_logic_vector(127 downto 0);
      dataout  : out std_logic_vector(127 downto 0) := (others => '0');
      fc3      : out std_logic_vector(31 downto 0);
      c        : out std_logic_vector(127 downto 0)
      );
end addkey;

architecture rtl of addkey is
begin
  step1 : keysched1 generic map(
    rcon => rcon
    ) port map(
      clk      => clk,
      rst      => rst,
      roundkey => roundkey,
      fc3      => fc3,
      c        => c
      );

  process(clk, rst)
  begin
    if(rst = '1') then
      dataout <= (others => '0');
    elsif(rising_edge(clk)) then
      dataout <= datain xor roundkey;
    end if;
  end process;
end rtl;
