//
//  MAVMutableMatrix.m
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "MAVMatrix-Protected.h"
#import "MAVMutableMatrix.h"
#import "MAVMutableMatrix-Protected.h"
#import "MAVVector.h"

#import "MCKTribool.h"

#import "NSNumber+MCKPrecision.h"
#import "NSData+MCKPrecision.h"

@interface MAVMutableMatrix ()

@property (strong, nonatomic, readwrite) NSMutableData *values;

/**
 *  Reset the calculated state data of this matrix if a mutable operation invalidates it.
 *
 *  @param operation The mutating operation being performed on this matrix.
 *  @param input     The input to the mutating operation.
 *  @param row       The row being mutated, if specified in the mutating method.
 *  @param column    The column being mutated, if specified in the mutating method.
 */
// TODO: change 'atRow' to 'coordinateA', 'column' to 'coordinateB' to make more generic
- (void)invalidateStateIfOperation:(MAVMatrixMutatingOperation)operation
            notIdempotentWithInput:(id)input
                             atRow:(__CLPK_integer)row
                            column:(__CLPK_integer)column;

@end

@implementation MAVMutableMatrix

#pragma mark - Public

- (void)swapRowA:(__CLPK_integer)rowA withRowB:(__CLPK_integer)rowB
{
    NSAssert1(rowA < self.rows, @"rowA = %lld is outside the range of possible rows.", (long long int)rowA);
    NSAssert1(rowB < self.rows, @"rowB = %lld is outside the range of possible rows.", (long long int)rowB);
    
    // TODO: implement using cblas_dswap
    
    for (__CLPK_integer i = 0; i < self.columns; i++) {
        NSNumber *temp = [self valueAtRow:rowA column:i];
        [self setEntryAtRow:rowA column:i toValue:[self valueAtRow:rowB column:i]];
        [self setEntryAtRow:rowB column:i toValue:temp];
    }
    
    [self invalidateStateIfOperation:MAVMatrixMutatingOperationRowSwap
              notIdempotentWithInput:nil
                               atRow:rowA
                              column:rowB];
}

- (void)swapColumnA:(__CLPK_integer)columnA withColumnB:(__CLPK_integer)columnB
{
    NSAssert1(columnA < self.columns, @"columnA = %lld is outside the range of possible columns.", (long long int)columnA);
    NSAssert1(columnB < self.columns, @"columnB = %lld is outside the range of possible columns.", (long long int)columnB);
    
    // TODO: implement using cblas_dswap
    
    for (__CLPK_integer i = 0; i < self.rows; i++) {
        NSNumber *temp = [self valueAtRow:i column:columnA];
        [self setEntryAtRow:i column:columnA toValue:[self valueAtRow:i column:columnB]];
        [self setEntryAtRow:i column:columnB toValue:temp];
    }
    
    [self invalidateStateIfOperation:MAVMatrixMutatingOperationColumnSwap
              notIdempotentWithInput:nil
                               atRow:columnA
                              column:columnB];
}

