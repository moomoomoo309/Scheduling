# Scheduling

### How to run:
- Find an online Lua interpreter, or use a local one if you have it. (http://www.lua.org/demo.html or https://repl.it/languages/lua for example)
- Paste it in and execute Scheduling2.lua, or download it and run it locally. If you get an error like this `input:1: unexpected symbol near '#'`, delete the first line. (#!/usr/bin/luajit)
- Change the value of processes, thickBoxes, justify, and algorithm as needed. (around line 607 in Scheduling2, and 334 in Scheduling at the time of writing)
- Run it!

### How to edit:
- Don't bother editing Scheduling2. Scheduling2 is fraction.lua, minus the last line, then Scheduling is appended, minus the first 3 lines.
- Set up a local lua environment (https://github.com/rjpcomputing/luaforwindows for windows, in OSX and Linux, it should be in brew / your package manager)
- Clone this repository.
- Edit Scheduling and fraction to your liking.
- When you're done, run concat.lua, it'll put Scheduling2 back together for you.
