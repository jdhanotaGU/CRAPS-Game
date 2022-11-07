library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity craps is
port (reset, MCLK, key: in std_logic;
		seg1, seg2, seg3, seg4: out std_logic_vector(6 downto 0);	-- outputs for 7 seg displays
		debugLED, win_LED, lose_LED: out std_logic	-- LEDs for win and lose
		);
end craps;

architecture rtl of craps is
-- User Defined Types
type stateType is (waitPress, pressRecieved, win, lose);

-- Signals:
signal nextState: stateType := waitPress;
signal currentState: stateType := waitPress;
signal slow_clk_in: std_logic; -- This will act as our slow clock. Updated by the counter component.
signal key_clean: std_logic := '0'; -- Holds the clean key press. (Cleaned using negative edge detection)
signal firstRoll: std_logic := '0'; -- 0 if this is the first roll. If on 2nd+ roll, then 1.
signal nextGame: std_logic := '0'; -- Signal that the next game is starting (update previousSum)
signal stopCount: std_logic := '0';
signal currentSum: integer range 0 to 12;
signal previousSum: integer range 0 to 12;
signal dice1Cnt: integer range 0 to 7;
signal dice2Cnt: integer range 0 to 7;
signal seg1_output : std_logic_vector(6 downto 0);
signal seg2_output : std_logic_vector(6 downto 0);
signal seg3_output : std_logic_vector(6 downto 0);
signal seg4_output : std_logic_vector(6 downto 0);

-- Instatiate the counter component:
component counter
	port (rst: in std_logic;
		clk_in: in std_logic;
		slow_clk: out std_logic); -- clock_out is the slowed down clock (4ms period)
end component counter;
	
