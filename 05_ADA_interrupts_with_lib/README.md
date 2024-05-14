
# Description

That example is the same as `04_ADA_interrupts` but the code makes use of the
`Ada_Driver_Library`.

You'll note that every drivers related to the board are compiled!

# Note

There's a nice Ada hack to light the leds one after each other.

The array `blinking_leds` defines the array containing the leds we
want to blink. Note that the index is defined like this:

	type index is mod 4;

And the first led to blink is the first one:

	current_led    : index   := blinking_leds'first;

Then, the main loop blinks the next one:

	current_led := current_led + 1;

We always increment `current_led`, even if it's the biggest possible value.
It's possible because it's a modular type. 

