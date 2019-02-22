--------------------------------------------------------------------------------------
-- 
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- **** INPUTS ****
-- 
--
-- **** OUTPUTS  ****
-- 
--------------------------------------------------------------------------------------
-- Diary:	05/01/2018	Start 
--------------------------------------------------------------------------------------
-- Author: Daniel Pascual (daniel.pascual at protonmail.com) 
-- Copyright 2018 Daniel Pascual
-- License: GNU GPLv3
--------------------------------------------------------------------------------------
-- Copyright 2018 Daniel Pascual
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;-- addition
use ieee.numeric_std.all;		-- to_signed, etc
use IEEE.math_real.all; 		-- maths

entity strobe_fast_2_slow is
	Generic(N : integer := 12);
	Port (clk : in STD_LOGIC;
		rst	: in STD_LOGIC;		
		strobe_PRN : out std_logic;	
		strobe_in : in std_logic);			
end strobe_fast_2_slow;

architecture Behavioral of strobe_fast_2_slow is

	signal cont_boc : integer range 0 to N-1 := 0;		
	
	begin
		process(clk)
	
			begin
				if (rising_edge(clk)) then
					if (rst = '1') then
						cont_boc <= N-1;
						strobe_prn <= '0';
					else
						strobe_prn <= '0';
						if strobe_in = '1' then
							cont_boc <= cont_boc+1;
							if cont_boc = N-1 then
								strobe_prn <= '1';
								cont_boc <= 0;
							end if;
						end if; 	
					end if; 		
				end if;
			end process;					
end Behavioral;