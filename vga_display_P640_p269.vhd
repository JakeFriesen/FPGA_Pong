--------------------------------------------------------------------------------
--
-- dwc ECE441 adapted from Gazi&Arli book, P6.40, p.269
-- Jake Friesen - Code adapted from Uvic ECE441 Lab section
--    
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.std_logic_unsigned.all;

entity vga_obj_motion is
    port(clk: in std_logic;
    blank_in, vsync_in: in std_logic;
    hpos, vpos: in positive range 1 to 1024;
    btn_left, btn_right: in std_logic;
    btn_up, btn_down: in std_logic;
    vga_red, vga_green, vga_blue: out std_logic_vector(3 downto 0);
    score : out std_logic_vector(15 downto 0);
    reset : in std_logic
    );
end vga_obj_motion;



architecture logic_flow of vga_obj_motion is
-- Length and Height of Paddle
signal length : positive range 1 to 1024 := 64;
signal width : positive range 1 to 1024 := 3;
signal ball_pos_x : positive range 1 to 1024 := 30;
signal ball_pos_y : positive range 1 to 1024 := 30;
signal ball_size : positive range 1 to 1024 := 8;
signal obj_X_pos: positive range 1 to 1024:=10; 
signal obj_X_pos_l : positive range 1 to 1024 := 20; -- starting position for left paddle
signal obj_X_pos_r : positive range 1 to 1024 := 630; -- starting position for left paddle
signal obj_Y_pos: positive range 1 to 1024:=240;
signal obj_X_motion: integer range -8 to 8:=0;
signal obj_Y_motion: integer range -8 to 8:=0;
signal ball_dir_x, ball_dir_y : integer range -8 to 8 := 2;
signal display_height: positive range 1 to 1024 := 480;
signal display_width: positive range 1 to 1024 := 640;
signal reset_in : std_logic;
signal collide : std_logic_vector(1 downto 0);
signal speed : integer range -8 to 8 := 2;
signal speed_btn_pressed : std_logic;
signal num_hits : positive range 0 to 1024;
signal score_l, score_r : std_logic_vector(7 downto 0) := x"00";

begin
obj_create: process(clk)
begin
if(rising_edge(clk)) then
if(blank_in='0') then
    -- Left Paddle
    if((0 = hpos -obj_X_pos_l) and 
       (0 = vpos -obj_Y_pos)) then
        vga_red<=x"0";
        vga_green<=x"0";
        vga_blue<=x"0";
    elsif((0<= hpos + width - obj_X_pos_l) and
    (obj_X_pos_l + width-hpos>=0) and
    (0<=vpos + length-obj_Y_pos) and
    (obj_Y_pos + length- vpos>=0)) then
        vga_red<=x"f";
        vga_green<=x"f";
        vga_blue<=x"f";
    -- Right Paddle
    elsif((0 = hpos -obj_X_pos_r) and 
          (0 = vpos - obj_Y_pos)) then
        vga_red<=x"0";
        vga_green<=x"0";
        vga_blue<=x"0";
    elsif ((0<= hpos + width - obj_X_pos_r) and
    (obj_X_pos_r + width-hpos>=0) and
    (0<=vpos + length-obj_Y_pos) and
    (obj_Y_pos + length- vpos>=0)) then
        vga_red<=x"f";
        vga_green<=x"f";
        vga_blue<=x"f";
    --Ball Position
    elsif((0 = hpos - ball_pos_x) and 
          (0 = vpos - ball_pos_y)) then
        vga_red<=x"0";
        vga_green<=x"0";
        vga_blue<=x"0";    
    elsif((0<= hpos + ball_size - ball_pos_x) and
    (ball_pos_x + ball_size-hpos>=0) and
    (0<=vpos + ball_size-ball_pos_y) and
    (ball_pos_y + ball_size- vpos>=0)) then
        --Ball Colour
        vga_red<=x"f";
        vga_green<=x"3";
        vga_blue<=x"3";
    --Middle line
    elsif((hpos >= (display_width/2) - 1) and 
          (hpos <= (display_width/2) + 1)) then
        vga_red<=x"f";
        vga_green<=x"f";
        vga_blue<=x"f";
    else
        --Background Colour
        vga_red<=x"1";
        vga_green<=x"1";
        vga_blue<=x"a";
    end if;
else
    --Blanking Colour
    vga_red<=x"0";
    vga_green<=x"0";
    vga_blue<=x"0";
end if;
end if;
end process;

obj_move: process (vsync_in)
begin
if(rising_edge(vsync_in)) then

