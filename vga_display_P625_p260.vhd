--------------------------------------------------------------------------------
--
-- dwc ECE441 adapted from Gazi&Arli book, P6.25, p.260
--
--    
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_signal_gen is
	port(
	clk: 			in std_logic;
	blank: 			out std_logic;
	hsync, vsync: 	out std_logic;
	hpos, vpos: 	out positive range 1 to 1024
	);
end vga_signal_gen;

architecture logic_flow of vga_signal_gen is

	signal x, y: integer range 0 to 1023:=0;
	signal act_pxl_hrzntl, act_pxl_vrtcl: positive range 1 to 1024:=1;
	signal hsync_sig: std_logic:='0';
	signal Hactive,Vactive: std_logic:='0';

begin

hpos<=act_pxl_hrzntl;
vpos<=act_pxl_vrtcl;
Hsync<=hsync_sig;
blank<=not(Hactive and Vactive);

--Generation of Horizontal signals
horizontal_sync: process (clk)
begin
	if(rising_edge(clk)) then
	x <= x + 1;
	if(x<96) then
	hsync_sig<='0'; Hactive<='0';
	elsif (x>=96 and x<144) then
	hsync_sig<='1'; Hactive<='0';
	elsif (x>=144 and x<784) then
	hsync_sig<='1'; Hactive<='1';
	act_pxl_hrzntl<=act_pxl_hrzntl + 1;
	elsif(x>=784 and x<800) then
	hsync_sig<='1'; Hactive<='0';
	else
	hsync_sig<='0';
	x<=0;
	act_pxl_hrzntl<=1;
	end if;
	end if;
end process;

--Generation of Vertical signals
vertical_sync: process (hsync_sig)
begin
	if(rising_edge(hsync_sig)) then
	y <= y + 1;
	if(y<2) then
	Vsync<='0'; Vactive<='0';
	elsif (y>=2 and y<33) then
	Vsync<='1'; Vactive<='0';
	elsif (y>=33 and y<515) then
	Vsync<='1'; Vactive<='1';
	act_pxl_vrtcl<=act_pxl_vrtcl + 1;
	elsif (y>=515 and y<525) then
	Vsync<='1'; Vactive<='0';
	else
	Vsync<='0';
	y<=0;
	act_pxl_vrtcl<=1;
	end if;
	end if;
end process;


end logic_flow;

