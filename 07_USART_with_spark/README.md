
# Description

That code makes use of SPARK. To launch the prover, just execute the following:

	make prove

It will lauch `gnatprove`:

	gnatprove -P main.gpr

The code is almost the same as in the last example.


# Note

The components provided by the Ada_Driver_Library can't be included
in the proof. Thus, I had to slightly change the way the "unproved" functions
are called by the main procedure.

They are some messages about potentially initialized variables. They can be
ignored.

The important thing is that the prover successfully detect an *integer overflow*.

