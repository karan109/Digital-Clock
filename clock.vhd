library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY clock IS
PORT(
    clk : IN bit; -- clk is the master clock of the BASYS3 FPGA board with frequency 100 MHz
    b1 : IN bit; -- Button 1 (To change the display type in time display modes)
    b2 : IN bit; -- Button 2 (To enter or exit time display modes)
    b3 : IN bit; -- Button 3 (To increment the digit selected in time setting modes)
    b4 : IN bit; -- Button 4 (To change the digit selected to set in time setting modes)
    b5 : IN bit; -- Button 5 (To decrement the digit selected in time setting modes)
    anode : OUT std_logic_vector (3 DOWNTO 0); -- Anode output for the FPGA board 4 digits
    display: OUT std_logic_vector (7 DOWNTO 0)); -- Cathode output for the FPGA board digit
END clock;

ARCHITECTURE ARCH_MAIN OF clock IS

TYPE state_type IS(hr_min, min_sec, set_hr_1, set_hr_2, set_min_1, set_min_2, set_sec_1, set_sec_2);
-- Description os states:
-- 1. hr_min : Normal time mode of clock in which HH.MM is displayed (Hours and Minutes Mode)
-- 2. min_sec : Normal time mode of clock in which MM.SS is displayed (Minutes and Seconds Mode)
-- 3. set_hr_1 : Time setting mode in which user changes the ten's digit of the Hours
-- 4. set_hr_2 : Time setting mode in which user changes the one's digit of the Hours
-- 5. set_min_1 : Time setting mode in which user changes the ten's digit of the Minutes
-- 6. set_min_2 : Time setting mode in which user changes the one's digit of the Minutes
-- 7. set_sec_1 : Time setting mode in which user changes the ten's digit of the Seconds
-- 8. set_sec_2 : Time setting mode in which user changes the one's digit of the Seconds


SIGNAL state : state_type := hr_min; -- Assign initial state of clock to display HH.MM


-- Component instantiation for bcdto7segment defined in bcdto7segment.vhd
COMPONENT bcdto7segment IS
PORT(
    bcd : IN unsigned (3 DOWNTO 0);
    dot7segment : OUT std_logic_vector (7 DOWNTO 0));
END COMPONENT bcdto7segment;
-- This takes a 4 bit unsigned vector and outputs the 7 segment display with decimal vector

-- Component instantiation for frequency defined in frequency.vhd
COMPONENT frequency IS
PORT(
    clk_in : IN bit;
    number : IN integer;
    new_clk : OUT bit);
END COMPONENT frequency;
-- This takes the master clock, "clk_in" and an integer, "number" as input and generates 
-- a signal with time period = number * (time period of clock)

SIGNAL clk_period : integer := 100000000; -- Time period of 1 second clock
SIGNAL blink_period : integer := 50000000; -- Time period for blinking (This is twice as fast as seconds clock)

SIGNAL blink_state : bit := '1';
-- When blink_state = '0' then turn the light on the corresponding segment(s)
-- When blink_state = '1' then turn off the corresponding segment(s)


SIGNAL SEC1 : unsigned (3 DOWNTO 0) := "0000"; -- Stores the value of ten's digit of seconds
SIGNAL MIN1 : unsigned (3 DOWNTO 0) := "0000"; -- Stores the value of ten's digit of minutes
SIGNAL HR1 : unsigned (3 DOWNTO 0) := "0000"; -- Stores the value of ten's digit of hours
SIGNAL SEC2 : unsigned (3 DOWNTO 0) := "0000"; -- Stores the value of one's digit of seconds
SIGNAL MIN2 : unsigned (3 DOWNTO 0) := "0000"; -- Stores the value of one's digit of minutes
SIGNAL HR2 : unsigned (3 DOWNTO 0) := "0000"; -- Stores the value of one's digit of hours


SIGNAL trash : unsigned (3 DOWNTO 0) := "1111"; 
-- This corresponds to a junk value when we do not want to display anything


SIGNAL no_blink_display: std_logic_vector (7 DOWNTO 0);
-- What the actual output should be on the FPGA board if blinking is not implemented


