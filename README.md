This repository contains the source files for the firmware used in

# Hacking Louie

Looping Louie is a popular childrens game by Hasbro (which is frequently misused as drinking game by students).
It consists of a central rotating pillar with rotating arm attached, which lets a little plane spin around in a circle.
Players try to knock the plane into the air with paddles before it hits their base, costing them lives (plastic coins).
Though mechanically pretty simple, the game still contains small parts that get lost frequently (mainly, the plastic coins).

We wanted to make the game more exciting, portable and just all-around cooler by integrating microcontrollers
into the base and paddles, making motor speed and lighting cue variation possible, as well as counting your strikes easier.

The central motor assembly has been modified to include a MOSFET motor driver controlled by PWM from an ATmega8 microcontroller,
as well as a 10-pin DIP switch controlling fixed/random motor speed settings and more.

The paddles have been modified to display 4 LEDs on top, representing the remaining strikes for a player, as well as a switch
for resetting the paddle counter and increasing the handicap if wanted. The strike counter is triggered by a hall sensor in the front
of the paddle, reacting to a magnet attached to the plane.

All these improvements are backwards-compatible, meaning it is still possible to play with plastic chips.

# Authors

* Hardware: [@Indidev](http://github.com/Indidev)
* Firmware: [@cbdev](http://github.com/cbdevnet) 
