MaVec
===

A framework for performing matrix and vector math using first-class objects. Developed after trudging through the Accelerate framework's lack of quality documentation and cryptic function names, MaVec provides a more intuitive and Objective-C friendly interface (and documentation!). But don't worry--behind many of its methods are the same Accelerate functions you've grown to know and love. Or not. Which is why MaVec is here for you.

With MaVec you can create a matrix object from any of several matrix representations (conventional or packed row- or column- major, or band), with single- or double-precision floating point values, and then forget about the underlying details. It will choose the most efficient Accelerate function to perform a desired operation based on the matrix' characteristics (tridiagonal, symmetric, positive-definite, etc) and floating-point precision, while maintaining the most space-efficient backing store of values that you provide.

Many useful utilities exist to transform the value representations, from, say, upper triangular column-major to conventional row-major, or symmetric to band. Operations such as LU and QR factorization, singular value decomposition, eigendecomposition, matrix and vector arithmetic, definiteness determination, linear system solving and many more are all one line of code away!
