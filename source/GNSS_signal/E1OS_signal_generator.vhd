--------------------------------------------------------------------------------------
--	
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- **** INPUTS ****
-- PRN: PRN(0) = E1C, PRN(1) = E1B
-- enable --> Freeze everything when '0'
-- strobe_in --> "t" sequence generation strobe
-- addr_new --> New address set
-- N --> The sampling frequency (x 1.023 MHz) (i.e. the "t" frequency), not to be 
--	      confused with the PRN frequency.
--
-- **** OUTPUTS  ****
-- E1OS --> Signal
-- valid_out --> Signal valid
-- strobe_out --> New output sample
--------------------------------------------------------------------------------------
-- 											THEORY
-- Create the E1OS signal with the CBOC(6,1,1/11) modulation with E1B and E1C codes:
--
-- E1OS = E1B*(b*BOCs(6,1)+a*BOCs(1,1)) - E1C*(-b*BOCs(6,1)+a*BOCs(1,1))
-- where a = sqrt(10/11), b = sqrt(1/11), and BOCs(X,Y) is a sine-phased BOC signal
-- with a sub-carrier rate S and a PRN chip frequency U:
-- BOCs(S,U) = sign(sin(2 pi S t)), and with the exception that sign(0) = 1. 
-- 
-- It can be computed with the next loop-up table
-- E1B   1		1		0		0
-- E1C	1		0		1		0
-- t
-- 0		2b		2a		-2a	-2b
-- 1		-2b	2a		-2a	2b			
-- 2		2b		2a		-2a	-2b	
-- 3		-2b	2a		-2a	2b
-- 4		2b		2a		-2a	-2b
-- 5		-2b	2a		-2a	2b
-- 6		2b		-2a	2a		-2b		
-- 7		-2b	-2a	2a		2b
-- 8		2b		-2a	2a		-2b
-- 9		-2b	-2a	2a		2b
-- 10		2b		-2a	2a		-2b
-- 11		-2b	-2a	2a		2b
--
-- where a=1 and b=1/sqrt(10), t=mod(T,12), and T=mod(adress,4092)
-- With 8 bits- -> 2a=127, -2a= -127, 2b= 40, 2b=-40. (error of 0.4% in 2b)
--------------------------------------------------------------------------------------
-- Diary:	10/06/2016	Start 
--				20/07/2016 	Version 1.0	Dani --> The PRNs MUST be generated at 1*1.023MHz
--															I am not sure about the behaviour if not
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
use ieee.numeric_std.all; 			-- to_signed, etc
use IEEE.std_logic_signed.all; 	-- additions
use IEEE.math_real.all; 			-- maths

entity E1OS_signal_generator is
		Generic(Width : integer := 8;			-- Output width
				N : integer := 50);		
		Port (clk : in STD_LOGIC;
			rst	: in STD_LOGIC;
			PRN : in STD_LOGIC_VECTOR(2-1 downto 0);	-- PRN(1) = E1B, PRN(0)= E1C
			E1OS : out STD_LOGIC_VECTOR(Width-1 downto 0);
			addr : in integer range 0 to 4092-1;
			strobe_in : in std_logic;
			strobe_out : out std_logic;
			addr_new : in std_logic);			
end E1OS_signal_generator;

