# IIR filter
**Exercise:**

Design architecture, and implement it in RTL Verilog to realize the following difference equation:

$$y[n]=x[n]-x[n-1]+x[n-2]+x[n-3]+0.5y[n-1]+0.25y[n-2]$$

Implement multiplication with 0.5 and 0.25 by shift operations.

---------------------
## RTL
Bellow is shown the RTL for the difference equation presented above.
<img src=doc/rtl.png>