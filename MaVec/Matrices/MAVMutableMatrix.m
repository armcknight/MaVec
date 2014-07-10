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

#import "NSNumber+MCKPrecision.h"

@property (strong, nonatomic, readwrite) NSMutableData *values;


@implementation MAVMutableMatrix

// TODO: invalidate all calculated properties when mutating matrix values

- (void)swapRowA:(int)rowA withRowB:(int)rowB
{
    NSAssert1(rowA < self.rows, @"rowA = %u is outside the range of possible rows.", rowA);
    NSAssert1(rowB < self.rows, @"rowB = %u is outside the range of possible rows.", rowB);
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.columns; i++) {
        NSNumber *temp = [self valueAtRow:rowA column:i];
        [self setEntryAtRow:rowA column:i toValue:[self valueAtRow:rowB column:i]];
        [self setEntryAtRow:rowB column:i toValue:temp];
    }
}

- (void)swapColumnA:(int)columnA withColumnB:(int)columnB
{
    NSAssert1(columnA < self.columns, @"columnA = %u is outside the range of possible columns.", columnA);
    NSAssert1(columnB < self.columns, @"columnB = %u is outside the range of possible columns.", columnB);
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.rows; i++) {
        NSNumber *temp = [self valueAtRow:i column:columnA];
        [self setEntryAtRow:i column:columnA toValue:[self valueAtRow:i column:columnB]];
        [self setEntryAtRow:i column:columnB toValue:temp];
    }
}

- (void)setEntryAtRow:(int)row column:(int)column toValue:(NSNumber *)value
{
    // TODO: take into account internal representation b/t conventional, packed and band, row- vs. col- major, triangular component, bandwidth, start/finish band offset
    
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    BOOL precisionsMatch = (self.precision == MCKValuePrecisionDouble && value.isDoublePrecision ) || (self.precision == MCKValuePrecisionSingle && value.isSinglePrecision);
    NSAssert(precisionsMatch, @"Precisions do not match.");
    
    if (self.precision == MCKValuePrecisionDouble) {
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

- (void)setRowVector:(MAVVector *)vector atRow:(NSUInteger)row
{
    NSAssert2(vector.length == self.columns, @"Vector length (%u) must equal amount of columns in this matrix (%u)", vector.length, self.columns);
    NSAssert2(row < self.rows, @"row (%lu) must be < the amount of rows in this matrix (%u)", (unsigned long)row, self.rows);
    
    for (int i = 0; i < self.columns; i++) {
        [self setEntryAtRow:row column:i toValue:vector[i]];
    }
}

- (void)setColumnVector:(MAVVector *)vector atColumn:(NSUInteger)column
{
    NSAssert2(vector.length == self.rows, @"Vector length (%u) must equal amount of rows in this matrix (%u)", vector.length, self.rows);
    NSAssert2(column < self.columns, @"column (%lu) must be < the amount of columns in this matrix (%u)", (unsigned long)column, self.columns);
    
    for (int i = 0; i < self.rows; i++) {
        [self setEntryAtRow:i column:column toValue:vector[i]];
    }
}

- (void)setObject:(MAVVector *)obj atIndexedSubscript:(NSUInteger)idx
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
    
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = self.rows * matrix.columns * sizeof(double);
        double *cVals = malloc(size);
        vDSP_mmulD(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, self.rows, matrix.columns, self.columns);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:cVals length:size];
    } else {
        size_t size = self.rows * matrix.columns * sizeof(float);
        float *cVals = malloc(size);
        vDSP_mmul(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, self.rows, matrix.columns, self.columns);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:cVals length:size];
    }
    
    return self;
}

- (MAVMutableMatrix *)addMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.columns; j++) {
            if (self.precision == MCKValuePrecisionDouble) {
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
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.columns; j++) {
            if (self.precision == MCKValuePrecisionDouble) {
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
    int rows = self.rows;
    int cols = self.columns;
    
    if (self.precision == MCKValuePrecisionDouble) {
        double *result = calloc(vector.length, sizeof(double));
        cblas_dgemv(order, transpose, rows, cols, 1.0, self.values.bytes, rows, vector.values.bytes, 1, 1.0, result, 1);
        [self.values replaceBytesInRange:NSMakeRange(0, vector.values.length) withBytes:result length:vector.values.length];
    } else {
        float *result = calloc(vector.length, sizeof(float));
        cblas_sgemv(order, transpose, rows, cols, 1.0f, self.values.bytes, rows, vector.values.bytes, 1, 1.0f, result, 1);
        [self.values replaceBytesInRange:NSMakeRange(0, vector.values.length) withBytes:result length:vector.values.length];
    }
    
    return self;
}

- (MAVMutableMatrix *)multiplyByScalar:(NSNumber *)scalar
{
    int valueCount = self.rows * self.columns;
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = valueCount * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < valueCount; i++) {
            values[i] = ((double *)self.values.bytes)[i] * scalar.doubleValue;
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:values];
    }
    else {
        size_t size = valueCount * sizeof(float);
        float *values = malloc(size);
        for (int i = 0; i < valueCount; i++) {
            values[i] = ((float *)self.values.bytes)[i] * scalar.floatValue;
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:values];
    }
    
    return self;
}

- (MAVMutableMatrix *)raiseToPower:(NSUInteger)power
{
    NSAssert(self.rows == self.columns, @"Cannot raise a non-square matrix to exponents.");
    
    for (int i = 0; i < power - 1; i += 1) {
        [self multiplyByMatrix:self];
    }
    
    return self;
}

@end
