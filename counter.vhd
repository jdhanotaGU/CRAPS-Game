library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity counter is
port (rst: in std_logic;
		clk_in: in std_logic; -- Clk_in is 50MHZ
		slow_clk: out std_logic); -- slow_clk is the slowed down clock
end counter;

architecture rtl of counter is
signal cnt: unsigned(18 downto 0); -- 18 bit counter needed for a 6ms counter (3mSec high + 3ms low).
begin
	 counter_p: process(rst, clk_in) 
	 variable slow_clk_v: std_logic;
	 begin
		if (rst = '0') then
			cnt <= (others => '0');
			slow_clk_v := '0';
		
		elsif (rising_edge(clk_in)) then
			if (cnt = "1111010000100100000") then -- This binary value is equivelent to 150,000 clock cycles (3ms).
				slow_clk_v := not slow_clk_v;
				cnt <= (others => '0'); -- Reset the counter back to 0.
			
			else
				cnt <= cnt + 1;
				slow_clk_v := slow_clk_v; -- Do this to avoid an infered latch with slow_clk_v. Make it equal itself so the compliler knows what to do with the variable when still counting.
			
			end if;
		end if;	
		slow_clk <= slow_clk_v;
	 end process;
end rtl;