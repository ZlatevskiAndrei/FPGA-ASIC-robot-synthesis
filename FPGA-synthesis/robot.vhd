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
	rest, search, food : out std_logic;
	LEDR : out std_logic_vector(5 downto 0);
	LEDG : out std_logic_vector(2 downto 0);
	seg_val_hex0: out INTEGER range 0 to 127);
end Robot;

architecture intf of Robot is
type States is (idle, resting, randomwalk, movetofood, scanarena, homing, grabfood, movetohome, deposit);
signal state, nextstate: States;

    -- PSL default clock is (clk'event and clk = '1');

    -- PSL property p1 is always(search = '1' -> (state /= grabfood until (findfood = '1')));

    -- PSL property p2 is always(state = grabfood -> (state = deposit before (rest = '1')));
	
    -- PSL property p3 is always({state = randomwalk ; (abovesearchth = '0' and findfood = '0')[*]; (abovesearchth = '0' and findfood = '1'); (abovesearchth = '0' and lostfood = '0')[*]; (abovesearchth = '0' and lostfood = '1'); (abovesearchth = '0' and findfood = '0' and scantimeup = '0')[*]; (abovesearchth = '0' and findfood = '0' and scantimeup = '1')} |-> next!(state = randomwalk));

    -- PSL assert p1;
    -- PSL assert p2;
    -- PSL assert p3;

begin
	-- expose the 6 inputs on red LEDs
	LEDR(5) <= athome;
	LEDR(4) <= findfood;
	LEDR(3) <= lostfood;
	LEDR(2) <= closetofood;
	LEDR(1) <= success;
	LEDR(0) <= scantimeup;

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
	-- asynchronous reset (active low):
	if (reset = '0') then state <= idle;
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

    -- expose control outputs on green LEDs
    LEDG(2) <= rest;
    LEDG(1) <= search;
    LEDG(0) <= food;

    -- display current FSM state on HEX0  (MAY BE HAS TO BE UPDATED TO MATCH THE ORDER OF STATES IN THE TYPE DECLARATION)
    process(state)
    begin
	case state is
		when idle => seg_val_hex0 <= 2#0000001#;      -- 0
		when resting => seg_val_hex0 <= 2#1001111#;   -- 1
		when randomwalk => seg_val_hex0 <= 2#0010010#;-- 2
		when movetofood => seg_val_hex0 <= 2#0000110#;-- 3
		when scanarena => seg_val_hex0 <= 2#1001100#; -- 4
		when homing => seg_val_hex0 <= 2#0100100#;    -- 5
		when grabfood => seg_val_hex0 <= 2#0100000#;  -- 6
		when movetohome => seg_val_hex0 <= 2#0001111#;-- 7
		when deposit => seg_val_hex0 <= 2#0000000#;   -- 8
	end case;
    end process;
end intf;