SIGNAL d1 : unsigned (3 DOWNTO 0); -- Stores the left most digit at any point of time
SIGNAL d2 : unsigned (3 DOWNTO 0); -- Stores the second to left digit at any point of time
SIGNAL d3 : unsigned (3 DOWNTO 0); -- Stores the second to right digit at any point of time
SIGNAL d4 : unsigned (3 DOWNTO 0); -- Stores the right most digit at any point of time

SIGNAL digit: unsigned (3 DOWNTO 0) := "0000";
-- Actual digit to be displayed on the FPGA board

SIGNAL refresh : unsigned (19 DOWNTO 0) := "00000000000000000000";
-- Stores a 20 bit modulo counter corresponding to 2^20 clock cycles
-- This makes it an approximately 10.5 ms cycle (Within the range of the required refresh rate) 

SIGNAL sec_clk : bit := '0'; -- The second clock signal
SIGNAL blink_clk : bit := '0'; -- The blink clock signal

BEGIN

C1 : bcdto7segment PORT MAP (bcd => digit,dot7segment => no_blink_display);
-- This component convertes the SIGNAL "digit" to its 7 segment with decimal counterpart

C2 : frequency PORT MAP (clk_in => clk, number => clk_period, new_clk => sec_clk);
-- Get the seconds clock from the master clock

C3 : frequency PORT MAP (clk_in => clk, number => blink_period, new_clk => blink_clk);
-- Get the blink clock from the master clock


-- This is a modulo refresh counter which is set to 0 after a cycle of approximately 10.5 ms
PROCESS(clk) BEGIN
IF clk = '1' AND clk'EVENT THEN
    IF refresh = "11111111111111111111" THEN
        refresh <= "00000000000000000000";
    ELSE refresh <= refresh + 1;
    END IF;
END IF;
END PROCESS;


-- The 4 digits take places to be displayed at an interval of 10.5/4 = 2.125 ms
-- This can be easily implemented considering the 2 MSBs of the refresh counter
PROCESS(refresh(19 DOWNTO 18))
BEGIN
    CASE refresh(19 DOWNTO 18) IS
    WHEN "00" => anode <= "0111"; digit <= d1; 
    -- When 2 MSBs are "00", display the left most digit
    -- Anode output is set accordingly where 0 means set and 1 means not set

    when "01" => anode <= "1011"; digit <= d2; -- When 2 MSBs are "01", display the second to left digit
    WHEN "10" => anode <= "1101"; digit <= d3; -- When 2 MSBs are "10", display the second to right digit
    WHEN OTHERS => anode <= "1110"; digit <= d4; -- When 2 MSBs are "11", display the right most digit
    END CASE;
END PROCESS;


-- Configure blink_state using blink clock
PROCESS(blink_clk) BEGIN
IF blink_clk = '1' AND blink_clk'EVENT THEN
    IF blink_state = '0' THEN blink_state <= '1';
    ELSE blink_state <= '0';
    END IF;
END IF;
END PROCESS;


