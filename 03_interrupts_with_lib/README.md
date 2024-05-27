
# Description

That example is the same as `04_ADA_interrupts` but the code makes use of the
`Ada_Driver_Library`.

Every drivers related to the board are compiled, but only the necessary
object files are included in the binary.

# Note

The array `blinking_leds` defines the array containing the leds we
want to blink. That the index is a modular type, defined like this:

	type index is mod 4;

The first led to blink is the first element in the array:

	current_led    : index   := blinking_leds'first;

Then, after a delay, the main loop blinks the next led by incrementing the
counter:

	current_led := current_led + 1;

The code always increments `current_led`, even if it has reached the biggest
index value. As the `index` type is modular, when `current_led` value is 3,
it's still possible to increment the counter. The value "rewind" and is then 0.

