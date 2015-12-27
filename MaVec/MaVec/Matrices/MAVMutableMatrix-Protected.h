//
//  MAVMutableMatrix-Protected.h
//  MaVec
//
//  Created by Andrew McKnight on 9/14/14.
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

typedef enum {
    /**
     *  Enum constant representing mutation by swapping two rows.
     */
    MAVMatrixMutatingOperationRowSwap,
    
    /**
     *  Enum constant representing mutation by swapping two columns.
     */
    MAVMatrixMutatingOperationColumnSwap,
    
    /**
     *  Enum constant representing mutation by assigning an individual value.
     */
    MAVMatrixMutatingOperationAssignmentValue,
    
    /**
     *  Enum constant representing mutation by assigning a row.
     */
    MAVMatrixMutatingOperationAssignmentRow,
    
    /**
     *  Enum constant representing mutation by assigning a column.
     */
    MAVMatrixMutatingOperationAssignmentColumn,
    
    /**
     *  Enum constant representing mutation by multiplying by a vector.
     */
    MAVMatrixMutatingOperationMultiplyVector,
    
    /**
     *  Enum constant representing mutation by multiplying by a scalar.
     */
    MAVMatrixMutatingOperationMutliplyScalar,
    
    /**
     *  Enum constant representing mutation by multiplying by a matrix.
     */
    MAVMatrixMutatingOperationMultiplyMatrix,
    
    /**
     *  Enum constant representing mutation by raising to an exponent.
     */
    MAVMatrixMutatingOperationRaiseToPower,
    
    /**
     *  Enum constant representing mutation by adding a matrix.
     */
    MAVMatrixMutatingOperationAddMatrix,
    
    /**
     *  Enum constant representing mutation by subtracting a matrix.
     */
    MAVMatrixMutatingOperationSubtractMatrix
}

/**
 *  Enum representing the supported matrix mutating operations.
 */
MAVMatrixMutatingOperation;
