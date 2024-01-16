# Arithmethic Distribuited

Consider the following nine coefficients of an FIR filter:
$$h[n] = [-0.0456 -0.1703 \ \ 0.0696\ \ 0.3094 \ \ 0.4521 \ \ 0.3094 \ \ 0.0696 \ \ -0.1703 \ \ -0.0456]$$
Convert the coefficients into Q1.15 format. Consider x[n] to be an 8-bit number. Design the
following DA-based architecture:
1. a unified ROM-based design;
2. reduced size of ROM by the use of symmetry of the coefficients;

# Solution
To implement this filter successfully we must develop the equations that describe the behavior of the FIR filter, which is a reader task. 

Once the equations have been developed, it's mandatory translate it to a RTL diagram, as shown below.

<img src="doc/RTL.png">

From the image above it is possible to observe the need of a ROM memory which is designed with the "Generacion de datos" file in Jupyter notebook. The same occurs for the folded architechture, except that the ROM is smaller than the first one.

To test the design, the file "test.ipynb" is used to generate the testbench stimulus and the filter impulse response.
