# Parallelism and Unfolding
The objective of this lab is to compare the complexity and timing between a direct FIR filter and a parallel TDF unfolding 4 filter.

So, we must:
* Design and implement a parallel FIR.
* Design and implement a TDF filter with an unfolding factor of 4.
* Design a testbench for both methods.
* Create an XDC file with a clock of 100MHz.
* Get the critical path, timing, and usage report.

Also:
* Input/Output parallelism: 4.
* Resolution: **X** S(8,7), **h** (8,7), **Y** determined by the designer.
* All filters use the same coefficients.

$$
\begin{align*}
h_0&=8'd0\\
h_1&=8'd229\\
h_2&=8'd0\\
h_3&=8'd81\\
h_4&=8'd127\\
h_5&=8'd81\\
h_6&=8'd0\\
h_7&=8'd229\\
\end{align*}
$$

# Solution
## Parallel Direct FIR Filter
The RTL for this filter is shown below:
<img src="doc/fir_parallel.png">

In the image above, it's possible to observe the need for a regressor, which is shown as follows:
<img src="doc/regressor.png">

This way, the parallel FIR filter with a parallel factor of 4 is designed.

## TDF FIR Filter with an Unfolding Factor of 4
Applying the unfolding technique, we obtain the following RTL:
<img src="doc/fir_tdf_unfolded.png">

which is based on its original design:
<img src="doc/fir_tdf.png">

# Timing and Usage Report
When the timing report was obtained, there were timing issues with the parallel FIR filter. Although the synthesis was relaunched with forced re-timing, the timing issues still remain. So, the pipeline technique was applied as follows in the sum tree:
<img src="doc/no_pipeline.png">
<img src="doc/pipeline.png">

Finally, the synthesis results with timing and usage reports are shown below:

**Parallel FIR Filter Synthesis Results**
<img src="doc/fir_parallel_report.png">

**Parallel FIR Filter Report**

<img src="doc/reporte - parallel.png">

**TDF Unfolded FIR Filter Report**

<img src="doc/reporte_unfolded.png">