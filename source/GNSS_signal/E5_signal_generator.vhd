--------------------------------------------------------------------------------------
--	
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- **** INPUTS ****
-- PRN: PRN(3) = E5aI, PRN(2)= E5aQ, PRN(1) = E5bI, PRN(0) = E5bQ
-- addr --> Address of the PRNs
-- strobe_in --> "t" sequence generation strobe
-- N --> The sampling frequency (x 1.023 MHz) (i.e. the "t" frequency), not to be 
--	      confused with the PRN frequency.
--	addr_new --> synced with PRN
--
-- **** OUTPUTS  ****
-- E5I,E5Q --> Signal
-- valid --> Signal valid
-- strobe_out --> New output sample
--------------------------------------------------------------------------------------
-- 											THEORY
-- Create the E5 signal with the constant envelope AltBOC(15,10) modulation with the
-- E5aI, E5aQ, E5bI, E5bQ codes. The subcarrier signals have a rate Fb = Y*1.023 MHz
-- (Y = 15), and the codes Fc = X*1.023 MHz(X=10).
--
-- E5I = (E5aI+E5bI)*sd(t)+
--       (E5aQ-E5bQ)*sd(t-Tb/4)+
--       (E5aI*+E5bI*)*sp(t)+
--       (E5aQ*-E5bQ*)*sp(t-Tb/4).
-- E5Q = (E5aQ+E5bQ)*sd(t)+
--       (-E5aI+E5bI)*sd(t-Tb/4)+
--       (E5aQ*+E5bQ*)*sp(t)+
--       (-E5aI*+E5bI*)*sp(t-Tb/4).
--
-- where Tb is the period of the subcarrier = 1/Fb, and with
-- sd(t) = sqrt(2)/4*sign(cos(2 pi Fb t - pi/4 ))+0.5*sign(cos(2 pi Fb t))+sqrt(2)/4*sign(cos(2 pi Fb t + pi/4))
-- sp(t) = -sqrt(2)/4*sign(cos(2 pi Fb t - pi/4 ))+0.5*sign(cos(2 pi Fb t))-sqrt(2)/4*sign(cos(2 pi Fb t + pi/4))
-- 
-- The combination of these sequences result in 8 different values. E5I/E5Q can be 
-- created with the next loop-up table:
--
-- aI	0		0		0		0		0		0		0		0		1		1		1		1		1		1		1		1
-- bI	0		0		0		0		1		1		1		1		0		0		0		0		1		1		1		1
-- aQ	0		0		1		1		0		0		1		1		0		0		1		1		0		0		1		1
-- bQ	0		1		0		1		0		1		0		1		0		1	
-- t
-- 0  4     3     3     2     5     2     0     1     5     4     6     1     6     7     7     0
-- 1  4     3     7     2     1     2     0     1     5     4     6     5     6     3     7     0
-- 2  0     3     7     6     1     2     0     1     5     4     6     5     2     3     7     4
-- 3  0     7     7     6     1     2     0     5     1     4     6     5     2     3     3     4
-- 4  0     7     7     6     1     6     4     5     1     0     2     5     2     3     3     4
-- 5  0     7     3     6     5     6     4     5     1     0     2     1     2     7     3     4 
-- 6  4     7     3     2     5     6     4     5     1     0     2     1     6     7     3     0
-- 7  4     3     3     2     5     6     4     1     5     0     2     1     6     7     7     0
--
-- E5I/E5Q are then obtained with
-- 0 = a/a
-- 1 = 1/0
-- 2 = -a/a
-- 3 = 0/-1
-- 4 = -a/-a
-- 5 = -1/0
-- 6 = a/-a
-- 7 = 0/1
--
-- where a=sqrt(2)/2.  With 8 bits- -> a=90 (error of 0.22%)
--------------------------------------------------------------------------------------
-- 											OBSERVATIONS
--
-- I orginally tried a single look-up table instead of two, but Xilinx used an
-- unnecessary RAM18K.
--------------------------------------------------------------------------------------
-- Diary:	11/06/2016	Start 
--				20/07/2016 	Version 1.0	Dani --> The PRNs MUST be generated at 10*1.023MHz
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

entity E5_signal_generator is
		Generic(Width : integer := 8; -- Output width
				N : integer := 50);
		Port (clk : in STD_LOGIC;
			rst	: in STD_LOGIC;
			PRN : in STD_LOGIC_VECTOR(4-1 downto 0);	-- PRN(3) = E5aI, PRN(2)= E5bI, PRN(1) = E5aQ, PRN(0) =E5bQ
			E5I : out STD_LOGIC_VECTOR(Width-1 downto 0);
			E5Q : out STD_LOGIC_VECTOR(Width-1 downto 0);
			addr : in integer range 0 to 10230-1;	
			strobe_in : in std_logic;
			strobe_out : out std_logic;
			addr_new : in  std_logic);
end E5_signal_generator;