- (void)setEntryAtRow:(__CLPK_integer)row column:(__CLPK_integer)column toValue:(NSNumber *)value
{
    // TODO: take into account internal representation b/t conventional, packed and band, row- vs. col- major, triangular component, bandwidth, start/finish band offset
    
    NSAssert1(row >= 0 && row < self.rows, @"row = %lld is outside the range of possible rows.", (long long int)row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %lld is outside the range of possible columns.", (long long int)column);
    BOOL precisionsMatch = (self.precision == MCKPrecisionDouble && value.isDoublePrecision ) || (self.precision == MCKPrecisionSingle && value.isSinglePrecision);
    NSAssert(precisionsMatch, @"Precisions do not match.");
    
    [self invalidateStateIfOperation:MAVMatrixMutatingOperationAssignmentValue
              notIdempotentWithInput:value
                               atRow:row
                              column:column];
    
    if (self.precision == MCKPrecisionDouble) {
        if (self.leadingDimension == MAVMatrixLeadingDimensionRow) {
            ((double *)self.values.bytes)[row * self.columns + column] = value.doubleValue;
        } else {
            ((double *)self.values.bytes)[column * self.rows + row] = value.doubleValue;
        }
    } else {
        if (self.leadingDimension == MAVMatrixLeadingDimensionRow) {
            ((float *)self.values.bytes)[row * self.columns + column] = value.floatValue;
        } else {
            ((float *)self.values.bytes)[column * self.rows + row] = value.floatValue;
        }
    }
}

- (void)setRowVector:(MAVVector *)vector atRow:(__CLPK_integer)row
{
    NSAssert2(vector.length == self.columns, @"Vector length (%lld) must equal amount of columns in this matrix (%lld)", (long long int)vector.length, (long long int)self.columns);
    NSAssert2(row < self.rows, @"row (%lld) must be < the amount of rows in this matrix (%lld)", (long long int)row, (long long int)self.rows);
    
    [self invalidateStateIfOperation:MAVMatrixMutatingOperationAssignmentRow
              notIdempotentWithInput:vector
                               atRow:row
                              column:kMAVNoCoordinate];
    
    for (__CLPK_integer i = 0; i < self.columns; i++) {
        [self setEntryAtRow:row column:i toValue:vector[i]];
    }
}

- (void)setColumnVector:(MAVVector *)vector atColumn:(__CLPK_integer)column
{
    NSAssert2(vector.length == self.rows, @"Vector length (%lld) must equal amount of rows in this matrix (%lld)", (long long int)vector.length, (long long int)self.rows);
    NSAssert2(column < self.columns, @"column (%lld) must be < the amount of columns in this matrix (%lld)", (long long int)column, (long long int)self.columns);
    
    [self invalidateStateIfOperation:MAVMatrixMutatingOperationAssignmentRow
              notIdempotentWithInput:vector
                               atRow:kMAVNoCoordinate
                              column:column];
    
    for (__CLPK_integer i = 0; i < self.rows; i++) {
        [self setEntryAtRow:i column:column toValue:vector[i]];
    }
}

- (void)setObject:(MAVVector *)obj atIndexedSubscript:(__CLPK_integer)idx
{
    [self setRowVector:obj atRow:idx];
}

#pragma mark - Mathematical operations

- (MAVMutableMatrix *)multiplyByMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.columns == matrix.rows, @"self does not have an equal amount of columns as rows in matrix");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    if (matrix.isIdentity.isNo) {
        NSData *aVals = [self valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
        NSData *bVals = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
        
        if (self.precision == MCKPrecisionDouble) {
            size_t size = self.rows * matrix.columns * sizeof(double);
            double *cVals = malloc(size);
            vDSP_mmulD(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, self.rows, matrix.columns, self.columns);
            [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:cVals length:size];
            free(cVals);
        } else {
            size_t size = self.rows * matrix.columns * sizeof(float);
            float *cVals = malloc(size);
            vDSP_mmul(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, self.rows, matrix.columns, self.columns);
            [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:cVals length:size];
            free(cVals);
        }
        
        self.columns = matrix.columns;
        self.leadingDimension = MAVMatrixLeadingDimensionRow;
        [self resetToDefaultState];
    }
    
    return self;
}

- (MAVMutableMatrix *)addMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    if (matrix.isZero.isNo) {
        for (__CLPK_integer i = 0; i < self.rows; i++) {
            for (__CLPK_integer j = 0; j < self.columns; j++) {
                if (self.precision == MCKPrecisionDouble) {
                    [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].doubleValue + [matrix valueAtRow:i column:j].doubleValue)];
                } else {
                    [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].floatValue + [matrix valueAtRow:i column:j].floatValue)];
                }
            }
        }
        [self resetToDefaultState];
    }
    
    return self;
}

- (MAVMutableMatrix *)subtractMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    if (matrix.isZero.isNo) {
        for (__CLPK_integer i = 0; i < self.rows; i++) {
            for (__CLPK_integer j = 0; j < self.columns; j++) {
                if (self.precision == MCKPrecisionDouble) {
                    [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].doubleValue - [matrix valueAtRow:i column:j].doubleValue)];
                } else {
                    [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].floatValue - [matrix valueAtRow:i column:j].floatValue)];
                }
            }
        }
        [self resetToDefaultState];
    }
    
    return self;
}

- (MAVMutableMatrix *)multiplyByVector:(MAVVector *)vector
{
    NSAssert(self.columns == vector.length, @"self must have same amount of columns as vector length.");
    NSAssert(self.precision == vector.precision, @"Precisions do not match.");
    
    short order = self.leadingDimension == MAVMatrixLeadingDimensionColumn ? CblasColMajor : CblasRowMajor;
    short transpose = CblasNoTrans;
    __CLPK_integer rows = self.rows;
    __CLPK_integer cols = self.columns;
    
    if (self.precision == MCKPrecisionDouble) {
        double *result = calloc(vector.length, sizeof(double));
        cblas_dgemv(order, transpose, rows, cols, 1.0, self.values.bytes, rows, vector.values.bytes, 1, 1.0, result, 1);
        [self.values replaceBytesInRange:NSMakeRange(0, vector.values.length) withBytes:result length:vector.values.length];
        free(result);
    } else {
        float *result = calloc(vector.length, sizeof(float));
        cblas_sgemv(order, transpose, rows, cols, 1.0f, self.values.bytes, rows, vector.values.bytes, 1, 1.0f, result, 1);
        [self.values replaceBytesInRange:NSMakeRange(0, vector.values.length) withBytes:result length:vector.values.length];
        free(result);
    }
    
    if (vector.vectorFormat == MAVVectorFormatColumnVector) {
        self.leadingDimension = MAVMatrixLeadingDimensionColumn;
        self.columns = 1;
    } else {
        self.leadingDimension = MAVMatrixLeadingDimensionRow;
        self.columns = vector.length;
    }
    
    [self invalidateStateIfOperation:MAVMatrixMutatingOperationMultiplyVector
              notIdempotentWithInput:vector
                               atRow:kMAVNoCoordinate
                              column:kMAVNoCoordinate];
    
    return self;
}

