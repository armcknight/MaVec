//
//  MAVTypedefs.h
//  MaVec
//
//  Created by Andrew McKnight on 10/25/14.
//
//  Copyright © 2015 AMProductions
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

/*
 Type to index into elements of a vector or the rows and columns of a matrix.
 */
typedef __CLPK_integer MAVIndex;

#pragma mark - Vectors

typedef enum : UInt8 {
    /**
     Specifies that the values in the vector form a row with each value in its own column.
     */
    MAVVectorFormatRowVector,

    /**
     Specifies that the values in the vector form a column with each value in its own row.
     */
    MAVVectorFormatColumnVector
}
/**
 Constants specifying whether the vector is a row- or column- vector.
 */
MAVVectorFormat;

#pragma mark - Matrices

typedef enum : UInt8 {
    /**
     Specifies that this matrix' values are stored in row-major order.
     */
    MAVMatrixLeadingDimensionRow,

    /**
     Specifies that this matrix' values are stored in column-major order.
     */
    MAVMatrixLeadingDimensionColumn
}
/**
 Constants specifying the leading dimension used for storing this matrix' values.
 */
MAVMatrixLeadingDimension;

typedef enum : UInt8 {
    /**
     Specifies that values refer to lower triangular portion.
     */
    MAVMatrixTriangularComponentLower,

    /**
     Specifies that values refer to upper triangular portion.
     */
    MAVMatrixTriangularComponentUpper,

    /**
     Special case where both or neither triangular components are defined.
     */
    MAVMatrixTriangularComponentBoth
}
/**
 Constants specifying the triangular portion of a square matrix.
 */
MAVMatrixTriangularComponent;

typedef enum : UInt8 {
    /**
     All values are flattened using a MAVMatrixLeadingDimension.

     @code
     [ a b
       c d ]   =>    [a b c d] or [a c b d]
     */
    MAVMatrixValuePackingMethodConventional,

    /**
     Exclude triangular matrix' leftover 0 values.

     @code
     [ a b c
       0 d e
       0 0 f ]  =>  [a b c d e f] or [a b d c e f]
     */
    MAVMatrixValuePackingMethodPacked,

    /**
     Only store the non-zero band values. MAVMatrixLeadingDimension has no bearing on this packing format.

     @code
     [ a b 0 0
       c d e 0
       f g h i
       0 j k l
       0 0 m n ]  ->  [* b e i a d h l c g k n f j m *] (* must exist in array but isn't used by the algorithm)
     */
    MAVMatrixValuePackingMethodBand
}
/**
 Constants specifying the matrix flattening method used to construct the values array.
 */
MAVMatrixValuePackingMethod;

typedef enum : UInt8 {
    /**
     x^TMx > 0 for all nonzero real x
     */
    MAVMatrixDefinitenessPositiveDefinite,

    /**
     x^TMx ≥ 0 for all real x
     */
    MAVMatrixDefinitenessPositiveSemidefinite,

    /**
     x^TMx < 0 for all nonzero real x
     */
    MAVMatrixDefinitenessNegativeDefinite,

    /**
     x^TMx ≤ 0 for all real x
     */
    MAVMatrixDefinitenessNegativeSemidefinite,

    /**
     x^TMx can be greater than, equal to or lesser than 0 for all real x
     */
    MAVMatrixDefinitenessIndefinite,

    /**
     Definiteness not yet been computed for this matrix.
     */
    MAVMatrixDefinitenessUnknown
}
/**
 Definiteness of a matrix M.
 */
MAVMatrixDefiniteness;

typedef enum : UInt8 {
    /**
     Specifies that an angle rotates in a clockwise direction when viewed in a right handed coordinate system.
     */
    MAVAngleDirectionClockwise,

    /**
     Specifies that an angle rotates in a counterclockwise direction when viewed in a right handed coordinate system.
     */
    MAVAngleDirectionCounterClockwise
}
/**
 Direction of an angle, either clockwise or counterclockwise when viewed in a right handed coordinate system. The actual coordinate system has no bearing on the values of a rotated vector.
 */
MAVAngleDirection;

typedef enum : UInt8 {
    /**
     The X cartesian axis.
     */
    MAVCoordinateAxisX,

    /**
     The Y cartesian axis.
     */
    MAVCoordinateAxisY,

    /**
     The Z cartesian axis.
     */
    MAVCoordinateAxisZ
}
/**
 One of the three Cartesian coordinate axes, either X, Y or Z.
 */
MAVCoordinateAxis;
