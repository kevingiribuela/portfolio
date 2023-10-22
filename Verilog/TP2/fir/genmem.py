import numpy as np
import matplotlib.pyplot as plt
from tool._fixedInt import *



N = 1024
#                 S(16,15)
temp  = DeFixedInt(16,15, signedMode='S', roundMode='trunc', saturateMode='saturate')

filename = 'mem.hex'

F_noise     = 35000 ### <----------------
F_signal    = 10000 ### <-----------------
sample_rate = 80000 ### <---------------

def fun_gen(t):
    noise           = 0.5 * np.sin(2*np.pi*F_noise*t)
    data            = 1   * np.sin(2*np.pi*F_signal*t)
    noisy_signal    = data + noise
    return noisy_signal 

mem = []

with open(filename, 'w') as f:
    for index in range(N):
        value = fun_gen(index/sample_rate)
        temp.value = value
        mem.append(value)
        f.write("{}\n".format(temp.__hex__()).replace('0x',''))

plt.plot(mem,'bo-')
plt.show()
