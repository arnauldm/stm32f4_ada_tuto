
# Description

That code makes use of SPARK.

# Prerequisite

There's currently a 'bug' in a package included by Ada_Drivers_Library.
In practice, it requires you to edit `ST7735R` package and to set `spark_mode`
to `off`:

	vi Ada_Drivers_Library/components/src/screen/ST7735R/st7735r.ads
        
Before editing:

	package ST7735R is

After:

	package ST7735R
   		with spark_mode => off
	is

# Using gnatprove

To launch the prover, just execute the following:

	make prove

It will lauch `gnatprove`:

	gnatprove -P main.gpr

The code is almost the same as in the last example.

The components provided by the Ada_Driver_Library can't be included
in the proof. Thus, I had to slightly change the way the "unproved" functions
are called by the main procedure.

The prover successfully detect an *integer overflow*:

	main.adb:34:26: medium: range check might fail, cannot prove upper bound for counter + 1
	   34 |      counter := counter + 1;
	      |                 ~~~~~~~~^~~
	  reason for check: result of addition must fit in the target type of the assignment
	  possible fix: loop at line 20 should mention counter in a loop invariant
	   20 |   loop
	      |   ^ here

