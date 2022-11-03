-- Lab 5 logic code
-- State 0: Roll_button_wait state, wait for button to be pushed, 7 seg is displaying counter while counting, 
-- State 1: Roll_button_pressed state, Entered in if Roll button is activated, comparisons occur for determining next state (Win or Lose)
-- State 2: Win State, entered in if current sum is 7 or 11, maintains logic until reset is pressed, goes back to state 0, displays win led
-- State 3: Lose State, enterd in if current sum is 2,3, or 12, maintains logic until reset is pressed, goes back to state 0, dislays lose led
-- State 4: Roll_button 2, waits for the button to be pressed, sets previous sum flag to set current sum value into previous sum register, similar to state 0
-- State 5: Roll_button_pressed state, button has been pressed again, similar to state 1 handles 

-- Counter flip-flop: running concurrently with State 0, updating as counter is counting
--							 display Win LED if game is in win state, use win flag(?)
--							 display lose LED if game is in lost state, use lose flag(?)
--							 stores current sum into previous sum if flag is set, prepare for new game
-- Output flip-flop:  displays values on 7 segment display as it is updating,
--							 display Win LED if game is in win state, use win flag(?)
--							 display lose LED if game is in lost state, use lose flag(?)

-- variable names: dice1, dice 2, current_sum(register, updated in flip-flop), previous_sum(register, update in flip-flop), 

-- 3 processes of logic, next_state logic, output logic, counting/D flip-flop logic

-- output logic:

	signal dice1 : std_logic_vector(3 downto 0);
	signal dice2 : std_logic_vector(3 downto 0);
	signal current_sum : std_logic_vector(3 downto 0);
	signal win_LED : std_logic;
	signal lose_LED : std_logic;
	signal seg1_ouput : std_logic_vector(6 downto 0);
	signal seg2_ouput : std_logic_vector(6 downto 0);
	signal seg3_ouput : std_logic_vector(6 downto 0);
	signal seg4_ouput : std_logic_vector(6 downto 0);
	--type number_output is array (0 to 6) of std_logic_vector(6 downto 0);	--array of led numbers for 7-seg output
	--signal seg_output : number_output;
	
	segment_logic : process(dice1, dice2, current_sum)
	begin
	case dice1 is
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
		case dice2 is
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
		case current_sum is
			when 2 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "1011011";
			when 3 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "1001111";
			when 4 => 
				seg3_ouput <= "0000000";
				seg4_ouput <= "1100110";
			when 5 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "1101101";
			when 6 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "1111101";
			when 7 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "0000111";
			when 8 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "1111111";
			when 9 =>
				seg3_ouput <= "0000000";
				seg4_ouput <= "1101111";
			when 10 =>
				seg3_ouput <= "0000110";
				seg4_ouput <= "0111111"
			when 11 =>
				seg3_ouput <= "0000110";
				seg4_ouput <= "0000110"
			when 12 =>
				seg3_ouput <= "0000110";
				seg4_ouput <= "1011011";
	end process segment_logic;
	
	output_logic : process(state, dice1, dice2, current_sum)
	begin
		case state is 
			when waitForProcess =>
				-- display counter 7-seg values constanty updating
				--seg1 <= dice1;
				--seg2 <= dice2;
				seg1 <= seg1_output;
				seg2 <= seg2_output;
			when buttonPressed =>
				--seg1 <= dice1;
				--seg2 <= dice2;
				--seg3 <= current_sum;
				seg1 <= seg1_output;
				seg2 <= seg2_output;
				seg3 <= seg3_output;
				-- display 7-seg with final value of button pressed
				-- should display result of first dice role, second dice role, and summed dice role
			when win =>
				win_LED <= '1';
				lose_LED <= '0';
			when lose =>
				win_LED <= '0';
				lose_LED <= '1';
			when others =>
				-- do nothing
		end case;
	end process;