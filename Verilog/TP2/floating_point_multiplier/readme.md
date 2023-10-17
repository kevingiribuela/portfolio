# Custom floating point multiplier
In this exercise a custom floating point multiplier is implemented.

The total number of bits is 13.

* NB_MANT = 8, there are 8bits for the mantissa.
* NB_EXP = 4, there are 4bits for the exponent.
* NB_SIGN = 1, there is 1bit for the sign.
* BIAS = 7, and the bias's exponent is 7.

The idea behind this multiplier relies on use a 8bit unsigned multiplier for the product of mantissas, one adder for the exponents and a subraction for the bias.

-------------------------------------
## Block diagram
Bellow is shown the block diagram of the floating point multiplier implemented.
<img src=doc/rtl.png>

