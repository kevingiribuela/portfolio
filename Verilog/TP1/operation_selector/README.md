# Operation selector

**Exercise**:

Design an ALU datapath that performs the following operations in parallel on two 16-bit signed inputs $i\textunderscore dataA$ and $i\textunderscore dataB$ and assigns the value of one of the outputs to 16-bit $o\textunderscore dataC$. The selection of operation is based on a 2-bits selection line. Code the design. Write test to verify the implementation.

*Operations*:

$$o\textunderscore dataC = i\textunderscore dataA - i\textunderscore dataB$$

$$o\textunderscore dataC = i\textunderscore dataA + i\textunderscore dataB$$

$$o\textunderscore dataC = i\textunderscore dataA\ |\ i\textunderscore dataB$$

$$o\textunderscore dataC = i\textunderscore dataA\ \\& \ i\textunderscore dataB$$


----------------------------------
*Datapath:*

<img src=doc/rtl.png> 
