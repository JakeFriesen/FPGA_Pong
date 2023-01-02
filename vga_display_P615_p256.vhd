--------------------------------------------------------------------------------
--
-- dwc ECE441 adapted from Gazi&Arli book, P6.15, p.256
--
--    
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_generator is

port(
	clk_100MHz: in std_logic;
	clk_25MHz: out std_logic
	);
end clock_generator;

architecture logic_flow of clock_generator is

	signal count: integer range 0 to 3:=0;
	signal signal_25MHz: std_logic:='0';

begin
	clk_25MHz<=signal_25MHz;

clk25MHz: process(clk_100MHz)
	begin
		if(rising_edge(clk_100MHz)) then
		if(count=1) then
		signal_25MHz<=not signal_25MHz;
		count<=0;
		else
		count<=count + 1;
		end if;
		end if;

	end process;

end logic_flow;