architecture Behavioral of E5_signal_generator is

	-- Signals
	signal DECOD : STD_LOGIC_VECTOR(3-1 downto 0);
	signal t, t_new, t_regular: std_logic_vector(3-1 downto 0);
	
	signal PRN_d, PRN_d2, PRN_d3, PRN_d4, PRN_d5  : std_logic_vector(4-1 downto 0);	
	signal strobe_in_d, strobe_in_d2, strobe_in_d3, strobe_in_d4, strobe_in_d5, strobe_in_d6 : std_logic;
	
	-- Power constants
	constant alfa_real : real :=  sqrt(real(2))/real(2);		--sqrt(2)/2
	constant alfa_integer : integer := integer(alfa_real *real(2**(Width-1)-1));
	signal alfa: std_logic_vector (Width-1 downto 0)  := STD_LOGIC_VECTOR(to_unsigned(alfa_integer,Width));
	signal logic_one : std_logic_vector (Width-1 downto 0)  := STD_LOGIC_VECTOR(to_unsigned(2**(Width-1)-1,Width));	
	
	-- E5 signal parameters
	constant M : integer := 120;
	constant L0 : integer := 8;
	constant X : integer := 10;
	constant L_X : integer := 10230;		
	
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
					
						E5I <= (others => '0');
						E5Q <= (others => '0');
						DECOD <= (others => '0');
						
						strobe_out <= '0';
						strobe_in_d <= '0';
						strobe_in_d2 <= '0';
						strobe_in_d3 <= '0';
						strobe_in_d4 <= '0';
						strobe_in_d5 <= '0';
						strobe_in_d6 <= '0';

						cont <= L_N-1;
						
						PRN_d <=(others => '0');
						PRN_d2 <=(others => '0');
						PRN_d3 <=(others => '0');
						PRN_d4  <=(others => '0');
						PRN_d5  <=(others => '0');
						
						t <= (others => '0');
						
					else
					
						PRN_d <= PRN;  
						PRN_d2 <= PRN_d;	
						PRN_d3 <= PRN_d2;
						PRN_d4 <= PRN_d3;
						PRN_d5 <= PRN_d4;		-- sync with t
						
						strobe_in_d <= strobe_in; 		
						strobe_in_d2 <= strobe_in_d;	
						strobe_in_d3 <= strobe_in_d2; 
						strobe_in_d4 <= strobe_in_d3;
						strobe_in_d5 <= strobe_in_d4;
						strobe_in_d6 <= strobe_in_d5;
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

						-- Decode "t-PRN"
						CASE to_integer(unsigned((t & PRN_d3(3) & PRN_d3(2) & PRN_d3(1) & PRN_d3(0))))  IS 
							WHEN 6 | 15 | 22 | 31 | 32 | 38 | 48 | 54 | 64 | 73 | 80 | 89 | 105 | 111 | 121 | 127 => 
								DECOD <= "000"; 
							WHEN 7 | 11 | 20 | 23 | 36 | 39 | 52 | 56 | 68 | 72 | 88 | 91 | 104 | 107 | 119 | 123  => 
								DECOD <= "001"; 
							WHEN 3 | 5 |  19 | 21 | 37 | 44 | 53 | 60 | 74 | 76 | 90 | 92 | 99 | 106 | 115 | 122 => 
								DECOD <= "010"; 
							WHEN 1 | 2 | 17 | 29 | 33 | 45 | 61 | 62 | 77 | 78 | 82 | 94 | 98 | 110 | 113 | 114 => 
								DECOD <= "011"; 
							WHEN 0 | 9 | 16 | 25 | 41 | 47 | 57 | 63 | 70 | 79 | 86 | 95 | 96 | 102 | 112 | 118 => 
								DECOD <= "100"; 
							WHEN 4 | 8 | 24 | 27 | 40 | 43 | 55 | 59 | 71 | 75 | 84 | 87 | 100 | 103 | 116 | 120 => 
								DECOD <= "101"; 
							WHEN 10 | 12 | 26 | 28 | 35 | 42 | 51 | 58 | 67 | 69 | 83 | 85 | 101 | 108 | 117 | 124 => 
								DECOD <= "110"; 
							WHEN 13 | 14 | 18 | 30 | 34 | 46 | 49 | 50 | 65 | 66 | 81 | 93 | 97 | 109 | 125 | 126 => 
								DECOD <= "111"; 
							WHEN OTHERS => 							
								DECOD <= (others => '0');	
						end case;
						
						CASE DECOD  IS
							WHEN "000" => --1
								E5I <= alfa;
								E5Q <= alfa;
							WHEN "001" => --2
								E5I <= logic_one;
								E5Q <= (others => '0');	
							WHEN "010" => --3
								E5I <= alfa;
								E5Q <= -alfa;
							WHEN "011" => --4
								E5I <= (others => '0');	
								E5Q <= -logic_one;					
							WHEN "100" => --5
								E5I <= -alfa;
								E5Q <= -alfa;
							WHEN "101" => --6
								E5I <= -logic_one;	
								E5Q <= (others => '0');	
							WHEN "110" => --7
								E5I <= -alfa;								
								E5Q <= alfa;
							WHEN "111" => --8
								E5I <= (others => '0');	
								E5Q <= logic_one;	
							WHEN OTHERS => 		
								E5I <= (others => '0');	
								E5Q <= (others => '0');										
						end case;						
					end if; --rst
				end if; --clk
		end process;					
end Behavioral;