-- Process sensitive to all buttons and the seconds clock
PROCESS (sec_clk, b1, b2, b3, b4, b5) BEGIN
    
    -- If state is in time display modes, then only update time after every seconds clock cycle
    IF state = hr_min OR state = min_sec THEN

        IF sec_clk = '1' AND sec_clk'EVENT THEN -- Detect rising edge of seconds clock

            -- This block updates the signals of SEC1, SEC2, MIN1, MIN2, HR1, HR2 accordingly
            IF SEC2 = "1001" THEN -- 9 is max value for one's digit
                SEC2 <= "0000";
                IF SEC1 = "0101" THEN -- 5 is max value for ten's digit
                    SEC1 <= "0000";
                    IF MIN2 = "1001" THEN -- 9 is max value for one's digit
                        MIN2 <= "0000";
                        IF MIN1 = "0101" THEN -- 5 is max value for ten's digit
                            MIN1 <= "0000";
                            IF HR2 = "0011" AND HR1 = "0010" THEN -- Hours should not be more than 23
                                HR2 <= "0000"; HR1 <= "0000";
                            ELSIF HR2 = "1001" THEN -- 9 is max value for one's digit
                                HR2 <= "0000"; HR1 <= HR1 + 1;
                            ELSE HR2 <= HR2 + 1;
                            END IF;
                        ELSE MIN1 <= MIN1 + 1;
                        END IF;
                    ELSE MIN2 <= MIN2 + 1;
                    END IF;
                ELSE SEC1 <= SEC1 + 1;
                END IF;
            ELSE SEC2 <= SEC2 + 1;
            END IF;
        END IF;

        -- State logic for state 1 (hr_min)
        IF state = hr_min THEN
            IF b2 = '1' AND b2'EVENT THEN state <= set_hr_1; 
            -- If Button 2 is pushed, enter time setting mode with initially control of the ten's digit of hours (state 3)
            ELSIF b1 = '1' AND b1'EVENT THEN state <= min_sec;
            -- If Button 1 is pushed, change display type to display MM.SS (Minutes and Seconds) (state 2)
            END IF;

        -- State logic for state 2 (min_sec)
        ELSIF b2 = '1' AND b2'EVENT THEN state <= set_hr_1;
        -- If Button 2 is pushed, enter time setting mode with initially control of the ten's digit of hours (state 3)
        ELSIF b1 = '1' AND b1'EVENT THEN state <= hr_min;
        -- If Button 1 is pushed, change display type to display HH.MM (Hours and Minutes) (state 1)
        END IF;

    ELSE

        CASE state IS
        
        -- State logic for state 3 (set_hr_1)
        WHEN set_hr_1 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            -- If Button 2 is pushed, enter time display mode with HH.MM (state 1)
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF HR1 = "0010" THEN HR1 <= "0000"; ELSE HR1 <= HR1 + 1; END IF;
            -- If Button 3 is pushed, modulo increment the ten's digit of the hours, keeping the maximum value 2
            ELSIF b5 = '1' AND b5'EVENT THEN 
                IF HR1 = "0000" THEN HR1 <= "0010"; ELSE HR1 <= HR1 - 1; END IF;
            -- If Button 5 is pushed, decrement (and wrap around 0) the ten's digit of the hours, keeping the maximum value 2
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_hr_2;
            -- If Button 4 is pushed, move to state 4 to change the one's digit of hours
            END IF;
        
        -- State logic for state 4 (set_hr_2)
        WHEN set_hr_2 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            -- If Button 2 is pushed, enter time display mode with HH.MM (state 1)
            ELSIF b3 = '1' AND b3'EVENT THEN
                IF HR1 = "0010" AND HR2 = "0011" THEN HR2 <= "0000";
                ELSIF HR2 = "1001" THEN HR2 <= "0000"; ELSE HR2 <= HR2 + 1; END IF;
            -- If Button 3 is pushed, modulo increment the one's digit of the hours
            -- The maximum value is 3 if the ten's digit is set to 2, else it is 9
            ELSIF b5 = '1' AND b5'EVENT THEN
                IF HR1 = "0010" AND HR2 = "0000" THEN HR2 <= "0011";
                ELSIF HR2 = "0000" THEN HR2 <= "1001"; ELSE HR2 <= HR2 - 1; END IF;
            -- If Button 5 is pushed, decrement and wrap around 0 the one's digit of the hours
            -- The maximum value is 3 if the ten's digit is set to 2, else it is 9
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_min_1;
            -- If Button 4 is pushed, move to state 5 to change the ten's digit of minutes
            END IF;
        
        -- State logic for state 5 (set_min_1)
        WHEN set_min_1 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            -- If Button 2 is pushed, enter time display mode with HH.MM (state 1)
            ELSIF b3 = '1' AND b3'EVENT THEN
                IF MIN1 = "0101" THEN MIN1 <= "0000"; ELSE MIN1 <= MIN1 + 1; END IF;
            -- If Button 3 is pushed, modulo increment the ten's digit of the minutes, keeping the maximum value 5
            ELSIF b5 = '1' AND b5'EVENT THEN
                IF MIN1 = "0000" THEN MIN1 <= "0101"; ELSE MIN1 <= MIN1 - 1; END IF;
            -- If Button 5 is pushed, decrement the ten's digit of the minutes, keeping the maximum value 5
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_min_2;
            -- If Button 4 is pushed, move to state 6 to change the one's digit of minutes
            END IF;
        
        -- State logic for state 6 (set_min_2)
        WHEN set_min_2 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            -- If Button 2 is pushed, enter time display mode with HH.MM (state 1)
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF MIN2 = "1001" THEN MIN2 <= "0000"; ELSE MIN2 <= MIN2 + 1; END IF;
            -- If Button 3 is pushed, modulo increment the one's digit of the minutes, keeping the maximum value 9
            ELSIF b5 = '1' AND b5'EVENT THEN 
                IF MIN2 = "0000" THEN MIN2 <= "1001"; ELSE MIN2 <= MIN2 - 1; END IF;
            -- If Button 5 is pushed, decrement the one's digit of the minutes, keeping the maximum value 9
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_sec_1;
            -- If Button 4 is pushed, move to state 7 to change the ten's digit of seconds
            END IF;
        
        -- State logic for state 7 (set_sec_1)
        WHEN set_sec_1 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            -- If Button 2 is pushed, enter time display mode with HH.MM (state 1)
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF SEC1 = "0101" THEN SEC1 <= "0000"; ELSE SEC1 <= SEC1 + 1; END IF;
            -- If Button 3 is pushed, modulo increment the ten's digit of the seconds, keeping the maximum value 5
            ELSIF b5 = '1' AND b5'EVENT THEN 
                IF SEC1 = "0000" THEN SEC1 <= "0101"; ELSE SEC1 <= SEC1 - 1; END IF;
            -- If Button 5 is pushed, decrement the ten's digit of the seconds, keeping the maximum value 5
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_sec_2;
            -- If Button 4 is pushed, move to state 8 to change the one's digit of seconds
            END IF;
        
        -- State logic for state 8 (set_sec_2)
        WHEN OTHERS => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            -- If Button 2 is pushed, enter time display mode with HH.MM (state 1)
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF SEC2 = "1001" THEN SEC2 <= "0000"; ELSE SEC2 <= SEC2 + 1; END IF;
            -- If Button 3 is pushed, modulo increment the one's digit of the seconds, keeping the maximum value 9
            ELSIF b5 = '1' AND b5'EVENT THEN 
                IF SEC2 = "0000" THEN SEC2 <= "1001"; ELSE SEC2 <= SEC2 - 1; END IF;
            -- If Button 5 is pushed, decrement the one's digit of the seconds, keeping the maximum value 9
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_hr_1;
            -- If Button 4 is pushed, move to state 3 to change the ten's digit of hours
            END IF;
        END CASE;

    END IF;

