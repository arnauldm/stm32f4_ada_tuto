
# Description

Same example as `02_interrupts` but the code here makes use of the
`Ada_Driver_Library`.

You'll notice that every drivers related to the board are compiled.
However, only the necessary object files are included in the binary.

# Note

The array `blinking_leds` contains the leds we want to blink. The array index
is a *modular* type:

	type index is mod 4;

Operations on modular integers use modular (wraparound) arithmetic.
For more info about modulars:

	https://learn.adacore.com/courses/advanced-ada/parts/data_types/numerics.html#modular-types

The first led to blink is the first element in the array:

	current_led    : index   := blinking_leds'first;

Then, after a delay, the main loop blinks the next led by incrementing the
counter:

	current_led := current_led + 1;

The code always increments `current_led`, even if it has reached the biggest
index value. As the `index` type is modular, when `current_led` value is 3,
it's still possible to increment the counter. The value wraps around and
becomes 0.

