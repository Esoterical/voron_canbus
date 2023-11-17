# Timeout during homing and/or probing

I'm going to make a couple of assumptions right at the start for this section as this 'symptom' could be from different causes. So to narrow it down this section is if:

- Your printer gets an error along the lines of `Timeout during homing` or `Timeout during probe` or `Timeout during homing probe`
- This error doesn't *always* happen. Sometimes it'll home fine or probe fine and start printing.
- Once your printer is printing it doesn't error out, it only happens during axis homing or a bed mesh.

If your symptoms match the above read on. If you can't even finish a homing or probing actuion error, or you sometimes can but you frequently get ["lost connection to mcu"](./lost_connection_to_mcu.md) or ["timer too close"](./timer_too_close.md) errors please read those relevant sections first then return here if your symptoms more align with the above.

With that out of the way, this kind of problem is usually the cause of your Pi not keeping up with klipper during a homing or probing operation. These operations require very tight timings and an underpowered board or a board with a lot of background processes going on can somtimes miss a timing window and cause this error. Or sometimes a board that "should" work fine still does it, which I suspect is something lower level in the linux kernel, but that's not a discussion for here.




`sed -i 's\TRSYNC_TIMEOUT = 0.025\TRSYNC_TIMEOUT = 0.05\g' ~/klipper/klippy/mcu.py`
`cat klipper/klippy/mcu.py | grep "TRSYNC_TIMEOUT ="`


[Return to Troubleshooting](./)
