--------------------------------------------------------------------------------------
-- In this example you cannot use of addr_new, because to do so, the unsampled PRN
-- must be stored in memory first.
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

entity E5_top is
	Generic(Width : integer := 8;			
		N : integer := 50);					-- integer > 0
	Port (clk : in STD_LOGIC;
			rst	: in STD_LOGIC;		
			strobe_out : out std_logic;
			strobe_in : in std_logic;			-- strobe a N*1.023 MHz
			epoch : out STD_LOGIC;
			E5I : out STD_LOGIC_VECTOR(Width-1 downto 0);
			E5Q : out STD_LOGIC_VECTOR(Width-1 downto 0);
			SAT : in integer range 0 to 26);	-- 27 Galileo
end E5_top;

architecture Behavioral of E5_top is

	signal PRN : STD_LOGIC_VECTOR(4-1 downto 0);
	signal strobe_PRN, strobe_BOC : std_logic;

	-- aux
	constant M : integer := integer(real(N)/10.0); 
	constant LATENCY : integer := 5;
	signal epoch_prn : std_logic;	
	signal strobe_in_d : std_logic_vector(LATENCY-1 downto 0);
	signal epoch_prn_d : std_logic_vector(LATENCY-1-1 downto 0);
	signal prn_started : std_logic;
	signal valid_PRN : std_logic;	

	COMPONENT E5_signal_generator is
			Generic(Width : integer := 8; 
					N : integer := 50);
			Port (clk : in STD_LOGIC;
				rst	: in STD_LOGIC;
				PRN : in STD_LOGIC_VECTOR(4-1 downto 0);
				E5I : out STD_LOGIC_VECTOR(Width-1 downto 0);
				E5Q : out STD_LOGIC_VECTOR(Width-1 downto 0);
				addr : in integer range 0 to 10230-1;	
				strobe_in : in std_logic;
				strobe_out : out std_logic;
				addr_new : in std_logic);
	end COMPONENT;

	COMPONENT E5_generator is
		Port (clk : in STD_LOGIC;
				rst	: in STD_LOGIC;	
				E5aI : out STD_LOGIC;	
				E5aQ : out STD_LOGIC;	
				E5bI : out STD_LOGIC;	
				E5bQ : out STD_LOGIC;	
				ENABLE : in STD_LOGIC;	
				valid_out : out std_logic;
				epoch : out STD_LOGIC;
				SAT : in integer range 0 to 26);	
	end COMPONENT;
	
	COMPONENT strobe_fast_2_slow
		Generic(N : integer := 12);
		Port (clk : in STD_LOGIC;
			rst	: in STD_LOGIC;		
			strobe_PRN : out std_logic;	
			strobe_in : in std_logic);
	END COMPONENT;		

	begin
	
		E5_signal_generator_inst : E5_signal_generator
			Generic map(Width => Width,
				N => N)
			Port map (clk => clk,
				rst => rst,
				PRN => PRN,
				E5I => E5I,
				E5Q => E5Q,
				addr => 0,
				strobe_in => strobe_BOC,
				strobe_out => strobe_out,
				addr_new => '0');	
		
		E5_generator_inst : E5_generator
			Port map (clk => clk,
					rst => rst,
					E5aI => PRN(3),
					E5aQ => PRN(1),
					E5bI => PRN(2),
					E5bQ => PRN(0),
					ENABLE => strobe_PRN,
					valid_out => valid_PRN,
					epoch =>  epoch_prn,
					SAT => SAT);						-- The block has its own memory

		strobe_fast_2_slow_inst : strobe_fast_2_slow 
			Generic map(N => M)			
			Port map (clk => clk,
				rst => rst,
				strobe_PRN => strobe_PRN,
				strobe_in => strobe_in);		

		strobe_BOC <= strobe_in_d(LATENCY-1) and prn_started;
		epoch <=	epoch_prn_d(LATENCY-1-1);
		
	process(clk)
		begin
			if (rising_edge(clk)) then
				if (rst = '1') then
					strobe_in_d <= (others =>'0');
					epoch_prn_d <= (others =>'0');
					
					prn_started <= '0';
					
				else
				
					strobe_in_d(0) <= strobe_in;
					strobe_in_d(LATENCY-1 downto 1) <= strobe_in_d(LATENCY-2 downto 0);
					
					epoch_prn_d(0) <= epoch_prn;
					epoch_prn_d(LATENCY-1-1 downto 1) <= epoch_prn_d(LATENCY-2-1 downto 0);				
					
					if strobe_PRN = '1' then
						prn_started <= '1';
					else
						prn_started <= prn_started;
					end if;
				end if; 		
			end if;
		end process;		
end Behavioral;