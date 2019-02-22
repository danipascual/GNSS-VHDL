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
use ieee.numeric_std.all; 			-- to_signed, etc
use IEEE.std_logic_signed.all; 	-- additions
use IEEE.math_real.all; 			-- maths

ENTITY addr_decoder_tb IS
END addr_decoder_tb;
 
ARCHITECTURE behavior OF addr_decoder_tb IS 

	-- E5 at a sampling rate 50
	constant M : integer := 120;
	constant	L0 : integer := 8;
	constant X : integer := 10;
	constant L_X : integer := 10230;		
	constant	N : integer := 50;	
	constant L_M : integer := 24;				
	constant L_N : integer := 10;	
	constant L_N_log : integer := 4;	 	
	constant L_M_log : integer := 5;	 
	constant L_X_log : integer := 14;	
	constant L0_log : integer := 3;
	constant T_X : integer := 2;	 
	
	-- E1OS at a sampling rate 50
--	constant M : integer := 12;
--	constant	L0 : integer := 12;
--	constant X : integer := 1;
--	constant L_X : integer := 4092;		
--	constant	N : integer := 50;	
--	constant L_M : integer := 12;				
--	constant L_N : integer := 50;
--	constant L_N_log : integer := 6;	 				
--	constant L_M_log : integer := 4;	 
--	constant L_X_log : integer := 12;
--	constant L0_log : integer := 4;
--	constant T_X : integer := 2;	 	
 
   COMPONENT addr_decoder
		Generic(M : integer := M;
			L0 : integer := L0;
			X : integer := X;
			L_X : integer := L_X;		
			N : integer := N;
			L_M : integer := L_M;				
			L_N : integer := L_N;				
			L_M_log : integer := L_M_log;
			L0_log : integer := L0_log;
			T_X : integer := T_X);		
		Port (clk : in STD_LOGIC;
			addr_coded : in integer range 0 to L_N-1;			
--			addr_coded : in std_logic_vector(L_N_log-1 downto 0);
			addr_decoded : out std_logic_vector(L0_log-1 downto 0);
			addr_ref : in integer range 0 to L_X-1;							
--			addr_ref : in  std_logic_vector(L_X_log-1 downto 0);					
			addr_ref_decoded : out std_logic_vector(L0_log-1 downto 0));	
    END COMPONENT;
    
   --Inputs
   signal addr_coded : integer range 0 to L_N-1 := 0;
--	signal addr_coded : std_logic_vector(L_N_log-1 downto 0):=(others => '0');
   signal addr_ref : integer range 0 to L_X-1 := 0;
--	signal addr_ref :  std_logic_vector(L_X_log-1 downto 0):=(others => '0');
	signal clk : std_logic := '0';

 	--Outputs
   signal addr_decoded : std_logic_vector(L0_log-1 downto 0);
   signal addr_ref_decoded :std_logic_vector(L0_log-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 5 ns; -- 200 MHz
	
	constant XX : integer := integer(real(200)/real(N))-1;
	signal start_strobe : std_logic := '0';	
	signal strobe, strobe_sync  : std_logic := '0';	
	
	BEGIN
 
		uut: addr_decoder 
			Generic map(M => M,
				L0  => L0,
				X => X,
				L_X => L_X,
				N  =>N ,
				L_M  => L_M,
				L_N  =>L_N,	
				L_M_log  => L_M_log,
				L0_log => L0_log,
				T_X  => T_X)
			PORT MAP (clk => clk,
				addr_coded => addr_coded,
				addr_decoded => addr_decoded,
				addr_ref => addr_ref,
				addr_ref_decoded => addr_ref_decoded);
				
		-- Clock process definitions
		clk_process :process
		begin
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end process;	
		
		stim_proc: process
			begin		
				wait for 200 ns;	
				start_strobe <= '1';
				wait;
		end process;			

		process
			begin
				strobe <= '1';
				wait for clk_period;
				strobe <= '0';
				wait for XX*clk_period;
				strobe <= '0';
		end process;	

		process (clk)
			begin
				if (rising_edge(clk)) then
					if (start_strobe='1') then
						strobe_sync <= strobe;
					else
						strobe_sync <= '0';
					end if;
				end if;
			end process;		
		
		process (clk)
			begin
				if (rising_edge(clk)) then
					if (strobe_sync = '1') then
						if addr_coded = L_N-1 then
							addr_coded <= 0;
--							addr_coded <= (others => '0');
						else
							addr_coded <= addr_coded+1;
						end if;
					end if;
				end if;
			end process;	
			
		process (clk)
			begin
				if (rising_edge(clk)) then
					if (strobe_sync = '1') then
						if addr_ref = L_X-1 then
							addr_ref <= 0;
--							addr_ref <= (others => '0');
						else
							addr_ref <= addr_ref+1;
						end if;
					end if;
				end if;
			end process;				
END;