# Arithmethic Distribuited

Consider the following nine coefficients of an FIR filter:
$$h[n] = [-0.0456 -0.1703 \ \ 0.0696\ \ 0.3094 \ \ 0.4521 \ \ 0.3094 \ \ 0.0696 \ \ -0.1703 \ \ -0.0456]$$
Convert the coefficients into Q1.15 format. Consider x[n] to be an 8-bit number. Design the
following DA-based architecture:
1. a unified ROM-based design;
2. reduced size of ROM by the use of symmetry of the coefficients;

# Solution
## Unfolded FIR
The DA logic replaces the MAC operation of convolution summation of
$$y_n = \sum_{k=0}^{L-1}h_kx_{n-k}$$
into a bit-serial look.up table read an addition operation.

The DA logic works by first expanding the array of variable numers in the dot products as a binary number and then rearranging MAC terms with respect to weights of the bits.

To implement this filter successfully we must develop the equations that describe the behavior of the FIR filter as follow, assume that the lenght of both arrays is K

$$y_n = \sum_{k=0}^{K-1}A_kx_{k}$$

Without lost of generality, let us assume $x_k$ is an N-bit Q1.(N-1)-format number:
$$ x_k = -x_{k0}2^0+\sum_{b=1}^{N-1}x_{kb}2^{-b}=-x_{k0}2^0+x_{k1}2^{-1}+\dots+x_{k(N-1)}2^{N-1}$$

The dot product on the first equation can be written as:

$$ y = \sum_{k=0}^{K-1}\left(-x_{k0}2^0+x_{k1}2^{-1}+\dots+x_{k(N-1)}2^{N-1} \right)A_k$$

Rearranging the terms yields:

$$ y = -\sum_{k=0}^{K-1}x_{k0}A_k2^0+\sum_{b=1}^{N-1}2^{-b}\sum_{k=0}^{K-1}x_{kb}A_k$$

For our case K=9 and N=8, so

$$
 \begin{align*}
    &-(x_{00}A_0+x_{10}A_1+\dots+x_{80}A_8)2^0 \\
    &+(x_{01}A_0+x_{11}A_1+\dots+x_{81}A_8)2^{-1} \\
    &+\hspace{2.5cm}\vdots \\
    &+(x_{07}A_0+x_{17}A_1+\dots+x_{87}A_8)2^{-7} \\
 \end{align*}
$$

Then the ROM will be of 2^K=2^9 depth. The width is calculated as

$$ P = \left \lfloor log_2\left(\sum_{k=0}^8|A_k| \right)\right \rfloor + 1 = 17\ bits$$

Once the equations have been developed, it's mandatory translate it to a RTL diagram, as shown below.

<img src="doc/DA unfolded.png">

From the image above it is possible to observe the need of a ROM memory which is designed with the "Data Generation" file in Jupyter notebook. The same occurs for the folded architechture, except that the ROM is smaller than the first one.

To test the design, the file "test.ipynb" is used to generate the testbench stimulus and the filter impulse response.

## Folded FIR
Since the linearity in the phase filter, some operations can be reduced, such as MAC operations. As shown in the following mathematical explanation, where K=9 and J=4

$$
\begin{align*}
    y&=A_Jx_J +  \sum_{j=0}^{J-1}A_j\left(x_j+x_{k-1-j}\right) \\ 
    y&=A_0(x_0+x_8)+A_1(x_1+x_7)+A_2(x_2+x_6)+A_3(x_3+x_5)+A_4x_4
\end{align*}
$$
Using the same ideas as before
$$ \tilde{x}_k = -\tilde{x}_{k0}2^0+\sum_{b=1}^{N-1}\tilde{x}_{kb}2^{-b}$$
so

$$
\begin{align*}
y&=\sum_{j=0}^{4}A_j\left(-2^0\tilde{x}_{j0}+\sum_{b=1}^{N-1}2^{-b}\tilde{x}_{jb} \right)\\
&=\sum_{j=0}^{4}-A_j\tilde{x}_{j0}+\sum_{b=1}^82^{-b}\sum_{j=0}^{4}A_j\tilde{x}_{jb}
\end{align*}
$$

Rearranging we obtain

$$
 \begin{align*}
    &-(\tilde{x}_{00}A_0+\tilde{x}_{10}A_1+\tilde{x}_{20}A_1+\tilde{x}_{30}A_1+\tilde{x}_{40}A_4)2^0 \\
    &+(\tilde{x}_{01}A_0+\tilde{x}_{11}A_1+\tilde{x}_{21}A_1+\tilde{x}_{31}A_1+\tilde{x}_{41}A_4)2^{-1} \\
    &+(\tilde{x}_{02}A_0+\tilde{x}_{12}A_1+\tilde{x}_{22}A_1+\tilde{x}_{32}A_1+\tilde{x}_{42}A_4)2^{-2} \\
    &+(\tilde{x}_{03}A_0+\tilde{x}_{13}A_1+\tilde{x}_{23}A_1+\tilde{x}_{33}A_1+\tilde{x}_{43}A_4)2^{-3} \\
    &+(\tilde{x}_{04}A_0+\tilde{x}_{14}A_1+\tilde{x}_{24}A_1+\tilde{x}_{34}A_1+\tilde{x}_{44}A_4)2^{-4} \\
 \end{align*}
$$

wich yield in a ROM smaller than before.

The RTL is shown below
<img src="doc/DA folded.png">