library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Robot is
	port(reset, clk,
	findfood, -- location of the food has been identified
	closetofood, -- moving towards the food
	lostfood, -- location of the food has been lost
	scantimeup, -- scan time has expired
	success, -- the food has been grabbed, or deposited
	athome, -- control is given to exit the arena
	aboverestth, abovesearchth : in std_logic;
	rest, search, food : out std_logic);
end Robot;

architecture intf of Robot is
type States is (idle, resting, randomwalk, movetofood, scanarena, homing, grabfood, movetohome, deposit);
signal state, nextstate: States;

    -- PSL default clock is (clk'event and clk = '1');

    -- PSL property p1 is always(search = '1' -> (state /= grabfood until! (findfood = '1')));

    -- PSL property p2 is always(state = grabfood -> (state = deposit before! (rest = '1')));
	
    -- PSL property p3 is always({state = randomwalk ; (abovesearchth = '0' and findfood = '0')[*]; (abovesearchth = '0' and findfood = '1'); (abovesearchth = '0' and lostfood = '0')[*]; (abovesearchth = '0' and lostfood = '1'); (abovesearchth = '0' and findfood = '0' and scantimeup = '0')[*]; (abovesearchth = '0' and findfood = '0' and scantimeup = '1')} |-> next!(state = randomwalk));

    -- PSL assert p1;
    -- PSL assert p2;
    -- PSL assert p3;

begin
    -- next state 
    process(state, findfood, closetofood, lostfood, scantimeup, success, athome, aboverestth, abovesearchth)
    begin
	case state is
		when idle => nextstate <= resting;
		when resting => 
			if aboverestth = '1' then nextstate <= randomwalk;
			else nextstate <= resting;
			end if;
		when randomwalk =>
			if (abovesearchth = '1') then nextstate <= homing;
			elsif (findfood = '1') then nextstate <= movetofood;
			else nextstate <= randomwalk;
			end if;
		when movetofood =>
			if (abovesearchth = '1') then nextstate <= homing;
			elsif (closetofood = '1')  then nextstate <= grabfood;
			elsif (lostfood = '1')  then nextstate <= scanarena;
			else nextstate <= movetofood;
			end if;
		when scanarena =>
			if (abovesearchth = '1') then nextstate <= homing;
			elsif (findfood = '1') then nextstate <= movetofood;
			elsif (scantimeup = '1') then nextstate <= randomwalk;
			else nextstate <= scanarena;
			end if;
		when homing =>
			if athome = '1' then nextstate <= resting;
			else nextstate <= homing;
			end if;
		when grabfood =>
			if success = '1' then nextstate <= movetohome;
			else nextstate <= grabfood;
			end if;
		when movetohome =>
			if athome = '1' then nextstate <= deposit;
			else nextstate <= movetohome;
			end if;
		when deposit =>
			if success = '1' then nextstate <= resting;
			else nextstate <= deposit;
			end if;
	end case;
    end process;

    -- updating of the state register:
    process(reset, clk)
    begin
	-- asynchronous reset (active high):
	if (reset = '1') then state <= idle;
	-- otherwise, on clock rising edges:
	elsif (clk'event and clk='1') then
		state <= nextstate;
	end if;
    end process;

    -- output function for rest
    process(state, success, athome)
    begin 
	if (state=idle) then rest <= '1';
	elsif (state=homing) and (athome='1') then rest <= '1';
	elsif (state=deposit) and (success='1') then rest <= '1';
	else rest <= '0';
    	end if;
    end process;

    -- output function for food
    process(state, closetofood, abovesearchth, lostfood)
    begin 
	if (state=movetofood) and (abovesearchth='0') and (lostfood = '0') and (closetofood='1') then food <= '1';
	else food <= '0';
    	end if;
    end process;

    -- output function for search
    process(state, aboverestth)
    begin 
	if (state=resting) and (aboverestth='1') then search <= '1';
	else search <= '0';
    	end if;
    end process; 	
end intf;




library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Counter entity to manage the thresholds
entity Count is
	generic(threshold: natural);
	port(reset, clk, start: in std_logic; aboveth: out std_logic);
end Count;

architecture impl of Count is
type States is (idle, counting);
signal state, nextstate: States;
signal c, nextc: natural;
begin
	process (state, start, c)
	begin
		case state is
			when idle =>
				if start = '1' then
					nextstate <= counting;
					nextc <= 1;
				else nextstate <= idle;
					nextc <= 0;
				end if;
			when counting =>
				if (c >= threshold) then
					nextstate <= idle;
					nextc <= 0;
				else nextstate <= counting;
					nextc <= c+1;
				end if;
		end case;
	end process;
	process (reset, clk)
	begin
		if (reset = '1') then state <= idle;
			c <= 0;
		elsif (clk'event and clk='1') then
			state <= nextstate;
			c <= nextc;
		end if;
	end process;
	aboveth <= '1' when c >=threshold else '0';
end impl;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- system 
entity System is
	port(reset, clk, findfood, closetofood, lostfood, scantimeup,
	success, athome: in std_logic;
	food: out std_logic);
end System;

architecture sys of System is
  component Robot is
	port(reset, clk,
	findfood, -- location of the food has been identified
	closetofood, -- moving towards the food
	lostfood, -- location of the food has been lost
	scantimeup, -- scan time has expired
	success, -- the food has been grabbed, or deposited
	athome, -- control is given to exit the arena
	aboverestth, abovesearchth : in std_logic;
	rest, search, food : out std_logic);
  end component;

  component Count is
     generic(threshold: natural);
     port(reset, clk, start: in std_logic; aboveth: out std_logic);
  end component;
 
  signal rest, aboverest, search, abovesearch: std_logic := '0';
begin
     -- instantiate robot
     robot_inst: Robot port map(reset, clk, findfood, closetofood, lostfood, scantimeup, success, athome,
		           aboverest, abovesearch, rest, search, food);

     -- instantiate counter for resting 
     counter1: Count generic map (4) port map(reset, clk, rest, aboverest);

     -- instantiate counter for searching 
     counter2: Count generic map (10) port map(reset, clk, search, abovesearch);
end sys;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Configuration of the system
configuration sys_config of System is
  for sys
    for robot_inst : Robot
      use entity work.Robot (intf)
      port map (reset => reset,clk => clk, findfood => findfood, closetofood => closetofood, lostfood => lostfood, scantimeup => scantimeup, success => success, athome => athome, aboverestth => aboverest, abovesearchth => abovesearch, rest => rest, search => search, food => food);
    end for;

    for counter1 : Count
      use entity work.Count (impl)
      generic map (threshold => 4)
      port map (reset => reset, clk => clk, start => rest, aboveth => aboverest);
    end for;
 
    for counter2 : Count
      use entity work.Count (impl)
      generic map (threshold => 10)
      port map (reset  => reset, clk => clk, start => search, aboveth => abovesearch);
    end for;
  end for;
end sys_config;