- (MAVMutableMatrix *)multiplyByScalar:(NSNumber *)scalar
{
    if (![scalar isEqualToNumber:@1]) {
        size_t valueCount = self.rows * self.columns;
        if (self.precision == MCKPrecisionDouble) {
            size_t size = valueCount * sizeof(double);
            double *values = malloc(size);
            for (size_t i = 0; i < valueCount; i++) {
                values[i] = ((double *)self.values.bytes)[i] * scalar.doubleValue;
            }
            [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:values];
            free(values);
        }
        else {
            size_t size = valueCount * sizeof(float);
            float *values = malloc(size);
            for (size_t i = 0; i < valueCount; i++) {
                values[i] = ((float *)self.values.bytes)[i] * scalar.floatValue;
            }
            [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:values];
            free(values);
        }
        // ???: should only a subset of derived properties be reset?
        [self resetToDefaultState];
    }
    
    return self;
}

- (MAVMutableMatrix *)raiseToPower:(NSUInteger)power
{
    NSAssert(self.rows == self.columns, @"Cannot raise a non-square matrix to exponents.");
    
    MAVMatrix *original = [self copy];
    for (NSUInteger i = 0; i < power - 1; i += 1) {
        [self multiplyByMatrix:original];
    }
    
    return self;
}

#pragma mark - Private

- (void)invalidateStateIfOperation:(MAVMatrixMutatingOperation)operation
            notIdempotentWithInput:(id)input
                             atRow:(__CLPK_integer)row
                            column:(__CLPK_integer)column
{
    BOOL isIdempotent = NO;
    
    /*
     the following have to be reset on an individual basis
     
     leadingDimension
     packingMethod
     triangularComponent
     isSymmetric
     definiteness
     
     */
    
    switch (operation) {
            
        case MAVMatrixMutatingOperationRowSwap: {
            isIdempotent = [[self rowVectorForRow:row] isEqualToVector:[self rowVectorForRow:column]];
            break;
        }

        case MAVMatrixMutatingOperationColumnSwap: {
            isIdempotent = [[self columnVectorForColumn:row] isEqualToVector:[self columnVectorForColumn:column]];
            break;
        }
            
        case MAVMatrixMutatingOperationAssignmentValue: {
            NSAssert([input isKindOfClass:[NSNumber class]], @"Input should be of type NSNumber.");
            isIdempotent = [[self valueAtRow:row column:column] isEqualToNumber:input];
            break;
        }
            
        case MAVMatrixMutatingOperationAssignmentRow: {
            NSAssert([input isKindOfClass:[MAVVector class]], @"Input should be of type MAVVector.");
            isIdempotent = [[self rowVectorForRow:row] isEqualToVector:input];
            break;
        }

        case MAVMatrixMutatingOperationAssignmentColumn: {
            NSAssert([input isKindOfClass:[MAVVector class]], @"Input should be of type MAVVector.");
            isIdempotent = [[self columnVectorForColumn:column] isEqualToVector:input];
            break;
        }

        case MAVMatrixMutatingOperationMultiplyVector: {
            MAVVector *inputVector = (MAVVector *)input;
            isIdempotent = ((inputVector.vectorFormat == MAVVectorFormatRowVector
                             && self.columns == 1
                             && self.rows == inputVector.length)
                            || (inputVector.vectorFormat == MAVVectorFormatColumnVector
                                && self.rows == 1
                                && self.columns == inputVector.length)) && inputVector.isIdentity;
            break;
        }

        case MAVMatrixMutatingOperationMutliplyScalar: {
            // handled in multiplyByScalar:
            break;
        }

        case MAVMatrixMutatingOperationMultiplyMatrix: {
            // handled in multiplyByMatrix:
            break;
        }

        case MAVMatrixMutatingOperationRaiseToPower: {
            // implicitly handled in multiplyByMatrix:
            break;
        }

        case MAVMatrixMutatingOperationAddMatrix: {
            // handled in addMatrix:
            break;
        }

        case MAVMatrixMutatingOperationSubtractMatrix: {
            // handled in subtractMatrix:
            break;
        }
            
    }
    
    if (!isIdempotent) {
        [self resetToDefaultState];
    }
}

@end
