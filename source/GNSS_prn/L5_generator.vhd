--------------------------------------------------------------------------------------
-- L5 I and Q PRN Generator (1 bit outputs). 
--
-- All vectors are reversed as they appear in the ICD document (IS-GPS-705).
-- Both PRNs are generated with 2 LSFRs of 13 registers. One LSFR (XA) is shared 
-- between both PRNs, so three different LSFRs are used. All taps and phases are fixed
-- for all satellites for all LSFRs. The shared LSFR has a fixed seed for all 
-- satellites. The other two LSFR (XBI and XBQ) have different seeds for each
-- satellite. The shared LSFR is restarted 1 chip before its natural end. All the LSFRs
-- are restarted every 10230 clocks.
--
-- XA: 8191 chips lenght (actually is 8192 but is short cycled 1-chip before).
-- XBI, XBQ: 8192 chips lenght.
-- PRN I, Q: 10230 chips lenght.
--
--	Reset MUST be asserted during 2 clocks.
-- Satellite MUST be fixed during reset.
--	Satellite will be fix until next reset.
--------------------------------------------------------------------------------------
-- **** INPUTS ****
-- sat --> Sat number: 
--			0 = PRN 1, 1 = PRN 2,...,31 = PRN 32
-- enable --> freeze
--
-- **** OUTPUTS  ****
-- prn_i, prn_q  --> PRN signals
-- valid --> PRNs valid
-- epoch --> PRNs repeat
--------------------------------------------------------------------------------------
-- Diary:	05/12/2014	Start 
--				06/06/2016	Version 1.0	Dani
--				08/11/2016	Minor changes
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
use ieee.std_logic_signed.all;	-- additions
use ieee.numeric_std.all; 			-- to_signed
entity L5_generator is
	Port (clk : in STD_LOGIC;
			rst	: in STD_LOGIC;		-- signal to start	
			PRN_I : out STD_LOGIC;		-- 1 bit output
			PRN_Q : out STD_LOGIC;		-- 1 bit output
			ENABLE : in STD_LOGIC;		-- enable
			valid_out : out STD_LOGIC;	-- output valid
			epoch : out STD_LOGIC;		-- PRN repeated
			SAT : in integer range 0 to 31);	 -- 32 GPS
end L5_generator;

