# Overview of the Design
This is a design for a digital clock on a BASYS3 FPGA Board

The user can view the time in 2 display modes:
1. HH.MM (Hours and Minutes)
2. MM.SS (Minutes and Seconds)

Here, there is a dot after the second digit continuously blinking to denote every passing second.
The user can also set the time by incrementing or decrementing separate digits of each of hours, minutes and seconds.

There are a total of 8 states of the clock, 2 in time display modes and 6 in time setting modes  

Time Display Modes  

1. HH.MM displayed (hr_min in code)
2. MM.SS displayed (min_sec in code)

Time Setting Modes  

3. Set the ten's digit of the hours by incrementing/decrementing (set_hr_1 in code)
4. Set the one's digit of the hours by incrementing/decrementing (set_hr_2 in code)
5. Set the ten's digit of the minutes by incrementing/decrementing (set_min_1 in code)
6. Set the one's digit of the minutes by incrementing/decrementing (set_min_2 in code)
7. Set the ten's digit of the seconds by incrementing/decrementing (set_sec_1 in code)
8. Set the one's digit of the seconds by incrementing/decrementing (set_sec_1 in code)

There are 6 inputs to the digital clock - 
1. A master clock of frequency 100 MHz
2. Button 1 - To change the display type in time display modes
3. Button 2 - To enter or exit time display modes
4. Button 3 - To increment the digit selected in time setting modes
5. Button 4 - To change the digit selected to set in time setting modes
6. Button 5 - To decrement the digit selected in time setting modes

There are 2 outputs to the digital clock - 
1. Anode output for the FPGA board 4 digits (4 bit vector)
2. Cathode output for the FPGA board digit (8 bit vector (7 segments + dot))

State Logic is described and explained in the code
# VHDL Design Decisions
I have designed 2 seperate sub-components along with the main component:
1. This returns a clock with a given time period multiple of the master clock
(Used to generate a seconds clock (Time period 1 sec) and blink clock (Time period 0.5 sec))
2. This return the corresponding 7 segment with dot display, given a 4 bit vector
(Used to display output)

In the main architecture,

6 separate signals are used to store each digit of the hours, minutes and signals at any point of time

4 separate signals are used to store the digits to be displayed at any point of time

1 signal is used to store the digit currently displayed (This changes at a period of 2.1 ms because of the 10.5 ms refresh rate used)

1 signal each is used to store the seconds clock and the blink clock

1 signal is used to store the blink state (0 or 1)

1 Process is used sensitive to all buttons and the seconds clock describing the state and time updation logic

For refresh, a counter upto 2^20 is set. This corresponds to 2^20/10^5 = 10.5 ms. The 2 most significant bits of this counter are used to denote the current digit to be displayed. The anode output is updated according to these 2 bits.

The 4 digit signals are combinationally updated according the current state

The display is combinationally updated to take into account blinking, and the current digit