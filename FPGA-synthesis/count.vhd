library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Counter entity to manage the thresholds
entity Count is
	generic(threshold: natural);
	port(reset, clk, start: in std_logic;
	     aboveth: out std_logic;
	     seg_val_hex: out INTEGER range 0 to 127);
end Count;

architecture impl of Count is
type States is (idle, counting);
signal state, nextstate: States;
signal c, nextc: natural range 0 to 15;
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
		if (reset = '0') then state <= idle;
			c <= 0;
		elsif (clk'event and clk='1') then
			state <= nextstate;
			c <= nextc;
		end if;
	end process;
	aboveth <= '1' when c >=threshold else '0';

	-- display counter value on 7-segment output
	process(c)
	begin
		case c is
			when 0 => seg_val_hex <= 2#0000001#;
			when 1 => seg_val_hex <= 2#1001111#;
			when 2 => seg_val_hex <= 2#0010010#;
			when 3 => seg_val_hex <= 2#0000110#;
			when 4 => seg_val_hex <= 2#1001100#;
			when 5 => seg_val_hex <= 2#0100100#;
			when 6 => seg_val_hex <= 2#0100000#;
			when 7 => seg_val_hex <= 2#0001111#;
			when 8 => seg_val_hex <= 2#0000000#;
			when 9 => seg_val_hex <= 2#0000100#;
			when 10 => seg_val_hex <= 2#0001000#;
			when 11 => seg_val_hex <= 2#1100000#;
			when 12 => seg_val_hex <= 2#0110001#;
			when 13 => seg_val_hex <= 2#1000010#;
			when 14 => seg_val_hex <= 2#0110000#;
			when others => seg_val_hex <= 2#0111000#;
		end case;
	end process;
end impl;
