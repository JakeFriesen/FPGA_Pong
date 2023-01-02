--------------------------------------------------------------------------------
--
-- dwc ECE441 adapted from Gazi&Arli book, P6.36, p.266
-- Jake Friesen - Code adapted from Uvic ECE441 Lab section
--    
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_exp2 is
	port(
		clk_100MHz: in std_logic;
		hsync, vsync: out std_logic; -- output to JXADC PMOD to observe
		btn_left, btn_right: in std_logic;
        btn_up, btn_down: in std_logic;
		clk_out_25MHz: out std_logic;  -- output to JXADC PMOD to observe
		vgaRed, vgaGreen, vgaBlue: out std_logic_vector(3 downto 0);
		LED_num: out std_logic_vector(3 downto 0);
		LED_out: out std_logic_vector(6 downto 0);
		reset : in std_logic
		);
end vga_exp2;

architecture logic_flow of vga_exp2 is

	signal clk_25MHz:   std_logic;
	signal blank, vsync_signal:    std_logic := '0';
	signal hpos, vpos: positive range 1 to 1024;
    --remove
    signal num_in : std_logic_vector(15 downto 0) := (others=>'0');

	component clock_generator is
		port(
		clk_100MHz: in std_logic;
		clk_25MHz: out std_logic
		);
	end component;

	component vga_signal_gen is
		port(
		clk:   in std_logic;
		blank: out std_logic;
		hsync, vsync: out std_logic;
		hpos,vpos: out positive range 1 to 1024
		);
	end component;
	
	component vga_obj_motion is
		port(
		clk: in std_logic;
		blank_in, vsync_in: in std_logic;
		btn_left, btn_right : in std_logic;
		btn_up, btn_down : in std_logic;
		hpos, vpos: in positive range 1 to 1024;
		vga_red, vga_green, vga_blue: out std_logic_vector(3 downto 0);
		score : out std_logic_vector(15 downto 0);
		reset : in std_logic
		);
	end component;
	
	component seven_segment_driver is
	   port(
	   clk_100MHz : in std_logic;
	   reset : in STD_LOGIC;
       LED_num : out STD_LOGIC_VECTOR (3 downto 0);
       LED_out : out STD_LOGIC_VECTOR (6 downto 0);
       num_in : in STD_LOGIC_VECTOR (15 downto 0)
	   );
	end component;

begin

u1: clock_generator port map(clk_100MHz => clk_100MHz, clk_25MHz => clk_25MHz);
u2: vga_signal_gen 	port map(clk => clk_25MHz, blank => blank, hsync => hsync, vsync => vsync_signal, hpos => hpos, vpos => vpos);
u3: vga_obj_motion  port map(clk => clk_25MHz, blank_in => blank, vsync_in => vsync_signal, 
							btn_left => btn_left, btn_right => btn_right, btn_up => btn_up, btn_down=> btn_down,
							hpos => hpos, vpos => vpos,
							vga_red => vgaRed, vga_green => vgaGreen, vga_blue => vgaBlue, score=> num_in, reset=>reset);
u4: seven_segment_driver port map(clk_100MHz => clk_100MHz, reset=>reset, LED_num=>LED_num, LED_out=>LED_out, num_in=>num_in);
vsync<=vsync_signal;

clk_out_25MHz <= clk_25MHz;


end logic_flow;
