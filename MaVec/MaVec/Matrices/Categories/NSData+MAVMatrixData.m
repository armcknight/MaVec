//
//  NSData+MAVMatrixData.m
//  MaVec
//
//  Created by Andrew McKnight on 12/26/15.
//
//  Copyright (c) 2014 Andrew Robert McKnight
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

#import <MCKNumerics/MCKNumerics.h>

#import "NSData+MAVMatrixData.h"
#import "MAVVector.h"

@implementation NSData (MAVMatrixData)

+ (NSData *)dataFromVectors:(NSArray *)vectors
{
    MAVVector *firstVector = vectors.firstObject;
    BOOL isRowVector = firstVector.vectorFormat == MAVVectorFormatRowVector;
    MAVIndex rows = isRowVector ? (MAVIndex)vectors.count : firstVector.length;
    MAVIndex columns = isRowVector ? firstVector.length : (MAVIndex)vectors.count;

    NSData * data;

    MAVIndex innerLoopLimit = isRowVector ? columns : rows;
    if (((MAVVector *)vectors[0])[0].isDoublePrecision) {
        size_t size = rows * columns * sizeof(double);
        double *values = malloc(size);
        [vectors enumerateObjectsUsingBlock:^(MAVVector *vector, NSUInteger index, BOOL *stop) {
            for(MAVIndex i = 0; i < innerLoopLimit; i++) {
                NSNumber *value = [vector valueAtIndex:i];
                values[index * innerLoopLimit + i] = value.doubleValue;
            }
        }];
        data = [NSData dataWithBytesNoCopy:values length:size];
    } else {
        size_t size = rows * columns * sizeof(float);
        float *values = malloc(size);
        [vectors enumerateObjectsUsingBlock:^(MAVVector *vector, NSUInteger index, BOOL *stop) {
            for(MAVIndex i = 0; i < innerLoopLimit; i++) {
                NSNumber *value = [vector valueAtIndex:i];
                values[index * innerLoopLimit + i] = value.floatValue;
            }
        }];
        data = [NSData dataWithBytesNoCopy:values length:size];
    }

    return data;
}

+ (NSData *)dataForArrayFilledWithValue:(NSNumber *)value length:(size_t)length
{
    NSData *data;

    if ([value isDoublePrecision]) {
        size_t size = length * sizeof(double);
        double *values = malloc(size);
        double doubleValue = value.doubleValue;
        for (MAVIndex i = 0; i < length; i++) {
            values[i] = doubleValue;
        }
        data = [NSData dataWithBytesNoCopy:values length:size];
    } else {
        size_t size = length * sizeof(float);
        float *values = malloc(size);
        float floatValue = value.floatValue;
        for (MAVIndex i = 0; i < length; i++) {
            values[i] = floatValue;
        }
        data = [NSData dataWithBytesNoCopy:values length:size];
    }

    return data;
}

@end
