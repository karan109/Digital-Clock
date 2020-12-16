library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY clock IS
PORT(
    clk : IN bit;
    b1 : IN bit;
    b2 : IN bit;
    b3 : IN bit;
    b4 : IN bit;
    b5 : IN bit;
    sig : OUT bit;
    anode : OUT std_logic_vector (3 DOWNTO 0);
    s1 : OUT std_logic_vector (3 DOWNTO 0);
    m1 : OUT std_logic_vector (3 DOWNTO 0);
    h1 : OUT std_logic_vector (3 DOWNTO 0);
    s2 : OUT std_logic_vector (3 DOWNTO 0);
    m2 : OUT std_logic_vector (3 DOWNTO 0);
    h2 : OUT std_logic_vector (3 DOWNTO 0);
    display: OUT std_logic_vector (7 DOWNTO 0);
    display2: OUT std_logic_vector (7 DOWNTO 0));
END clock;

ARCHITECTURE RTL OF clock IS

TYPE state_type IS(hr_min, min_sec, set_hr_1, set_hr_2, set_min_1, set_min_2, set_sec_1, set_sec_2);
SIGNAL state : state_type := hr_min;

COMPONENT bcdto7segment IS
PORT(
    bcd : IN unsigned (3 DOWNTO 0);
    dot7segment : OUT std_logic_vector (7 DOWNTO 0));
END COMPONENT bcdto7segment;

COMPONENT frequency IS
PORT(
    clk_in : IN bit;
    number : IN integer;
    new_clk : OUT bit);
END COMPONENT frequency;

SIGNAL clk_period : integer := 100;
SIGNAL blink_period : integer := 50;

SIGNAL blink_state : bit := '1';

SIGNAL SEC1 : unsigned (3 DOWNTO 0) := "0000";
SIGNAL MIN1 : unsigned (3 DOWNTO 0) := "0100";
SIGNAL HR1 : unsigned (3 DOWNTO 0) := "0010";
SIGNAL SEC2 : unsigned (3 DOWNTO 0) := "0000";
SIGNAL MIN2 : unsigned (3 DOWNTO 0) := "1000";
SIGNAL HR2 : unsigned (3 DOWNTO 0) := "0001";
SIGNAL trash : unsigned (3 DOWNTO 0) := "1111";

SIGNAL no_blink_display: std_logic_vector (7 DOWNTO 0);
SIGNAL with_blink_display: std_logic_vector (7 DOWNTO 0);

SIGNAL d1 : unsigned (3 DOWNTO 0);
SIGNAL d2 : unsigned (3 DOWNTO 0);
SIGNAL d3 : unsigned (3 DOWNTO 0);
SIGNAL d4 : unsigned (3 DOWNTO 0);

SIGNAL digit: unsigned (3 DOWNTO 0) := "0000";
SIGNAL refresh : unsigned (2 DOWNTO 0) := "000";

SIGNAL sec_clk : bit := '0';
SIGNAL blink_clk : bit := '0';

BEGIN

C1 : bcdto7segment PORT MAP (bcd => digit,dot7segment => no_blink_display);
C2 : frequency PORT MAP (clk_in => clk, number => clk_period, new_clk => sec_clk);
C3 : frequency PORT MAP (clk_in => clk, number => blink_period, new_clk => blink_clk);

PROCESS(clk) BEGIN
IF clk = '1' AND clk'EVENT THEN
    IF refresh = "111" THEN
        refresh <= "000";
    ELSE refresh <= refresh + 1;
    END IF;
END IF;
END PROCESS;

--PROCESS (sec_clk) BEGIN
--IF sec_clk = '1' AND sec_clk'EVENT AND (state = hr_min OR state = min_sec) THEN
--    IF SEC2 = "1001" THEN
--        SEC2 <= "0000";
--        IF SEC1 = "0101" THEN
--            SEC1 <= "0000";
--            IF MIN2 = "1001" THEN
--                MIN2 <= "0000";
--                IF MIN1 = "0101" THEN
--                    MIN1 <= "0000";
--                    IF HR2 = "0011" AND HR1 = "0010" THEN
--                        HR2 <= "0000"; HR1 <= "0000";
--                    ELSIF HR2 = "1001" THEN
--                        HR2 <= "0000"; HR1 <= HR1 + 1;
--                    ELSE HR2 <= HR2 + 1;
--                    END IF;
--                ELSE MIN1 <= MIN1 + 1;
--                END IF;
--            ELSE MIN2 <= MIN2 + 1;
--            END IF;
--        ELSE SEC1 <= SEC1 + 1;
--        END IF;
--    ELSE SEC2 <= SEC2 + 1;
--    END IF;
--END IF;
--END PROCESS;


PROCESS(refresh(2 DOWNTO 1))
BEGIN
    CASE refresh(2 DOWNTO 1) IS
    WHEN "00" => anode <= "0111"; digit <= d1;
    when "01" => anode <= "1011"; digit <= d2;
    WHEN "10" => anode <= "1101"; digit <= d3;
    WHEN OTHERS => anode <= "1110"; digit <= d4;
    END CASE;
END PROCESS;


