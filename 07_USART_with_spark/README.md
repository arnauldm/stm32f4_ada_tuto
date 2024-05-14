
# Description

That code makes use of SPARK. To launch the proof, just do:

	make prove

It'll lauch `gnatprove`:

	gnatprove -P main.gpr

The code is almost the same as in the last example. Note although
that the components provided by the `Ada_Driver_Library` can't be included
in the proof. Thus, I had to slightly change the way the "unproved" functions
are called by the main procedure.

They are some messages about potentially initialized variables. I think
that we can get rid off them.

The last message is about an *integer overflow*.