architecture Behavioral of L5_generator is

	signal seed_xbi	: std_logic_vector (12 downto 0); -- seed for LSFR XBI
	signal seed_xbq	: std_logic_vector (12 downto 0); -- seed for LSFR XBQ	
	signal xa_out	: std_logic;
	signal xbi_out	: std_logic;
	signal xbq_out	: std_logic;
	signal LSFR_valid : std_logic;	-- just one needed because they are sync
	signal ENABLE_LSFR : std_logic;
	signal cont_epoch : integer range 0 to 10229;	-- PRN period of 10230 clocks	

	begin

		XA_gen : entity work.LFSR_generator(Behavioral)
			generic map(WIDTH => 13,
				WIDTH_CMP => 14)
			port map(clk => clk,
				rst => rst,
				seed	=> "1111111111111",		-- fixed seed for all PRNs
				tap => "1101100000000",			-- fixed seed for all PRNs
				RESET => "1011111111111",		-- fixed seed for all PRNs
				output => "1000000000000",		-- just last one
				SEQ => xa_out,
				count_cmp => "10011111110101", -- 10230-1
				ENABLE => ENABLE_LSFR,
				valid => LSFR_valid);		

		XBI_gen : entity work.LFSR_generator(Behavioral)
			generic map(WIDTH => 13,
				WIDTH_CMP => 14)			
			port map(clk => clk,
				rst => rst,
				seed	=> seed_xbi,				-- different for each PRN
				tap => "1100011101101",			-- fixed for all PRNs
				RESET => "0000000000000",		-- no reset
				output => "1000000000000",		-- just last one
				SEQ => xbi_out,
				count_cmp => "10011111110101", -- 10230-1
				ENABLE => ENABLE_LSFR,
				valid => open);					-- the LSFRs are sync

		XBQ_gen : entity work.LFSR_generator(Behavioral)
			generic map(WIDTH => 13,
				WIDTH_CMP => 14)			
			port map(clk => clk,
				rst => rst,
				seed	=> seed_xbq,				-- different for each PRN
				tap => "1100011101101",			-- fixed for all PRNs
				RESET => "0000000000000",		-- no reset
				output => "1000000000000",		-- just last one
				SEQ => xbq_out,
				count_cmp => "10011111110101", -- 10230-1
				ENABLE => ENABLE_LSFR,
				valid => open);					-- the LSFRs are sync
				
		proc: process(clk)
			begin
				if (rising_edge(clk)) then
					if (rst = '1') then

						-- Outputs
						PRN_I <= '0';
						PRN_Q <= '0';
						valid_out <= '0';	
						epoch <= '0';	
						
						-- LSFR inputs
						ENABLE_LSFR <= '0';
						
						-- aux
						cont_epoch <= 10230-1;	
						
						-- Seeds for XBI and XBQ
						CASE SAT IS
							WHEN 0 => 
								seed_xbi	<= "0010011101010";
								seed_xbq	<= "0011001101001";			
							WHEN 1 => 
								seed_xbi	<= "1010110000011";
								seed_xbq	<= "0110111100010";
							WHEN 2 => 
								seed_xbi	<= "0001000000010";
								seed_xbq	<= "1100010001111";
							WHEN 3 => 
								seed_xbi	<= "0110010001101";
								seed_xbq	<= "0101011011100";
							WHEN 4 => 
								seed_xbi	<= "1110101110111";
								seed_xbq	<= "0100110111100";
							WHEN 5 => 
								seed_xbi	<= "0101111100110";
								seed_xbq	<= "1001010101010";
							WHEN 6 => 
								seed_xbi	<= "1111100100101";
								seed_xbq	<= "1000000111111";
							WHEN 7 => 
								seed_xbi	<= "0010010111101";
								seed_xbq	<= "0001011010110";
							WHEN 8 => 
								seed_xbi	<= "1101010011111";
								seed_xbq	<= "1100001011101";
							WHEN 9 => 
								seed_xbi	<= "0111101111110";
								seed_xbq	<= "0110000100100";
							WHEN 10 => 
								seed_xbi	<= "0101110010000";
								seed_xbq	<= "1010000001000";
							WHEN 11 => 
								seed_xbi	<= "1001111100111";
								seed_xbq	<= "1010001101010";
							WHEN 12 => 
								seed_xbi	<= "0011100111000";
								seed_xbq	<= "1010010110010";
							WHEN 13 => 
								seed_xbi	<= "1110010000010";
								seed_xbq	<= "1111110000101";
							WHEN 14 => 
								seed_xbi	<= "0101101010110";
								seed_xbq	<= "1111000111101";
							WHEN 15 => 
								seed_xbi	<= "1001001111000";
								seed_xbq	<= "1111101001011";
							WHEN 16 => 
								seed_xbi	<= "1111000110010";
								seed_xbq	<= "0001001100111";
							WHEN 17 => 
								seed_xbi	<= "0111100001111";
								seed_xbq	<= "0010011101101";
							WHEN 18 => 
								seed_xbi	<= "1111100010011";
								seed_xbq	<= "1101101001100";
							WHEN 19 => 
								seed_xbi	<= "1011011010110";
								seed_xbq	<= "1000111000011";
							WHEN 20 => 
								seed_xbi	<= "0001000000100";
								seed_xbq	<= "0000100110110";
							WHEN 21 => 
								seed_xbi	<= "1111011110111";
								seed_xbq	<= "0111000110100";
							WHEN 22 => 
								seed_xbi	<= "0111111100001";
								seed_xbq	<= "1011111010001";
							WHEN 23 => 
								seed_xbi	<= "0010110100011";
								seed_xbq	<= "1100111110110";
							WHEN 24 => 
								seed_xbi	<= "1011011001011";
								seed_xbq	<= "1101100100010";
							WHEN 25 => 
								seed_xbi	<= "0110100110101";
								seed_xbq	<= "0011110101010";
							WHEN 26 => 
								seed_xbi	<= "0111101101010";
								seed_xbq	<= "0101111100001";
							WHEN 27 => 
								seed_xbi	<= "0110101011110";
								seed_xbq	<= "0100001011111";
							WHEN 28 => 
								seed_xbi	<= "1000011111010";
								seed_xbq	<= "0010010001010";
							WHEN 29 => 
								seed_xbi	<= "1110110100001";
								seed_xbq	<= "1001111000001";
							WHEN 30 => 
								seed_xbi	<= "0111100101000";
								seed_xbq	<= "1010011111010";
							WHEN 31 => 
								seed_xbi	<= "1001110100000";
								seed_xbq	<= "0101010001001";
							WHEN OTHERS =>  
								seed_xbi <= (others =>'0');
								seed_xbq <= (others =>'0');						
						END CASE;

					else 
						  
						ENABLE_LSFR <= ENABLE;
						epoch <= '0';
						
						-- Create PRN
						PRN_I <= xa_out xor xbi_out;
						PRN_Q  <= xa_out xor xbq_out;													
						valid_out <= LSFR_valid;			

						-- Counter epoch
						if LSFR_valid = '1' then
							if cont_epoch = 10230-1 then
								cont_epoch <= 0;
								epoch <= '1';
							else
								cont_epoch <= cont_epoch+1;							
								epoch<= '0';
							end if;
						end if;	
					end if; --reset
				end if; --clock
		end process proc;		
end Behavioral;