PROCESS(blink_clk) BEGIN
IF blink_clk = '1' AND blink_clk'EVENT THEN
    IF blink_state = '0' THEN blink_state <= '1';
    ELSE blink_state <= '0';
    END IF;
END IF;
END PROCESS;


PROCESS (sec_clk, b1, b2, b3, b4) BEGIN

    IF state = hr_min OR state = min_sec THEN

        IF sec_clk = '1' AND sec_clk'EVENT THEN
            IF SEC2 = "1001" THEN
                SEC2 <= "0000";
                IF SEC1 = "0101" THEN
                    SEC1 <= "0000";
                    IF MIN2 = "1001" THEN
                        MIN2 <= "0000";
                        IF MIN1 = "0101" THEN
                            MIN1 <= "0000";
                            IF HR2 = "0011" AND HR1 = "0010" THEN
                                HR2 <= "0000"; HR1 <= "0000";
                            ELSIF HR2 = "1001" THEN
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

        IF state = hr_min THEN
            IF b2 = '1' AND b2'EVENT THEN state <= set_hr_1;
            ELSIF b1 = '1' AND b1'EVENT THEN state <= min_sec;
            END IF;

        ELSIF b2 = '1' AND b2'EVENT THEN state <= set_hr_1;
        ELSIF b1 = '1' AND b1'EVENT THEN state <= hr_min;

        END IF;

    ELSE

        CASE state IS
        WHEN hr_min =>
            IF b2 = '1' AND b2'EVENT THEN state <= set_hr_1;
            ELSIF b1 = '1' AND b1'EVENT THEN state <= min_sec;
            END IF;
        WHEN min_sec =>
            IF b2 = '1' AND b2'EVENT THEN state <= set_hr_1;
            ELSIF b1 = '1' AND b1'EVENT THEN state <= hr_min;
            END IF;
        WHEN set_hr_1 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF HR1 = "0010" THEN HR1 <= "0000"; ELSE HR1 <= HR1 + 1; END IF;
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_hr_2;
            END IF;
        WHEN set_hr_2 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            ELSIF b3 = '1' AND b3'EVENT THEN
                IF HR1 = "0010" AND HR2 = "0011" THEN HR2 <= "0000";
                ELSIF HR2 = "1001" THEN HR2 <= "0000"; ELSE HR2 <= HR2 + 1; END IF;
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_min_1;
            END IF;
        WHEN set_min_1 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            ELSIF b3 = '1' AND b3'EVENT THEN
                IF MIN1 = "0001" THEN MIN1 <= "0000"; ELSE MIN1 <= MIN1 + 1; END IF;
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_min_2;
            END IF;
        WHEN set_min_2 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF MIN2 = "1001" THEN MIN2 <= "0000"; ELSE MIN2 <= MIN2 + 1; END IF;
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_sec_1;
            END IF;
        WHEN set_sec_1 => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF SEC1 = "0101" THEN SEC1 <= "0000"; ELSE SEC1 <= SEC1 + 1; END IF;
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_sec_2;
            END IF;
        WHEN OTHERS => 
            IF b2 = '1' AND b2'EVENT THEN state <= hr_min;
            ELSIF b3 = '1' AND b3'EVENT THEN 
                IF SEC2 = "1001" THEN SEC2 <= "0000"; ELSE SEC2 <= SEC2 + 1; END IF;
            ELSIF b4 = '1' AND b4'EVENT THEN state <= set_hr_1;
            END IF;
        END CASE;

    END IF;

END PROCESS;

s1 <= std_logic_vector(SEC1);
m1 <= std_logic_vector(MIN1);
h1 <= std_logic_vector(HR1);
s2 <= std_logic_vector(SEC2);
m2 <= std_logic_vector(MIN2);
h2 <= std_logic_vector(HR2);
WITH state SELECT d1 <= 
    HR1 WHEN hr_min, HR1 WHEN set_hr_1, HR1 WHEN set_hr_2,
    MIN1 WHEN min_sec, MIN1 WHEN set_min_1, MIN1 WHEN set_min_2,
    SEC1 WHEN OTHERS;
WITH state SELECT d2 <= 
    HR2 WHEN hr_min, HR2 WHEN set_hr_1, HR2 WHEN set_hr_2,
    MIN2 WHEN min_sec, MIN2 WHEN set_min_1, MIN2 WHEN set_min_2,
    SEC2 WHEN OTHERS;
WITH state SELECT d3 <= 
    MIN1 WHEN hr_min,
    SEC1 WHEN min_sec,
    trash WHEN OTHERS;
WITH state select d4 <= 
    MIN2 WHEN hr_min,
    SEC2 WHEN min_sec,
    trash WHEN OTHERS;


sig <= blink_clk;
with_blink_display <= 
    no_blink_display(7 DOWNTO 1) & "0" WHEN (blink_state = '0' AND refresh(2 DOWNTO 1) = "01" AND (state = hr_min OR state = min_sec))
    ELSE "11111111" WHEN blink_state = '1' AND (state = set_hr_1 OR state = set_hr_2 OR state = set_min_1 OR state = set_min_2 OR state = set_sec_1 OR state = set_sec_2)
    ELSE no_blink_display;
display <= with_blink_display;
display2 <= no_blink_display;
end RTL;