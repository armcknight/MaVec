//
//  MAVMutableMatrix.m
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import "MAVMutableMatrix.h"
#import "MAVVector.h"

#import "NSNumber+MCKPrecision.h"

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


@end
