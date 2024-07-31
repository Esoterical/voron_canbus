---
layout: default 
title: TMC Reset or Undervoltage
parent: Troubleshooting
---

# TMC reset or undervoltage error

Rarely there can be errors coming from the TMC driver, along the lines of:

`TMC 'extruder' reports GSTAT:      00000001 reset=1(Reset)`

WHile this can be caused by a brief power interruption, it may *also* be caused by static discharge that has been accumulated on the filament feed and arcing in the motor coils which transfers to the TMC stepper driver.

This can also manifest on the TMC2240 driver (as used on the BTT SB2240 toolhead board) as an `uv_cp=1(Undervoltage!)` error.

Something easy to try to stop this static charge from building up and causing issues is to connect the extruder motor to a free GND pin on the toolhead board to help shunt any accumulated charge to the negative power rail.

A simple ring terminal and nut on the motor mounting screw which then goes to any free ground pin is sufficient.

![image](https://github.com/user-attachments/assets/e48e5ad3-4ea5-4518-b424-d51a377c5729)

**Please Note** this may not be the silver bullet to solve all your issues, but *if* the reset/undervoltage error is due to static buildup then this workaround has had good results.
