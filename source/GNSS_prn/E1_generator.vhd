--------------------------------------------------------------------------------------
-- E1B and E1C codes generator (1 bit outputs). They are memory codes stored in ROMs.
--
-- Galileo: 27 satellites
-- PRN E1B, E1C: 4092 chips length.
-- Two ROMs of 110592 (4096 * 27) positions depth and 1 bit width are needed.
-- stuff with 4 "0" between codes.
--
--    SAT 1          SAT 2   
-- 0      4091    4096   8186 
-- +++++++++++0000+++++++++++0000 ... etc
--
-- Reset MUST be asserted during 2 clocks.
-- Satellite MUST be fixed during reset.
--	Satellite will be fix until next reset.
--
-- LATENCY 
--------------------------------------------------------------------------------------
-- **** INPUTS ****
-- sat --> Sat number: 
--			0 = PRN 1, 1 = PRN 2,...,26 = PRN 27
-- enable --> freeze
--
-- **** OUTPUTS  ****
-- E1B, E1C  --> PRN signals
-- valid --> PRNs valid
-- epoch --> PRNs repeat
--------------------------------------------------------------------------------------
-- Diary:	09/06/2015	Start 
--				15/06/2016	Version 1.0	Dani
--------------------------------------------------------------------------------------
-- Author: Daniel Pascual (daniel.pascual at protonmail.com) 
-- Copyright 2017 Daniel Pascual
-- License: GNU GPLv3
--------------------------------------------------------------------------------------
-- Copyright 2017 Daniel Pascual
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

entity E1_generator is
	Port (clk : in STD_LOGIC;
			rst	: in STD_LOGIC;		-- signal to start	
			E1B : out STD_LOGIC;			-- 1 bit output
			E1C : out STD_LOGIC;			-- 1 bit output
			ENABLE : in STD_LOGIC;		-- enable high
			valid_out : out std_logic;
			epoch : out STD_LOGIC;
			SAT : in integer range 0 to 26);	-- 27 Galileo
end E1_generator;

architecture Behavioral of E1_generator is

	signal E1B_out : std_logic_vector(0 downto 0);
	signal E1C_out : std_logic_vector(0 downto 0);
	signal cont_addr, cont_epoch : integer range 0 to 4092-1;	-- PRN period of 4092 clocks	

	signal addr, addr_ref : STD_LOGIC_VECTOR(17-1 downto 0); --27*4096 --> 17b
	
	signal ENABLE_d, ENABLE_d2 : std_logic; 	-- The memories have a latency of 2 clocks

	COMPONENT PRN_E1B
		PORT (clka : IN STD_LOGIC;
			ena : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT PRN_E1C
		PORT (clka : IN STD_LOGIC;
			ena : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
	END COMPONENT;	

	begin
	
		PRN_E1B_inst : PRN_E1B
			PORT MAP (clka => clk,
				ena => ENABLE_d,
				addra => addr,
				douta => E1B_out);	
				
		PRN_E1C_inst : PRN_E1C
			PORT MAP (clka => clk,
				ena =>  ENABLE_d,
				addra => addr,
				douta => E1C_out);

		proc: process(clk)
			begin		
				if (rising_edge(clk)) then
					if (rst = '1') then
						
						-- Outputs
						E1B <= '0';
						E1C <= '0';
						valid_out <='0';	
						epoch <= '0';	

						-- aux
						cont_epoch <= 4092-1;
						cont_addr <= 4092-1;	
						ENABLE_d <= '0';
						ENABLE_d2 <= '0';
						
						addr_ref <= std_logic_vector(to_unsigned(SAT*4096, addr'length));	
						addr <= std_logic_vector(to_unsigned(SAT*4096, addr'length));

					else 
						
						ENABLE_d <= ENABLE;
						ENABLE_d2 <= ENABLE_d;
						valid_out <= ENABLE_d2;
						epoch <= '0';

						-- Create PRNs
						E1B <= E1B_out(0);
						E1C <= E1C_out(0);
						
						if ENABLE = '1' then
							-- Read ROMs
							if cont_addr = 4092-1 then
								addr <= addr_ref;						
								cont_addr <= 0;
							else
								addr <= addr+1;
								cont_addr <= cont_addr+1;
							end if;							
						end if;
						
						if ENABLE_d2 = '1' then
							-- Counter epoch
							if cont_epoch = 4092-1 then
								cont_epoch <= 0;
								epoch<= '1';
							else
								cont_epoch <= cont_epoch+1;							
							end if;
						end if;
						
					end if; --reset
				end if; --clock	
		end process proc;	
end Behavioral;