END PROCESS;

-- Setting d1 according to the state
WITH state SELECT d1 <= 
    HR1 WHEN hr_min, HR1 WHEN set_hr_1, HR1 WHEN set_hr_2,
    -- d1 is HR1 (ten's digit of hours) when state is hr_min (HH.MM time display mode), 
    -- or set_hr_1(time setting mode for HR1), or set_hr_2(time setting mode for HR2)
    MIN1 WHEN min_sec, MIN1 WHEN set_min_1, MIN1 WHEN set_min_2,
    -- d1 is MIN1 (ten's digit of minutes) when state is min_sec (MM.SS time display mode), 
    -- or set_min_1(time setting mode for MIN1), or set_min_2(time setting mode for MIN2)
    SEC1 WHEN OTHERS;
    -- d1 is SEC1 when state is set_sec_1(time setting mode for SEC1), or set_sec_2(time setting mode for SEC2)

-- Setting d2 according to the state
WITH state SELECT d2 <= 
    HR2 WHEN hr_min, HR2 WHEN set_hr_1, HR2 WHEN set_hr_2,
    -- d2 is HR2 (one's digit of hours) when state is hr_min (HH.MM time display mode), 
    -- or set_hr_1(time setting mode for HR1), or set_hr_2(time setting mode for HR2)
    MIN2 WHEN min_sec, MIN2 WHEN set_min_1, MIN2 WHEN set_min_2,
    -- d2 is MIN2 (one's digit of minutes) when state is min_sec (MM.SS time display mode), 
    -- or set_min_1(time setting mode for MIN1), or set_min_2(time setting mode for MIN2)
    SEC2 WHEN OTHERS;
    -- d2 is SEC2 when state is set_sec_1(time setting mode for SEC1), or set_sec_2(time setting mode for SEC2)

-- Setting d3 according to the state
WITH state SELECT d3 <= 
    MIN1 WHEN hr_min,
    -- d3 is MIN1 (ten's digit of minutes) when state is hr_min (HH.MM time display mode)
    SEC1 WHEN min_sec,
    -- d3 is SEC1 (ten's digit of seconds) when state is min_sec (MM.SS time display mode)
    trash WHEN OTHERS;
    -- d3 is empty in other states

-- Setting d4 according to the state
WITH state SELECT d4 <= 
    MIN2 WHEN hr_min,
    -- d3 is MIN2 (one's digit of minutes) when state is hr_min (HH.MM time display mode)
    SEC2 WHEN min_sec,
    -- d3 is SEC2 (one's digit of seconds) when state is min_sec (MM.SS time display mode)
    trash WHEN OTHERS;
    -- d4 is empty in other states

-- Setting the display, 7 segments with decimal (Cathode output for the FPGA board digit)
display <= 
    no_blink_display(7 DOWNTO 1) & "0" WHEN blink_state = '0' AND refresh(19 DOWNTO 18) = "01" AND (state = hr_min OR state = min_sec)
    -- In the time display modes, when blink_state is 0, make the LSB of the display segment to 0 
    -- to show the dot on digit d2 (refresh_state "01" corresponds to d2)
    ELSE "11111111" WHEN blink_state = '1' AND state = set_hr_1 AND refresh(19 DOWNTO 18) = "00"
    -- When blink_state is 0 and state is set_hr_1 (setting the ten's digit of hours),
    -- make the digit d1 (refresh_state "00" corresponds to d1) disappear from the display
    -- This makes the digit which is currently being set by the user, to blink at constant intervals of 0.5 s
    -- This is almost same as the dot blinking and these 2 things use the same clock
    -- This way the user knows which digit is being currently set
    ELSE "11111111" WHEN blink_state = '1' AND state = set_hr_2 AND refresh(19 DOWNTO 18) = "01"
    -- When blink_state is 0 and state is set_hr_2 (setting the ten's digit of hours),
    -- make the digit d2 (refresh_state "01" corresponds to d2) disappear from the display
    ELSE "11111111" WHEN blink_state = '1' AND state = set_min_1 AND refresh(19 DOWNTO 18) = "00"
    -- When blink_state is 0 and state is set_min_1 (setting the ten's digit of minutes),
    -- make the digit d1 (refresh_state "00" corresponds to d1) disappear from the display
    ELSE "11111111" WHEN blink_state = '1' AND state = set_min_2 AND refresh(19 DOWNTO 18) = "01"
    -- When blink_state is 0 and state is set_min_2 (setting the ten's digit of minutes),
    -- make the digit d2 (refresh_state "01" corresponds to d2) disappear from the display
    ELSE "11111111" WHEN blink_state = '1' AND state = set_sec_1 AND refresh(19 DOWNTO 18) = "00"
    -- When blink_state is 0 and state is set_sec_1 (setting the ten's digit of seconds),
    -- make the digit d1 (refresh_state "00" corresponds to d1) disappear from the display
    ELSE "11111111" WHEN blink_state = '1' AND state = set_sec_2 AND refresh(19 DOWNTO 18) = "01"
    -- When blink_state is 0 and state is set_sec_2 (setting the ten's digit of seconds),
    -- make the digit d2 (refresh_state "01" corresponds to d2) disappear from the display
    ELSE no_blink_display;
    -- Display the intended digit in other cases

end ARCH_MAIN;