------------------- y axis motion
if (btn_down='1' and btn_up='1') then
    obj_Y_motion<=0;
elsif (btn_up='0' and btn_down='1') then
    obj_Y_motion<=8;
elsif (btn_down='0' and btn_up='1') then
    obj_Y_motion<=-8;
elsif (btn_down='0' and btn_up='0') then
    obj_Y_motion<=0;
end if;

-------- Speed Changes-------- 
if (btn_left='1' and btn_right='1') then
    speed<=speed;
elsif (btn_right='0' and btn_left='1' and speed_btn_pressed = '0') then
    speed<=speed - 1;
    speed_btn_pressed <= '1';
elsif (btn_left='0' and btn_right='1' and speed_btn_pressed = '0') then
    speed<=speed + 1;
    speed_btn_pressed <= '1';
elsif (btn_left='0' and btn_right='0') then
    speed<=speed;
-- TODO: Need to retry this: currently increases speed infinitely 
-- after getting caught behind/around a paddle
--    speed <= speed + (num_hits/8);
    speed_btn_pressed <= '0';
end if;

-------- Ball Motion -------- 
--If out of display height, switch direction
if(ball_pos_y >= display_height) then
    ball_dir_y <= -speed;
elsif(ball_pos_y <= 10) then
    ball_dir_y <= speed;
else
    ball_dir_y <= ball_dir_y;
end if;

--reset signal - for when to reset ball
if(ball_pos_x >= display_width and reset_in = '0')then -- Left point
    reset_in <= '1';
    num_hits <= 0;
    score_l <= score_l + x"01"; --TODO: Make sure this doesn't count up a bunch
elsif((ball_pos_x <= 10) and reset_in = '0') then -- Right point
    reset_in <= '1';
    num_hits <= 0;
    score_r <= score_r + x"01";
elsif(reset = '1') then
    reset_in <= '1';
    score_r <= (others=>'0');
    score_l <= (others=>'0');
else
    reset_in <= '0';
end if;


-- If it passes the paddle, it should reset
if(ball_pos_x >= display_width) then
    --TODO: randomize initial speeds?
    ball_dir_x <= -speed;
--    ball_dir_y <= 1);
elsif(ball_pos_x <= 10) then
    --TODO: randomize intiial speeds?
    ball_dir_x <= speed;
--    ball_dir_y <= 1;
    
--If it hits the paddle, switch direction
--TODO: Count the number of hits and increase speed as the play progresses
--Left Paddle
elsif( (ball_pos_x + (ball_size) >= obj_X_pos_l - (width)) and
       (ball_pos_x - (ball_size) <= (obj_X_pos_l + (width))) and
       (ball_pos_y + (ball_size) >= obj_Y_pos - (length)) and
       (ball_pos_y - (ball_size) <= (obj_Y_pos + (length))) )then
   ball_dir_x <= speed; 
   collide <= "10";
   num_hits <= num_hits + 1;

--Right Paddle
elsif( (ball_pos_x + (ball_size) >= obj_X_pos_r - (width)) and
       (ball_pos_x - (ball_size) <= (obj_X_pos_r + (width))) and   
       (ball_pos_y + (ball_size) >= obj_Y_pos - (length)) and
       (ball_pos_y - (ball_size) <= (obj_Y_pos + (length))) )then
   ball_dir_x <= -speed; 
   collide <= "01";
   num_hits <= num_hits + 1;

--No Collisions
else
    ball_dir_x <= ball_dir_x;
    collide <= "00";
end if;


--Check for a collide, and set position to align to the edge
if(collide = "00")then --No Collision
    obj_Y_pos<=obj_Y_pos + obj_Y_motion;
    obj_X_pos<=obj_X_pos + obj_X_motion;
elsif(collide = "01") then --Right Collision
    obj_Y_pos<=obj_Y_pos + obj_Y_motion;
    obj_X_pos<=obj_X_pos_r - ball_size;
elsif(collide ="10") then --Left Collision
    obj_Y_pos<=obj_Y_pos + obj_Y_motion;
    obj_X_pos<=obj_X_pos_l + width;
end if;



if(reset_in = '1' or reset = '1') then
-- TODO: Make a more sophisticated reset sequence
    ball_pos_x <= 320;
    ball_pos_y <= 240;
else
    ball_pos_x <= ball_pos_x + ball_dir_x;
    ball_pos_y <= ball_pos_y + ball_dir_y;
end if;


end if;
end process;

-- Push scores into output vector
score <= score_l & score_r;

end logic_flow;