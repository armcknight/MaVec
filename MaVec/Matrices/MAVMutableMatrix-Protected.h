//
//  MAVMutableMatrix-Protected.h
//  MaVec
//
//  Created by Andrew McKnight on 9/14/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
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
