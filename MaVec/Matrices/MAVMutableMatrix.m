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
#import "MAVVector.h"

#import "MCKTribool.h"

#import "NSNumber+MCKPrecision.h"
#import "NSData+MCKPrecision.h"

@interface MAVMutableMatrix ()

@property (strong, nonatomic, readwrite) NSMutableData *values;

@end

@implementation MAVMutableMatrix

#pragma mark - Public

// TODO: invalidate all calculated properties when mutating matrix values

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
}

- (void)setEntryAtRow:(__CLPK_integer)row column:(__CLPK_integer)column toValue:(NSNumber *)value
{
    // TODO: take into account internal representation b/t conventional, packed and band, row- vs. col- major, triangular component, bandwidth, start/finish band offset
    
    NSAssert1(row >= 0 && row < self.rows, @"row = %lld is outside the range of possible rows.", (long long int)row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %lld is outside the range of possible columns.", (long long int)column);
    BOOL precisionsMatch = (self.precision == MCKPrecisionDouble && value.isDoublePrecision ) || (self.precision == MCKPrecisionSingle && value.isSinglePrecision);
    NSAssert(precisionsMatch, @"Precisions do not match.");
    
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
    
    for (__CLPK_integer i = 0; i < self.columns; i++) {
        [self setEntryAtRow:row column:i toValue:vector[i]];
    }
}

- (void)setColumnVector:(MAVVector *)vector atColumn:(__CLPK_integer)column
{
    NSAssert2(vector.length == self.rows, @"Vector length (%lld) must equal amount of rows in this matrix (%lld)", (long long int)vector.length, (long long int)self.rows);
    NSAssert2(column < self.columns, @"column (%lld) must be < the amount of columns in this matrix (%lld)", (long long int)column, (long long int)self.columns);
    
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
    
    return self;
}

- (MAVMutableMatrix *)addMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    for (__CLPK_integer i = 0; i < self.rows; i++) {
        for (__CLPK_integer j = 0; j < self.columns; j++) {
            if (self.precision == MCKPrecisionDouble) {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].doubleValue + [matrix valueAtRow:i column:j].doubleValue)];
            } else {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].floatValue + [matrix valueAtRow:i column:j].floatValue)];
            }
        }
    }
    
    return self;
}

- (MAVMutableMatrix *)subtractMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    for (__CLPK_integer i = 0; i < self.rows; i++) {
        for (__CLPK_integer j = 0; j < self.columns; j++) {
            if (self.precision == MCKPrecisionDouble) {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].doubleValue - [matrix valueAtRow:i column:j].doubleValue)];
            } else {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].floatValue - [matrix valueAtRow:i column:j].floatValue)];
            }
        }
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
    
    
    return self;
}

- (MAVMutableMatrix *)multiplyByScalar:(NSNumber *)scalar
{
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

@end
