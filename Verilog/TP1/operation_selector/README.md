# Operation selector

**Exercise**:

Design an ALU datapath that performs the following operations in parallel on two 16-bit signed inputs $i\_dataA$ and $i\_dataB$ and assigns the value of one of the outputs to 16-bit $o\_dataC$. The selection of operation is based on a 2-bits selection line. Code the design. Write test to verify the implementation.

*Operations*:

$$o\_dataC = i\_dataA - i\_dataB$$
$$o\_dataC = i\_dataA + i\_dataB$$
$$o\_dataC = i\_dataA\ |\ i\_dataB$$
$$o\_dataC = i\_dataA \ \&\ i\_dataB$$


----------------------------------
*Datapath:*

<img src=doc/rtl.png> 
