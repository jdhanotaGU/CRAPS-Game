library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity craps is
port (rst: in std_logic;
		clk_in: in std_logic; -- Clk_in is 50MHZ
		slow_clk: out std_logic); -- slow_clk is the slowed down clock
end craps;

architecture rtl of craps is
begin
	 
end rtl;