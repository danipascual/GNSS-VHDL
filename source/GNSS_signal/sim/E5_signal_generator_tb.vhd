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
 
ENTITY E5_signal_generator_tb IS
END E5_signal_generator_tb;
 
ARCHITECTURE behavior OF E5_signal_generator_tb IS 
 
	constant Width : integer := 8;
 
    COMPONENT E5_signal_generator
		Generic(Width : integer := 8;
				N : integer := 50);	 
		 PORT(clk : IN  std_logic;
			rst : IN  std_logic;
			PRN : IN  std_logic_vector(3 downto 0);
			E5I : OUT  std_logic_vector(Width-1 downto 0);
			E5Q : OUT  std_logic_vector(Width-1 downto 0);
			addr : in integer range 0 to 10230-1;
			strobe_in : IN  std_logic;
			strobe_out : OUT  std_logic;
			addr_new : IN  std_logic);
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal PRN : std_logic_vector(3 downto 0) := (others => '0');
   signal addr : integer range 0 to 10230-1 := 0;
   signal strobe_in : std_logic := '0';
   signal addr_new : std_logic := '0';
	signal addr_new_aux : std_logic := '0';
	

 	--Outputs
   signal E5I : std_logic_vector(Width-1 downto 0);
   signal E5Q : std_logic_vector(Width-1 downto 0);
   signal strobe_out : std_logic;
	
	-- Aux
	signal strobe_boc, strobe_boc_d, strobe_boc_d2 : std_logic := '0';
	signal strobe_prn, strobe_prn_d : std_logic := '0';
	signal start : std_logic := '0';	
	
	constant N : integer := 10;	constant L : integer := 1;
--	constant N : integer := 20;	constant L : integer := 2;
--	constant N : integer := 50;	constant L : integer := 5;
--	constant N : integer := 100; 	constant L : integer := 10;

	constant X : integer := integer(real(200)/real(N))-1;
	signal cont_boc : integer range 0 to L-1 := 0;	

   -- Clock period definitions
   constant clk_period : time := 5 ns; -- 200 MHZ
 
	BEGIN
	 
		uut: E5_signal_generator
			generic map(Width=>Width,
				N=> N) 
			PORT MAP (clk => clk,
				rst => rst,
				PRN => PRN,
				E5I => E5I,
				E5Q => E5Q,
				addr => addr,
				strobe_in => strobe_in,
				strobe_out => strobe_out,
				addr_new => addr_new);

		-- Clock process definitions
		clk_process :process
		begin
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end process;
		
		strobe_in <= strobe_boc_d2 and start;		
	 
		-- Stimulus process
		stim_proc: process

			-- clean output files		
			file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_10MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_10MHz.txt";			
--			file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_20MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_20MHz.txt";			
--			file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_50MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_50MHz.txt";			
--			file file_E5_I : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_100MHz.txt";file file_E5_Q : text open write_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_100MHz.txt";				
			
			begin		
				file_close(file_E5_I);
				file_close(file_E5_Q);				

				wait for 100 ns;	
				rst <= '0';
				
				wait for 0.2 ms;	
				
--				wait for clk_period*1+clk_period/2;
--				
--				addr_new <= '1';
--				wait for clk_period;	
--				addr_new <= '0';
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
						if cont_boc = L-1 then
							strobe_prn <= '1';
							cont_boc <= 0;
						end if;
					end if;
				end if;
			end process;		
		
		-- Read process
		process (clk)
		
			variable buff_E5aI, buff_E5bI, buff_E5aQ, buff_E5bQ : line;
			variable aux_E5aI, aux_E5bI, aux_E5aQ, aux_E5bQ : integer;
			
			-- Input file
			file file_E5aI  : text open read_mode is ".\matlab\testbench_excite\PRN_E5aI_1_rep5.txt";				
			file file_E5aQ  : text open read_mode is ".\matlab\testbench_excite\PRN_E5aQ_1_rep5.txt";				
			file file_E5bI  : text open read_mode is ".\matlab\testbench_excite\PRN_E5bI_1_rep5.txt";							
			file file_E5bQ  : text open read_mode is ".\matlab\testbench_excite\PRN_E5bQ_1_rep5.txt";							
			
			begin
			
				if (rising_edge(clk)) then  
					if rst = '1' then
						strobe_prn_d <= '0';
						strobe_boc_d <= '0';
						strobe_boc_d2 <= '0';
						
						PRN(0) <= '0';
						PRN(1) <= '0';
						PRN(2) <= '0';
						PRN(3) <= '0';
						
						start <= '0';
						
					else
					
						strobe_prn_d <= strobe_prn;
						strobe_boc_d <= strobe_boc;
						strobe_boc_d2 <= strobe_boc_d;						
					
						start <= start;
					
						if strobe_prn = '1' then
						
							start <= '1';
							
							readline(file_E5aI,buff_E5aI);
							read(buff_E5aI,aux_E5aI);
							
							readline(file_E5bI,buff_E5bI);
							read(buff_E5bI,aux_E5bI);

							readline(file_E5aQ,buff_E5aQ);
							read(buff_E5aQ,aux_E5aQ);								
							
							readline(file_E5bQ,buff_E5bQ);
							read(buff_E5bQ,aux_E5bQ);															

							if aux_E5aI = 1 then -- +1		
								PRN(3)<= '1';
							else							
								PRN(3)<= '0';
							end if;
							
							if aux_E5bI = 1 then -- +1		
								PRN(2)<= '1';
							else							
								PRN(2)<= '0';
							end if;
							
							if aux_E5aQ = 1 then -- +1		
								PRN(1)<= '1';
							else							
								PRN(1)<= '0';
							end if;	

							if aux_E5bQ = 1 then -- +1		
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
			
			variable buff_E5_I, buff_E5_Q : line;		
			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_10MHz.txt";file file_E5_Q : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_10MHz.txt";			
--			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_20MHz.txt";file file_E5_Q : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_20MHz.txt";			
--			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_50MHz.txt";file file_E5_Q : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_50MHz.txt";			
--			file file_E5_I : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_I_100MHz.txt";file file_E5_Q : text open append_mode is "source/GNSS_signal/sim/results/E5_signal_generator_output_Q_100MHz.txt";	
		
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