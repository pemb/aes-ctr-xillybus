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
-- Description: The MixColumns step
-- Ports:
--                      clk: System Clock
--                      datain: Input State block
--                      inrkey: Input round key for passing on 
--                              to the next stage, i.e. Addkey
--                      outrkey: Output round key to next stage
--                      dataout: Output state block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity colmix is
  port(
    clk     : in  std_logic;
    rst     : in  std_logic;
    datain  : in  std_logic_vector(127 downto 0);
    inrkey  : in  std_logic_vector(127 downto 0);
    outrkey : out std_logic_vector(127 downto 0);
    dataout : out std_logic_vector(127 downto 0)
    );
end colmix;

architecture rtl of colmix is
  signal bi: datablock;
  signal bo : colnet(3 downto 0);
begin
  bi <= slv2db(datain);
  dataout <= db2slv((slv2bc(bo(3)),slv2bc(bo(2)),slv2bc(bo(1)),slv2bc(bo(0))));
  
  -- Do the mixcol operation on all the 4 columns
  g0 : for i in 3 downto 0 generate
    mix : mixcol port map(
      clk  => clk,
      rst  => rst,
      din  => bc2slv(bi(i)),
      dout => bo(i)
      );
  end generate;
  process(clk, rst)
  begin
    if(rst = '1') then
      outrkey <= (others => '0');
    elsif(rising_edge(clk)) then
      outrkey <= inrkey;
    end if;
  end process;
end rtl;
