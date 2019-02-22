--------------------------------------------------------------------------------------
-- This block gives 2 outputs:
-- 1) The value of the BOC sequence "t", whith original rate M, sub/over-sampled at N
--	2) The value of the above sampled sequence for a given PRN address.
--
-- Design requirements for both outputs:
--	1) The PRNs MUST be generated at their original rate (X)
--
-- Design requirmments for second output:
-- 2) The desired rate (N) must be multiple of the PRN original rate (X).
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- **** INPUTS ****
-- addr_coded  --> index of "t"
-- addr_ref --> PRN reference address
-- 	
-- **** OUTPUTS  ****
-- addr_decoded  --> t(addr_coded)
-- addr_ref_decoded --> Value of "t" for this PRN address
-- addr_ref_coded --> Index of addr_ref_decoded inside "t"
--------------------------------------------------------------------------------------
-- 											THEORY
--
-- M  		Nominal BOC rate
--	L0 		Lenght of the unsampled BOC sequence
--	X  		Nominal PRN rate (is the requested as well!)
--	L_X 		Lenght of the unsampled PRN sequence
--	N			Requested BOC rate

-- Fixed values:
-- 		E1OS	E5
--	M		12		120
--	L0		12		8
-- X		1		10
--	L_X	4092	10230
--
-- The sampled BOC sequence is:
-- **********************************************
-- * t = mod( floor(ro*M/N) ,L0)  ro = 0..L_N-1 *
-- **********************************************
--	where
--	L_N 		Lenght of the "t" sequence in period of N
--				L_N = L_M*P/T
--	where	
--				P = N/gcd(M,N)
-- and
--	L_M 		Lenght of the "t" sequence in period of M
--				L_M = lcm(T,L0)
--	where  
--				T = M/gcd(M,N)
-- T/P  is the irreducible fraction of M/N
--
-- The index of "t", for given PRN address is
-- ******************************************************
-- * indx = mod(floor(A_REF'*[(L_X/X)/(L0/M)/L_X]*L_N),L_N) *
--	* A_REF' = mod(A_REF,T_X) A_REF = 0.. L_X-1			  *
-- ******************************************************
-- where
--	T_X		The repetition period of "t" in PRN chips
--				T_x = lcm(L_M,L_M0)*X/M, 
--	where 
--	L_M0 = L_M when N = M
--------------------------------------------------------------------------------------
-- 											OBSERVATIONS
--
-- I believe, it can be further improved so as to remove the above requirements.
--
-- This block can be used also to sample PRNs (i.e. signals without BOC)
-- For PRNS at X = 1 (L1 C/A and the PRNs of E1) it's much easier
-- For the other PRNS (L5 and the PRNs of E5), it would use a lot of resources using this method
-- i recoomend to sample them to a multple of X (10, in both cases) wich would be easier.
--
--	The above equations may be synthesized with many LUTs, which may not XXX with
--	the desired rate. I have implemented them in 3 steps and clock so as to make sure that
--	they can be fast enought. But that would depend on the chip speed, etc.
--	I made it sync with clock, Xilinx ISE syntethize it with a RAM. If not, it may 
--	use a lot of LUTs and limite the rate. You coun change this program and do step by step
--------------------------------------------------------------------------------------
-- Diary:	09/01/2018	Start 
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

entity addr_decoder is
--	Generic(M : integer := 120;	-- Example E5 50 MSps
--		L0 : integer := 8;			
--		X : integer := 10;			
--		L_X : integer := 10230;		
--		N : integer := 50;			
--		L_M : integer := 24;			
--		L_N : integer := 10;			
--		L_M_log : integer := 5;	
--		L0_log : integer := 3;	
--		T_x : integer := 2);			
	Generic(M : integer := 12;		-- Example E1OS 50 MSps
		L0 : integer := 12;			
		X : integer := 1;			
		L_X : integer := 4092;		
		N : integer := 50;			
		L_M : integer := 12;			
		L_N : integer := 50;			
		L_M_log : integer := 4;		
		L0_log : integer := 4;
		T_x : integer := 2);			
	Port (clk : in STD_LOGIC;
		addr_coded : in integer range 0 to L_N-1;								
		addr_decoded : out std_logic_vector(L0_log-1 downto 0);				
		addr_ref : in integer range 0 to L_X-1;							
		addr_ref_decoded : out std_logic_vector(L0_log-1 downto 0);
		addr_ref_coded : out integer range 0 to L_N-1);
end addr_decoder;

architecture Behavioral of addr_decoder is

	-- The sub-sampled "t" sequence -------------------------------------------
	type t_array is array (0 to L_N-1) of std_logic_vector(L0_log-1 downto 0);
	
	function compute_t return t_array is
		variable t : t_array;
		
		begin
			for j in 0 to L_N-1 loop
				t(j) := std_logic_vector(to_unsigned(integer((floor(real(j)*real(M)/real(N))) mod (real(L0))),L0_log));	
			end loop;			
			
			return t;
	end compute_t;	
	
	signal t : t_array := compute_t;		
	
	-- The reference address modulus T_X --------------------------------------	
	type aref_array is array (0 to L_X-1) of integer range 0 to T_X-1;
	
	function compute_aref return aref_array  is
		variable aref : aref_array;
		
		begin
			for j in 0 to L_X-1 loop
				aref(j) := integer(real(j) mod (real(T_X)));
			end loop;
		
			return aref;
	end compute_aref; 	
	
	signal aref : aref_array  := compute_aref; 	
	
	-- The INDEX of the sub-sampled "t" sequence when a new address is set ----
	type idx_array is array (0 to T_X-1) of integer range 0 to L_N-1;
	
	function compute_idx return idx_array  is
		variable idx : idx_array;
		
		begin
			for j in 0 to T_X-1 loop
				idx(j) := integer(((real(j)*(((real(L_X)/real(X))/(real(L0)/real(M)))/real(L_X))*real(L_N)) mod (real(L_N))));
			end loop;
		
			return idx;
	end compute_idx; 	
	
	signal idx : idx_array := compute_idx; 
	-----------------------------------------------------------------------------------------

	begin
--		addr_decoded <= t(addr_coded);
--		addr_ref_decoded <= t(idx(compute_aref(addr_ref)));
		
		process(clk)
			begin
				if (rising_edge(clk)) then		
					addr_decoded <= t(addr_coded);
					addr_ref_decoded <= t(idx(compute_aref(addr_ref)));
					addr_ref_coded <= idx(compute_aref(addr_ref));
				end if;
		end process;		
end Behavioral;