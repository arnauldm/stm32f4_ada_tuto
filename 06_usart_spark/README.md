
# Description

That code uses SPARK. To launch the prover, just execute the following:

	make prove

It will lauch `gnatprove`:

	gnatprove -P main.gpr

The code is almost the same as in the last example, but the low-level
packages have been "sparkified". As a result, the whole code is
almost fully proved.

You'll note two things:

1. Some packages are not proved. They use some Ada features not compatible with
   SPARK and therefore *spark_mode* is off.

2. The prover still generates some warnings. They are several reasons for this but
   the main reason is that provers don't deal well with aliasing. The current
   code uses `with address => ...` clauses which permit aliasing (even if
   the code in src/ doesn't use such aliasing).

