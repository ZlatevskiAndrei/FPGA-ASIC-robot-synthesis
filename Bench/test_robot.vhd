library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testSystem is
end testSystem;

architecture test1 of testSystem is
  -- System component
  component System port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
  end component;

  signal athome, findfood, lostfood, closetofood, success, scantimeup, clk, reset, food: std_logic := '0';
begin
  -- system instqntiation
  sys_inst: System port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome, food);
  reset <= '1', '0' after 5 ns;
  clk <= not clk after 5 ns;
-- this is a simulation example where we want to check the appearance of 1 from food. then we go back to the resting point.
  findfood <= '1' after 45 ns;
  closetofood <= '1' after 55 ns;
  --lostfood <= 
  --scantimeup <= 
  success <= '1' after 85 ns, '0' after 95 ns, '1' after 115 ns;
  athome <= '1' after 75 ns;
end test1;
 

architecture test2 of testSystem is
  -- System component
  component System port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
  end component;

  signal athome, findfood, lostfood, closetofood, success, scantimeup, clk, reset, food: std_logic := '0';
begin
  -- system instqntiation
  sys_inst: System port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome, food);
  reset <= '1', '0' after 5 ns;
  clk <= not clk after 5 ns;
-- this is a simulation example where we want to check the appearance of 1 from food. then we go back to the resting point.
  athome <= '1' after 140 ns;
end test2;


architecture test3 of testSystem is
  -- System component
  component System port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
  end component;

  signal athome, findfood, lostfood, closetofood, success, scantimeup, clk, reset, food: std_logic := '0';
begin
  -- system instqntiation
  sys_inst: System port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome, food);
  reset <= '1', '0' after 5 ns;
  clk <= not clk after 5 ns;
-- this is a simulation example where we want to check the transition between scanarena and homing due to the activation of the abovesearchth threshold
  findfood <= '1' after 50 ns, '0' after 60 ns;
  lostfood <= '1' after 60 ns;
end test3;

architecture test4 of testSystem is
  -- System component
  component System port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
  end component;

  signal athome, findfood, lostfood, closetofood, success, scantimeup, clk, reset, food: std_logic := '0';
begin
  -- system instqntiation
  sys_inst: System port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome, food);
  reset <= '1', '0' after 5 ns;
  clk <= not clk after 5 ns;
-- this is a simulation example where we want to check the transition between movetofood and homing due to the activation of the abovesearchth threshold and returning to resting when athome = 1.
  findfood <= '1' after 50 ns;
  athome <= '1' after 140 ns;  
end test4;

architecture test5 of testSystem is
  -- System component
  component System port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
  end component;

  signal athome, findfood, lostfood, closetofood, success, scantimeup, clk, reset, food: std_logic := '0';
begin
  -- system instqntiation
  sys_inst: System port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome, food);
  reset <= '1', '0' after 5 ns;
  clk <= not clk after 5 ns;
-- this is a simulation example where we want to check the transition between scanarena and movetofood in the case that the robot has find the food after losing it in a previous time.
  findfood <= '1' after 50 ns, '0' after 60 ns, '1' after 70 ns;
  lostfood <= '1' after 60 ns, '0' after 70 ns;
end test5;



architecture test6 of testSystem is
  -- System component
  component System port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
  end component;

  signal athome, findfood, lostfood, closetofood, success, scantimeup, clk, reset, food: std_logic := '0';
begin
  -- system instqntiation
  sys_inst: System port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome, food);
  reset <= '1', '0' after 5 ns;
  clk <= not clk after 5 ns;
-- this is a simulation example where we want to check the transition scanarena to randomwalk state when the signal scantimeup is set to 1.
  findfood <= '1' after 50 ns, '0' after 60 ns;
  lostfood <= '1' after 60 ns, '0' after 70 ns;
  scantimeup <= '1' after 70 ns;
end test6;


library LIB_ROBOT;
library LIB_ROBOT_BENCH;

configuration config1 of LIB_ROBOT_BENCH.testSystem is  
    for test1
       for sys_inst:System use configuration LIB_ROBOT.sys_config; 
       end for;
    end for; 
end config1; 

library LIB_ROBOT;
library LIB_ROBOT_BENCH;

configuration config2 of LIB_ROBOT_BENCH.testSystem is  
    for test2
       for sys_inst:System use configuration LIB_ROBOT.sys_config;
       end for;
    end for; 
end config2; 

library LIB_ROBOT;
library LIB_ROBOT_BENCH;

configuration config3 of LIB_ROBOT_BENCH.testSystem is  
    for test3
       for sys_inst:System use configuration LIB_ROBOT.sys_config;
       end for;
    end for; 
end config3; 

library LIB_ROBOT;
library LIB_ROBOT_BENCH;

configuration config4 of LIB_ROBOT_BENCH.testSystem is  
    for test4
       for sys_inst:System use configuration LIB_ROBOT.sys_config;
       end for;
    end for; 
end config4; 

library LIB_ROBOT;
library LIB_ROBOT_BENCH;

configuration config5 of LIB_ROBOT_BENCH.testSystem is  
    for test5
       for sys_inst:System use configuration LIB_ROBOT.sys_config;
       end for;
    end for; 
end config5;

library LIB_ROBOT;
library LIB_ROBOT_BENCH; 

configuration config6 of LIB_ROBOT_BENCH.testSystem is  
    for test6
       for sys_inst:System use configuration LIB_ROBOT.sys_config;
       end for;
    end for; 
end config6; 