begin
	-- Component Definitions --
	slowClock : counter port map(rst => reset, clk_in => MCLK, slow_clk => slow_clk_in);
	
	craps_nextStateLogic_p: process(currentState)
	begin
		case currentState is
			when waitPress => 
				nextGame <= '0'; -- reset
				stopCount <= '0';
				if (key_clean = '1') then
					nextState <= pressRecieved;
				else
					nextState <= waitPress;
				end if;
			
			when pressRecieved =>
				if (firstRoll = '1') then
					if (currentSum = 7 or currentSum = 11) then
						nextState <= win;
						stopCount <= '1';
					elsif (currentSum = 2 or currentSum = 3 or currentSum = 12) then
						nextState <= lose;
						stopCount <= '1';
					else -- nextGame
						stopCount <= '0';
						nextGame <= '1';
						nextState <= waitPress;
					end if;
				else -- if this is the 2nd+ roll
					if (currentSum = previousSum) then
						nextState <= win;
						stopCount <= '1';
					elsif (currentSum = 7) then
						nextState <= lose;
						stopCount <= '1';
					else -- Next game
						nextGame <= '1';
						nextState <= waitPress;
						stopCount <= '0';
					end if;
				end if;
			
			when win => -- Loop forever here
				stopCount <= '1';
				nextState <= win;
			
			when lose => -- loop forever here
				stopCount <= '1';
				nextState <= lose;
		end case;
	end process craps_nextStateLogic_p;
	
	craps_DFlipFlop: process(slow_clk_in, reset, stopCount)
	begin
		if (reset = '0') then
			firstRoll <= '0';
			dice1Cnt <=  0;
			dice2Cnt <= 0;
			currentSum <= 0;
			previousSum <= 0;
			currentState <= waitPress;
		elsif (rising_edge(slow_clk_in)) then
			currentState <= nextState;
			if (stopCount = '0') then
				if (dice1Cnt >= 6) then
					dice1Cnt <= 0;
				else
					dice1Cnt <= dice1Cnt + 1;
				end if;
				if ((dice1Cnt mod 3) = 0) then
					if (dice2Cnt >= 6) then
						dice2Cnt <= 0;
					else
						dice2Cnt <= dice2Cnt + 1;
					end if;
				else 
					dice2Cnt <= dice2Cnt;
				end if;
			else
				dice1Cnt <= dice1Cnt;
				dice2Cnt <= dice2Cnt;
			end if;
			if (key_clean = '1') then
				if (firstRoll = '0') then -- This is the first game
					firstRoll <= '1';
				else
					firstRoll <= '0'; -- prevent latch
				end if;
				currentSum <= dice1Cnt + dice2Cnt;
			end if;
			
			if (nextGame = '1') then
				previousSum <= currentSum; -- Is this ok? Read and write ok on currentSum?
			end if;
		end if;
	
	end process craps_DFlipFlop;
	
	craps_segmentLogic_p: process(dice1Cnt, dice2Cnt, currentSum)
	begin
		case dice1Cnt is
			when 1 =>
				seg1_output <= "0000110";
			when 2 =>
				seg1_output <= "1011011";
			when 3 =>
				seg1_output <= "1001111";
			when 4 => 
				seg1_output <= "1100110";
			when 5 =>
				seg1_output <= "1101101";
			when 6 =>
				seg1_output <= "1111101";
			when others =>
				seg1_output <= "0000000";
		end case;
		case dice2Cnt is
			when 1 =>
				seg2_output <= "0000110";
			when 2 =>
				seg2_output <= "1011011";
			when 3 =>
				seg2_output <= "1001111";
			when 4 => 
				seg2_output <= "1100110";
			when 5 =>
				seg2_output <= "1101101";
			when 6 =>
				seg2_output <= "1111101";
			when others =>
				seg2_output <= "0000000";
		end case;
		case currentSum is
			when 2 =>
				seg3_output <= "0000000";
				seg4_output <= "1011011";
			when 3 =>
				seg3_output <= "0000000";
				seg4_output <= "1001111";
			when 4 => 
				seg3_output <= "0000000";
				seg4_output <= "1100110";
			when 5 =>
				seg3_output <= "0000000";
				seg4_output <= "1101101";
			when 6 =>
				seg3_output <= "0000000";
				seg4_output <= "1111101";
			when 7 =>
				seg3_output <= "0000000";
				seg4_output <= "0000111";
			when 8 =>
				seg3_output <= "0000000";
				seg4_output <= "1111111";
			when 9 =>
				seg3_output <= "0000000";
				seg4_output <= "1101111";
			when 10 =>
				seg3_output <= "0000110";
				seg4_output <= "0111111";
			when 11 =>
				seg3_output <= "0000110";
				seg4_output <= "0000110";
			when 12 =>
				seg3_output <= "0000110";
				seg4_output <= "1011011";
			when others =>
				seg3_output <= "0000000";
				seg4_output <= "0000000";
				-- do nothing
		end case;
	end process craps_segmentLogic_p;
	
	-- I don't believe next state is needed in the sensitivity list
	-- segments might cause latches since not defined for every case
	craps_outputLogic_p: process(currentState, nextState)
	begin
		case currentState is 
			when waitPress =>
				-- display counter 7-seg values constanty updating
				debugLED <= '0';
				seg1 <= not seg1_output;
				seg2 <= not seg2_output;
				seg3 <= not "0000000";
				seg4 <= not "0000000";
				win_LED <= '0';
				lose_LED <= '0';
			when pressRecieved =>
				-- display 7-seg with final value of button pressed
				-- should display result of first dice role, second dice role, and summed dice role
				debugLED <= '1';
				seg1 <= not seg1_output;
				seg2 <= not seg2_output;
				seg3 <= not seg3_output;
				seg4 <= not seg4_output;
				win_LED <= '0';
				lose_LED <= '0';
			when win =>
				win_LED <= '1';
				lose_LED <= '0';
			when lose =>
				win_LED <= '0';
				lose_LED <= '1';
			when others =>
				-- do nothing
		end case;
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