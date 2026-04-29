# 'Keyboard' Use

We were unable to get a USB keyboard working. As a result ASCII characters must be entered 4 bits at a time with the onboard switches. Pressing button 2 changes into 'keyboard mode'. In this mode the seven segment display will show a hexadecimal representation of the character to be sent to the z80 core. To modify this value button 3 can be pressed to set the lower 4 bits of the byte. The upper 4 bits are set to the previous contents of the lower 4 bits. To enter a character, for example 'A', you must do the following:

1. Look up the correct hex value for the desired character. I like [this table](https://www.ascii-code.com/). We see that 'A' corresponds to 0x41.
2. Switch to keyboard mode by pressing button 2. The RGB LED should turn purple.
3. Enter 0100 (0x4) onto the bank of 4 switches.
4. Press button 3 to update the buffer. It should now read '04'.
5. Enter 0001 (0x1) onto the bank of 4 switches.
5. Press button 3 again. The seven segment display should now read '41' as desired.
6. Exit keyboard mode by pressing button 2. This sends the character to the z80 core. It is easy to send multiple copies of the same character by repeatedly pressing button 2 as the buffer is never cleared. Sometimes (due to a timing bug) the character will not be received. Pressing button 2 twice will attempt to resend the character.

With a bit of practice you can manage ~5-10 characters per minute. Good luck!