architecture Behavioral of E1OS_signal_generator is

	-- Signals
	signal t, t_d, t_new, t_regular:  std_logic_vector(4-1 downto 0);
	signal PRN_d, PRN_d2, PRN_d3, PRN_d4 : STD_LOGIC_VECTOR(2-1 downto 0);
	
 	signal strobe_in_d, strobe_in_d2, strobe_in_d3, strobe_in_d4 : std_logic;

	-- Power constants
	constant alfa2_integer : integer := 2**(Width-1)-1; --127
	constant beta2_real : real :=  sqrt(real(1)/real(10));
	constant beta2_integer : integer := integer(beta2_real *real(alfa2_integer));
	signal alfa2: std_logic_vector (Width-1 downto 0)  := STD_LOGIC_VECTOR(to_unsigned(alfa2_integer,Width));
	signal beta2:  std_logic_vector (Width-1 downto 0)  := STD_LOGIC_VECTOR(to_unsigned(beta2_integer,Width));
	
	-- E5 signal parameters
	constant M : integer := 12;
	constant L0 : integer := 12;
	constant X : integer := 1;
	constant L_X : integer := 4092;		
	
	-- The sampled "t" stuff
	function gcd(a : integer; b : integer) return integer is -- Greatest common divisor
		variable r : integer;
		
		begin
			if b=0 then
				r := a;
			else
				r := gcd(b,integer(real(a) mod real(b)));
			end if;
		
			return r;
	end gcd;	
	
	function lcm(a : integer; b: integer) return integer is -- Least common multiple
		variable r : integer;
		
		begin
			r := integer(real(a*b)/real(gcd(a,b)));
			return r;
	end lcm;	

	constant TT : integer := integer(real(M)/real(gcd(M,N)));			-- Maybe evertyhing works better with reals?
	constant P : integer := integer(real(N)/real(gcd(M,N)));
	
	constant L_M : integer := lcm(TT,L0);
	constant L_N : integer := integer(real(L_M)*(real(P)/(real(TT))));
	
	constant L_M_log : integer := integer(ceil(log2(real(L_M))));
	constant L0_log : integer := integer(ceil(log2(real(L0))));
	
	constant T0 : integer := integer(real(M)/real(gcd(M,M)));
	constant L_M0 : integer := lcm(T0,L0);
	constant T_x : integer := integer(real(lcm(L_M,L_M))*real(X)/real(M));   
	
	signal cont, cont_new : integer range 0 to L_N-1;	
	signal aux : std_logic;
	-----------------------------------------------------------------------------------		
	
	
	component addr_decoder is
		Generic(M : integer := 120;
			L0 : integer := 8;			
			X : integer := 10;			
			L_X : integer := 10230;		
			N : integer := 50;			
			L_M : integer := 24;			
			L_N : integer := 10;			
			L_M_log : integer := 5;		
			L0_log : integer := 3;	
			T_x : integer := 2);			
		Port (clk : in STD_LOGIC;
			addr_coded : in integer range 0 to L_N-1;								
			addr_decoded : out std_logic_vector(L0_log-1 downto 0);				
			addr_ref : in integer range 0 to L_X-1;							
			addr_ref_decoded : out std_logic_vector(L0_log-1 downto 0);
			addr_ref_coded : out integer range 0 to L_N-1);	
	end component;

	begin
	
		addr_decoder_inst : addr_decoder
			Generic map(M => M,
				L0 => L0,			
				X => X,	
				L_X => L_X,
				N => N,		
				L_M => L_M,			
				L_N => L_N,		
				L_M_log => L_M_log,
				L0_log => L0_log,
				T_x => T_x)
			Port map(clk => clk,
				addr_coded => cont,						
				addr_decoded => t_regular,			
				addr_ref => addr,						
				addr_ref_decoded => t_new,
				addr_ref_coded => cont_new);		
	
		process(clk)
			begin
				if (rising_edge(clk)) then		
					if (rst = '1') then
						E1OS <= (others => '0');

						strobe_out <= '0';
						strobe_in_d  <= '0';	
						strobe_in_d2  <= '0';
						strobe_in_d3   <= '0';
						strobe_in_d4  <= '0';
						
						t <= (others => '0');
						t_d <= (others => '0');
						aux <= '0';
						
						cont <= L_N-1;
						
						PRN_d <= (others => '0');
						PRN_d2  <= (others => '0');
						PRN_d3 <= (others => '0');
						PRN_d4 <= (others => '0');
						
					else
					
						PRN_d <= PRN;
						PRN_d2 <= PRN_d;
						PRN_d3 <= PRN_d2;
						PRN_d4 <= PRN_d3;
						
						strobe_in_d <= strobe_in;
						strobe_in_d2 <= strobe_in_d;
						strobe_in_d3 <= strobe_in_d2;
						strobe_in_d4 <= strobe_in_d3;
						strobe_out <= strobe_in_d4;

						if addr_new = '0' then
							t <= t_regular;
							
							if strobe_in = '1' then
								if cont = L_N-1 then
									cont <= 0;
								else
									cont <= cont+1;
								end if;
							end if;	
							
						else					-- addr_new is sync with strobe_in
							t <= t_new;
							cont <= cont_new;
						end if;

						-- Create signal 
						-- Done in two steps to allow fast rates, but maybe it needs to be done with three
						-- Xilinx doesn't like the comparison with 6
						t_d <= t;
						if  (unsigned(t) < 6) then
							aux <= '0';
						else
							aux <= '1';
						end if;

						if (PRN_d4(0) = not PRN_d4(1)) then  --"10" or "01"
							if  (aux='0') then
								if (PRN_d4(0) = '1') then
									E1OS <= -alfa2; 
								else
									E1OS <= alfa2; 
								end if;
							else
								if (PRN_d4(0) = '1') then
									E1OS <= alfa2; 
								else
									E1OS <= -alfa2; 
								end if;
							end if;
						else --"11" or "00"
							if PRN_d4(0) = '1' then
								if t_d(0) = '0' then 
									E1OS <= beta2;
								else
									E1OS <= -beta2;
								end if;
							else
								if t_d(0) = '0' then 
									E1OS <= -beta2;
								else
									E1OS <= beta2;
								end if;
							end if;
						end if;
					end if; --rst
				end if; --clk
		end process;					
end Behavioral;