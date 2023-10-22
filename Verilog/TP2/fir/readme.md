# FIR filter
In this exercise we implement differents FIR filters.

The filters to be implemented are:
* FIR filter using truncation and saturation
* FIR filter using folded architechture, truncation and saturation.
* FIR filter using round and saturation.
* FIR filter using folder architechture, round and saturation.

-------------------------------------
## Block diagrams
### Truncation & saturation 
Bellow is shown the block diagram of the first FIR filter.

<img src=doc/fir_trunc.png>

### Round & saturation
The nex FIR filter was implemented by using round instead of truncation.

<img src=doc/fir_round.png>

### Folded FIR filter - Truncation & saturation
The following FIR filter was designed based on that the filter coefficients are simmetrics.

<img src=doc/fir_folded_trunc.png>

### Folded FIR filter - Round & saturation
The last FIR filter, instead of use truncation, round is used.

<img src=doc/fir_folded_round.png>


# Testing
For test the design, a signal was composed using a python script. Futhermore, the Jupyter notebook called "coeff.ipynb" was used to generate the apropiated coefficients for a low pass filter with cut-off frequency of 10kHz

The signal generated was loaded trough an external memory.

$s(t) = sin(2\pi 10000t) + 0.5sin(2\pi 35000t)$

The FIR filter output is shown bellow

<img src=doc/original_vs_filtered.png>