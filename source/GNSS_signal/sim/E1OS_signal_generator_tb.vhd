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
 
ENTITY E1OS_signal_generator_tb IS
END E1OS_signal_generator_tb;
 
ARCHITECTURE behavior OF E1OS_signal_generator_tb IS 
 
 	constant Width : integer := 8;
 
	COMPONENT E1OS_signal_generator
		Generic(Width : integer := 8;		
				N : integer := 50);	
		PORT(clk : IN  std_logic;
			rst : IN  std_logic;
         PRN : IN  std_logic_vector(1 downto 0);
         E1OS : OUT  std_logic_vector(Width-1 downto 0);
			addr : in integer range 0 to 4092-1;
			strobe_in : IN  std_logic;
			strobe_out : OUT  std_logic;
			addr_new : IN  std_logic);			
    END COMPONENT;
    
	-- Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
	signal PRN : std_logic_vector(1 downto 0);
   signal addr : integer range 0 to 4092-1 := 0;
	signal strobe_in : std_logic := '0';
	signal addr_new : std_logic := '0';
	signal addr_new_aux : std_logic := '0';

 	-- Outputs
   signal E1OS : std_logic_vector(Width-1 downto 0);
	signal strobe_out : std_logic;
	
	-- Aux
	signal strobe_boc, strobe_boc_d, strobe_boc_d2 : std_logic := '0';
	signal strobe_prn, strobe_prn_d : std_logic := '0';
	signal start : std_logic := '0';

--	constant N : integer := 8;	
--	constant N : integer := 10;
--	constant N : integer := 12;
--	constant N : integer := 20;
	constant N : integer := 50;
	
	constant X : integer := integer(real(200)/real(N))-1;
	signal cont_boc : integer range 0 to N-1 := 0;	

   constant clk_period : time := 5 ns; -- 200 MHZ
 
	BEGIN
 
		uut: E1OS_signal_generator 
			generic map(Width=>8,
				N=> N) 	
			PORT MAP (clk => clk,
				rst => rst,
				PRN => PRN,
				E1OS => E1OS,
				addr => addr,
				strobe_in => strobe_in,
				strobe_out => strobe_out,
				addr_new => addr_new);			
				
		strobe_in <= strobe_boc_d2 and start;
				
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
--			file file_E1OS : text open write_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_8MHz.txt";			
--			file file_E1OS : text open write_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_10MHz.txt";			
--			file file_E1OS : text open write_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_12MHz.txt";			
--			file file_E1OS : text open write_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_20MHz.txt";			
			file file_E1OS : text open write_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_50MHz.txt";			
			
			begin		
				file_close(file_E1OS);

				wait for 100 ns;	
				rst <= '0';
				wait;
		end process;
		
		-- Create strobe BOC signal
		process
			begin
				strobe_boc <= '1';
				wait for clk_period;
				strobe_boc <= '0';
				wait for X*clk_period;
		end process;		

		-- Create strobe PRN signal
		process (clk)
			begin
				if (rising_edge(clk)) then
					
					strobe_prn <= '0';
				
					if strobe_boc = '1' then
						cont_boc <= cont_boc+1;
						if cont_boc = N-1 then
							strobe_prn <= '1';
							cont_boc <= 0;
						end if;
					end if;
				end if;
			end process;
		
		-- Read process
		process (clk)
		
			variable buff_E1B, buff_E1C : line;
			variable aux_E1B, aux_E1C : integer;
			
			-- Input file
			file file_E1B  : text open read_mode is ".\matlab\testbench_excite\PRN_E1B_1_rep5.txt";				
			file file_E1C  : text open read_mode is ".\matlab\testbench_excite\PRN_E1C_1_rep5.txt";					
			
			begin
			
				if (rising_edge(clk)) then  
					if rst = '1' then
						strobe_prn_d <= '0';
						strobe_boc_d <= '0';
						strobe_boc_d2 <= '0';
						
						PRN(0) <= '0';
						PRN(1) <= '0';
						
						start <= '0';
						
					else
					
						strobe_prn_d <= strobe_prn;
						strobe_boc_d <= strobe_boc;
						strobe_boc_d2 <= strobe_boc_d;						
					
						start <= start;
					
						if strobe_prn = '1' then
						
							start <= '1';
							
							readline(file_E1B,buff_E1B);
							read(buff_E1B,aux_E1B);
							
							readline(file_E1C,buff_E1C);
							read(buff_E1C,aux_E1C);							

							if aux_E1B = 1 then -- +1		
								PRN(1)<= '1';
							else							
								PRN(1)<= '0';
							end if;
							
							if aux_E1C = 1 then -- +1		
								PRN(0)<= '1';
							else							
								PRN(0)<= '0';
							end if;
						end if; --strobe_prn
					end if; -- rst			 
				end if; -- clk
		end process;		
		
		-- Write process
		process (clk)
			
			variable buff_E1OS : line;		
--			file file_E1OS : text open append_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_8MHz.txt";			
--			file file_E1OS : text open append_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_10MHz.txt";			
--			file file_E1OS : text open append_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_12MHz.txt";			
--			file file_E1OS : text open append_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_20MHz.txt";						
			file file_E1OS : text open append_mode is "source/GNSS_signal/sim/results/E1OS_signal_generator_output_50MHz.txt";			
		
			begin
				if (rising_edge(clk)) then 
					if strobe_out= '1' then
						write(buff_E1OS, E1OS); 
						writeline(file_E1OS, buff_E1OS);	
					end if;
				end if;
		end process;		
END;