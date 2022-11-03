library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity craps is
port (rst, MCLK, key: in std_logic;
		slow_clk: out std_logic); -- slow_clk is the slowed down clock
end craps;

architecture rtl of craps is
-- User Defined Types
type stateType is (waitPress, pressRecieved, win, lose);

-- Signals:
signal nextState: stateType := waitPress;
signal currentState: stateType := waitPress;
signal key_clean: std_logic := '0'; -- Holds the clean key press. (Cleaned using negative edge detection)
signal firstRoll: std_logic := '0'; -- 0 if this is the first roll. If on 2nd+ roll, then 1.
signal nextGame: std_logic := '0'; -- Signal that the next game is starting (update previousSum)
signal currentSum: integer range 0 to 12;
signal previousSum: integer range 0 to 12;
	
begin
	craps_nextStateLogic_p: process(currentState)
	begin
		case currentState is
			when waitPress => 
				if (key_clean = '1') then
					nextState <= pressRecieved;
				else
					nextState <= waitPress;
				end if;
			
			when pressRecieved =>
				if (firstRoll = '1') then
					if (currentSum = 7 or currentSum = 11) then
						nextState <= win;
					elsif (currentSum = 2 or currentSum = 3 or currentSum = 12) then
						nextState <= lose;
					else -- nextGame
						nextGame <= '1';
						nextState <= waitPress;
					end if;
				else -- if this is the 2nd+ roll
					if (currentSum = previousSum) then
						nextState <= win;
					elsif (currentSum = 7) then
						nextState <= lose;
					else -- Next game
						nextGame <= '1';
						nextState <= waitPress;
					end if;
				end if;
			
			when win => -- Loop forever here
				nextState <= win;
			
			when lose => -- loop forever here
				nextState <= lose;
		
		end case;
	end process craps_nextStateLogic_p;
	
	craps_DFlipFlop: process(MCLK, rst)
	begin
	
	end process craps_DFlipFlop;
	
	craps_outputLogic_p: process(currentState, nextState)
	begin
	
	end process craps_outputLogic_p;
	
	
	craps_negEdgeDetect: process(MCLK, key) -- detects negative edges of the key (debouncer)
	 variable sigA: std_logic;
	 variable sigB: std_logic;
	 begin
		sigA := key;
		if (rising_edge(MCLK)) then
			sigB := key; 
		end if;
		key_clean <= not sigA and sigB;
	end process craps_negEdgeDetect;
	 
end rtl;