--------------------------------------------------------------------------------------
-- Basic block to generate a LFSR sequence (1 bit output).
-- All inputs are fixed until next reset.
--
-- Used to generate the sequences L1 C/A; L5 I and Q; Galileo E5 aI, aQ, bI, and bQ.
-- Check the maximum clock frequency of your system for the XORing.
--------------------------------------------------------------------------------------
-- *** INPUTS ***
-- seed --> Initial state of the registers.
-- tap --> These registers are XORed to update the first register (taps)
-- reset --> The registers are loaded to the signal seed when they reach this state.
--				 All 0s is unreachable.
-- output --> These registers are XORed to create the output (phases).
-- count_cmp --> The registers are loaded to the signal seed when every X clocks.
--					  "0" means no reseting.
-- enable --> To freeze the LSFR (in principle to reduce power consumption, but
--				  it can be used to generate the code by steps).
--
-- *** OUTPUTS ***
-- seq --> 1 bit sequence.
-- valid --> new output value.
--
--	LATENCY = 1 clock
--------------------------------------------------------------------------------------
-- Diary:	02/12/2014	Start 
--				08/06/2016	Version 1.0	Dani
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
use IEEE.std_logic_unsigned.all; -- additions

entity LFSR_generator is
	GENERIC(WIDTH : integer := 10;	
		WIDTH_CMP : integer := 0);		
	Port (clk : in STD_LOGIC;
		rst	: in STD_LOGIC;									-- reset
		seed	: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);	-- initial state
		tap	: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);	-- XOR taps for input
		RESET : in STD_LOGIC_VECTOR (WIDTH-1 downto 0); -- reset at this state
		output : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);-- phase selector taps		
		SEQ : out STD_LOGIC;							-- 1 bit output
		count_cmp : in STD_LOGIC_VECTOR (WIDTH_CMP-1 downto 0); -- reset after X clocks
		ENABLE : in STD_LOGIC;								-- Enable high (to freeze the LSFR)
		valid : out STD_LOGIC);
end LFSR_generator;

architecture Behavioral of LFSR_generator is

	signal reg: std_logic_vector(WIDTH-1 downto 0);
	signal tap_mem: std_logic_vector(WIDTH-1 downto 0);
	signal RESET_mem: std_logic_vector(WIDTH-1 downto 0);
	signal output_mem: std_logic_vector(WIDTH-1 downto 0);
	signal seed_mem: std_logic_vector(WIDTH-1 downto 0);
	signal count_cmp_mem : std_logic_vector(WIDTH_CMP-1 downto 0);
	
	signal count : std_logic_vector(WIDTH_CMP-1 downto 0);
	
	-- Debugging (these lines will be removed when synthesizing)
	signal epoch : STD_LOGIC;
	signal all_ones: std_logic_vector(WIDTH-1 downto 0);
	signal epoch_ones : STD_LOGIC;
	
	begin
		proc: process(clk)
		
			variable xor_result_1 : std_logic; -- taps
			variable xor_result_2 : std_logic; -- phases
		
			begin
				if (rising_edge(clk)) then
					if (rst = '1') then
						--LSFR
						reg <=  (others => '0');							
						xor_result_1 :=  '0';
						xor_result_2 :=  '0';
						SEQ <= '0';	
						valid <= '0';
						count <= (others => '0');

						-- These values must be already valid when reseting.
						tap_mem <= tap;
						RESET_mem <= RESET;
						output_mem <= output;
						seed_mem <= seed;
						reg <= seed;			
						count_cmp_mem <= count_cmp;

						-- Debugging
						all_ones <= (others => '1');	
						epoch <= '0';
						epoch_ones <= '0';						
					else
					
						if (ENABLE = '0') then -- Freeze everything
							valid <= '0';
						else
						
							valid <= '1'; 
						
							-- Shift the register
							reg(WIDTH-1 downto 1) <= reg(WIDTH-2 downto 0);

							-- First register update
							xor_result_1 := reg (0) and tap_mem(0);
							for i in 1 to WIDTH-1 loop
								xor_result_1 := (xor_result_1 xor (reg (i) and tap_mem(i)) );
							end loop;
							reg(0) <= xor_result_1;

							-- LSFR output
							xor_result_2 := reg(0) and output_mem(0);
							for i in 1 to WIDTH-1 loop
								xor_result_2 := (xor_result_2 xor (reg (i) and output_mem(i)) );		
							end loop;
							SEQ<= xor_result_2;
			
							-- Force original seed when reaching RESET_mem state
							if (reg = RESET_mem) then
								reg <= seed_mem;
							end if;
							
							-- Force original seed after count_cmp_mem clocks
							if count_cmp_mem > 0 then
								if count = count_cmp_mem then
									reg <= seed_mem;
									count <= (others => '0');	
								else
									count <= count +1;
								end if;
							end if;
							
							-- Debugging
							if (reg = seed) then
								epoch <= '1';
							else
								epoch <= '0';
							end if;
							if reg = all_ones then
								epoch_ones <= '1';
							else
								epoch_ones <= '0';
							end if;								
						end if; --enable
					end if; 	--reset 
				end if; 		--clock				
		end process proc; 
end Behavioral;