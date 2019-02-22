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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_signed.all; 	-- Additions

use ieee.std_logic_textio.all;   -- Write to file
use std.textio.all;
 
ENTITY E5_top_tb IS
END E5_top_tb;
 
ARCHITECTURE behavior OF E5_top_tb IS 
 
	COMPONENT E5_top
	Generic(Width : integer := 8;			
		N : integer := 50);		
	PORT(clk : IN  std_logic;
		rst : IN  std_logic;
		strobe_out : OUT  std_logic;
		strobe_in : IN  std_logic;
		epoch : OUT  std_logic;
		E5I : OUT  std_logic_vector(Width-1 downto 0);
		E5Q : OUT  std_logic_vector(Width-1 downto 0);
		SAT : IN  integer range 0 to 26);
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal strobe_in : std_logic := '0';
   signal SAT :  integer range 0 to 26 := 0;

 	--Outputs
   signal strobe_out : std_logic;
   signal epoch : std_logic;
   signal E5I : std_logic_vector(8-1 downto 0);
   signal E5Q : std_logic_vector(8-1 downto 0);
	
--	constant N : integer := 10;	
--	constant N : integer := 20;
	constant N : integer := 50;
--	constant N : integer := 100;

	constant X : integer := integer(real(200)/real(N))-1;	

   -- Clock period definitions
   constant clk_period : time := 5 ns;	-- 200 MHz 
	
	BEGIN
 
		uut: E5_top 
			Generic map (Width => 8,
				N => N)	
			PORT MAP (clk => clk,
				 rst => rst,
				 strobe_out => strobe_out,
				 strobe_in => strobe_in,
				 epoch => epoch,
				 E5I => E5I,
				 E5Q => E5Q,
				 SAT => SAT);

		-- Clock process definitions
		clk_process :process
		begin
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end process;
	 
		 -- Stimulus process
		stim_proc: process
				-- clean output files		
--				file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_I_10MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_10MHz.txt";			
--				file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_I_20MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_20MHz.txt";			
				file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_I_50MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_50MHz.txt";			
--				file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_I_100MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_100MHz.txt";						
			
			begin		
				file_close(file_E5_I);
				file_close(file_E5_Q);		
			
				wait for 100 ns;	
				rst <= '0';
				wait;
			end process;
		
			-- Create strobe BOC signal
			process
				begin
					strobe_in <= '1';
					wait for clk_period;
					strobe_in <= '0';
					wait for X*clk_period;
			end process;		
	 
	 
		-- Write process
		process (clk)
			
			variable buff_E5_I, buff_E5_Q : line;
			
--			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_top_output_I_10MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_10MHz.txt";			
--			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_top_output_I_20MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_20MHz.txt";			
			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_top_output_I_50MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_50MHz.txt";			
--			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_top_output_I_100MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_top_output_Q_100MHz.txt";						

			begin
				if (rising_edge(clk)) then 
					if strobe_out= '1' then
						write(buff_E5_I , E5I); 
						writeline(file_E5_I, buff_E5_I);	
						
						write(buff_E5_Q , E5Q); 
						writeline(file_E5_Q, buff_E5_Q);	
					end if;
				end if;
		end process;
END;