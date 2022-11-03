library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity craps is
port (rst, clk_in, key: in std_logic;
		slow_clk: out std_logic); -- slow_clk is the slowed down clock
end craps;

architecture rtl of craps is
begin
	
	signal key_clean: std_logic := '0'; -- Holds the clean key press. (Cleaned using negative edge detection)
	
	craps_nextStateLogic_p: process(currentState, key)
	begin
	
	end process craps_nextStateLogic_p;
	
	craps_DFlipFlop: process(slow_clk_in, reset)
	begin
	
	end process craps_DFlipFlop;
	
	craps_outputLogic_p: process(currentState, nextState)
	begin
	
	end process craps_outputLogic_p;
	
	
	craps_negEdgeDetect: process(slow_clk_in, key) -- detects negative edges of the key (debouncer)
	 variable sigA: std_logic;
	 variable sigB: std_logic;
	 begin
		sigA := key;
		if (rising_edge(slow_clk_in)) then
			sigB := key; 
		end if;
		key_clean <= not sigA and sigB;
	end process craps_negEdgeDetect;
	 
end rtl;