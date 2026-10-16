library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- system
entity System is
  port(reset, clk, athome, findfood, lostfood, closetofood,
       success, scantimeup: in std_logic;
       food: out std_logic;
       LEDR : out std_logic_vector(5 downto 0); -- for 6 red leds
       LEDG : out std_logic_vector(2 downto 0); -- for 3 green leds
       seg_val_hex0: out INTEGER range 0 to 127; -- to display the state
       seg_val_hex1: out INTEGER range 0 to 127; -- to display counter 1
       seg_val_hex2: out INTEGER range 0 to 127 -- to display counter 2
       );
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
	rest, search, food : out std_logic;
	LEDR : out std_logic_vector(5 downto 0);
	LEDG : out std_logic_vector(2 downto 0);
	seg_val_hex0: out INTEGER range 0 to 127);
  end component;

  component Count is
     generic(threshold: natural);
  port(reset, clk, start: in std_logic;
	  aboveth: out std_logic;
	  seg_val_hex: out INTEGER range 0 to 127);
  end component;

  signal rest, aboverest, search, abovesearch, ck_1Hz: std_logic := '0';

  attribute chip_pin : string;
  attribute chip_pin of reset : signal is "R22";
  attribute chip_pin of clk : signal is "L1";

  attribute chip_pin of athome : signal is "U12";
  attribute chip_pin of findfood : signal is "W12";
  attribute chip_pin of lostfood : signal is "V12";
  attribute chip_pin of closetofood : signal is "M22";
  attribute chip_pin of success : signal is "L21";
  attribute chip_pin of scantimeup : signal is "L22";

  attribute chip_pin of seg_val_hex0 : signal is "J2,J1,H2,H1,F2,F1,E2";
  attribute chip_pin of seg_val_hex1 : signal is "E1,H6,H5,H4,G3,D2,D1";
  attribute chip_pin of seg_val_hex2 : signal is "G5,G6,C2,C1,E3,E4,D3";

  attribute chip_pin of LEDR : signal is "V19,T18,Y19,U19,R19,R20";
  attribute chip_pin of LEDG : signal is "V22,U21,U22";
begin
  -- Clock divider from 50 MHz to a 1 Hz pulse (ck_1Hz)
  process (clk)
	variable cnt : INTEGER RANGE 0 TO 67108863;
	constant verrou_t : INTEGER := 50000000;
  begin
	if (clk'event and clk = '1') then
		if (reset = '0') or (cnt = verrou_t) then
			cnt := 0;
		else
			cnt := cnt + 1;
		end if;
	end if;

	if (cnt = verrou_t) then
		ck_1Hz <= '1';
	else
		ck_1Hz <= '0';
	end if;
  end process;

  -- instantiate robot
  robot_inst: Robot port map(reset, ck_1Hz, findfood, closetofood, lostfood, scantimeup, success, athome,
		           aboverest, abovesearch, rest, search, food, LEDR, LEDG, seg_val_hex0);

  -- instantiate counter for resting
  counter1: Count generic map (4) port map(reset, ck_1Hz, rest, aboverest, seg_val_hex1);

  -- instantiate counter for searching
  counter2: Count generic map (10) port map(reset, ck_1Hz, search, abovesearch, seg_val_hex2);
end sys;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Configuration of the system
configuration sys_config of System is
  for sys
    for robot_inst : Robot
      use entity work.Robot (intf)
      port map (reset => reset,clk => ck_1Hz, findfood => findfood, closetofood => closetofood, lostfood => lostfood, scantimeup => scantimeup, success => success, athome => athome, aboverestth => aboverest, abovesearchth => abovesearch, rest => rest, search => search, food => food, LEDR => LEDR, LEDG => LEDG, seg_val_hex0 => seg_val_hex0);
    end for;

    for counter1 : Count
      use entity work.Count (impl)
      generic map (threshold => 4)
      port map (reset => reset, clk => ck_1Hz, start => rest, aboveth => aboverest, seg_val_hex => seg_val_hex1);
    end for;

    for counter2 : Count
      use entity work.Count (impl)
      generic map (threshold => 10)
      port map (reset  => reset, clk => ck_1Hz, start => search, aboveth => abovesearch, seg_val_hex => seg_val_hex2);
    end for;
  end for;
end sys_config;
