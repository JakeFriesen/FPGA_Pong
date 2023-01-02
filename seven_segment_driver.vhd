----------------------------------------------------------------------------------
-- Engineer: Jake Friesen
-- 
-- Create Date: 12/23/2022 10:26:34 AM
-- Module Name: seven_segment_driver - Behavioral
-- Project Name: Pong  
-- Description: Driver for seven segment display. 
-- Uses decimal digits for two score numbers 
-- 
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment_driver is
    Port ( clk_100MHz : in STD_LOGIC;
           reset : in STD_LOGIC;
           LED_num : out STD_LOGIC_VECTOR (3 downto 0);
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);
           num_in : in STD_LOGIC_VECTOR (15 downto 0));
end seven_segment_driver;

architecture Behavioral of seven_segment_driver is
    signal LED_BCD : integer range 0 to 9;
    signal refresh_counter : STD_LOGIC_VECTOR(19 downto 0);
    signal LED_position : STD_LOGIC_VECTOR(1 downto 0);
    signal decimal_num_0, decimal_num_1 : integer;
    signal decimal_disp_0, decimal_disp_1, decimal_disp_2, decimal_disp_3 : integer range 0 to 9;
begin

-- Update output digit
process(LED_BCD)
begin
    case LED_BCD is
    when 0 => LED_out <= "0000001";    
    when 1 => LED_out <= "1001111";
    when 2 => LED_out <= "0010010";
    when 3 => LED_out <= "0000110";
    when 4 => LED_out <= "1001100";
    when 5 => LED_out <= "0100100";
    when 6 => LED_out <= "0100000";
    when 7 => LED_out <= "0001111";
    when 8 => LED_out <= "0000000";    
    when 9 => LED_out <= "0000100";
    end case;
end process;

--Reset process
process(clk_100MHz, reset) 
begin
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clk_100MHz)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
-- Update the current LED to refresh
 LED_position <= refresh_counter(19 downto 18);
-- Cycle through all 4 7-segment displays 
process(LED_position)
begin
    case LED_position is
    when "00" => -- Segment 1
        LED_num <= "0111"; 
        LED_BCD <= decimal_disp_0;
    when "01" => -- Segment 2
        LED_num <= "1011"; 
        LED_BCD <= decimal_disp_1;
    when "10" => -- Segment 3
        LED_num <= "1101"; 
        LED_BCD <= decimal_disp_2;
    when "11" => -- Segment 4
        LED_num <= "1110"; 
        LED_BCD <= decimal_disp_3;
    end case;
end process;

--Convert two 8 bit hex numbers into decimal numbers to display
process(num_in)
begin
    -- take num_in, split into two numbers, and then recast into decimal_disp
    decimal_num_0 <= to_integer(unsigned(num_in(15 downto 8)));-- first number
    decimal_disp_1 <= decimal_num_0 - ((decimal_num_0 / 10) * 10); -- lower digit
    decimal_disp_0 <= decimal_num_0 / 10; -- upper digit
    decimal_num_1 <= to_integer(unsigned(num_in(7 downto 0)));-- second number
    decimal_disp_3 <= decimal_num_1 - ((decimal_num_1 / 10) * 10);-- lower digit
    decimal_disp_2 <= decimal_num_1 / 10;-- upper digit
end process;

end Behavioral;
