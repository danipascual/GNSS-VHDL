LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
use ieee.std_logic_textio.all;
use std.textio.all;
 
use IEEE.std_logic_unsigned.all; -- per les sumes
use ieee.numeric_std.all; --to_signed, etc

use IEEE.math_real.all; --funcions matematiques
 
ENTITY E1_generator_tb IS
END E1_generator_tb;
 
ARCHITECTURE behavior OF E1_generator_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT E1_generator
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         E1B : OUT  std_logic;
         E1C : OUT  std_logic;
         ENABLE : IN  std_logic;
         valid_out : OUT  std_logic;
         epoch : OUT  std_logic;
			SAT : in integer range 0 to 26);
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal ENABLE : std_logic := '1';
	signal SAT : integer range 0 to 26 := 0;

 	--Outputs
   signal E1B : std_logic;
   signal E1C : std_logic;
   signal valid_out : std_logic;
   signal epoch : std_logic;
	
   -- Clock period definitions
   constant clk_period : time := 5 ns;
 
BEGIN
 
   uut: E1_generator 
		PORT MAP (clk => clk,
          rst => rst,
          E1B => E1B,
          E1C => E1C,
          ENABLE => ENABLE,
          valid_out => valid_out,
          epoch => epoch,
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
   begin		
      wait for 100 ns;	
		rst<='0';
		
		-- Disable/Enable
		wait for clk_period*1000*5;
		ENABLE <= '0';
		wait for clk_period*100;
		ENABLE <= '1';
		
		-- Change satellite
		wait for clk_period*1000*2;
		rst <= '1';
		SAT <= 1;
		wait for clk_period*2;
		rst <= '0';	

		wait for clk_period*1000*10;
		ENABLE <= '0';
		wait;
   end process;
	
   process
		--clean output file									
		file file_prn_B : text open write_mode is "GNSS_prn/sim/results/E1_generator_output_B.txt";
		file file_prn_C : text open write_mode is "GNSS_prn/sim/results/E1_generator_output_C.txt";

			begin		
				file_close(file_prn_B);	
				file_close(file_prn_C);	
				wait;
		end process;	

	writing_process : process (clk)
		variable buff_prn_B, buff_prn_C : line;
		file file_prn_B : text open append_mode is "GNSS_prn/sim/results/E1_generator_output_B.txt";
		file file_prn_C : text open append_mode is "GNSS_prn/sim/results/E1_generator_output_C.txt";
		
		begin
			if (rising_edge(clk)) then  
			 if (valid_out = '1') then
				write(buff_prn_B, E1B); 
				writeline(file_prn_B, buff_prn_B);	
				
				write(buff_prn_C, E1C); 
				writeline(file_prn_C, buff_prn_C);					
			 end if;
			end if;
	end process;	

END;
