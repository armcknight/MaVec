//
//  MAVEigenvalueDecomposition.h
//  MaVec
//
//  Created by andrew mcknight on 1/4/14.
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

#import <Foundation/Foundation.h>

@class MAVMatrix;
@class MAVVector;

@interface MAVEigendecomposition : NSObject <NSCopying>

/**
 @property eigenvectors
 @brief An MAVMatrix object whose columns are the eigenvectors of the eigendecomposition. The order of eigenvectors matches the order of the eigenvalues.
 */
@property (strong, nonatomic) MAVMatrix *eigenvectors;

/**
 @property eigenvalues
 @brief An MAVVector object containing the eigenvalues of the eigendecomposition. The order of values matches the order of the eigenvectors.
 */
@property (strong, nonatomic) MAVVector *eigenvalues;

/**
 @brief Creates a new instance of MAVEigendecomposition by calculating the eigendecomposition of the supplied matrix.
 @param matrix The MAVMatrix object to decompose.
 @return A new instance of MAVEigendecomposition containing the resulting eigenvalues and eigenvectors of the decomposition.
 */
- (instancetype)initWithMatrix:(MAVMatrix *)matrix;

/**
 @brief Class convenience method to create a new instance of MAVEigendecomposition by calculating the eigendecomposition of the supplied matrix.
 @param matrix The MAVMatrix object to decompose.
 @return A new instance of MAVEigendecomposition containing the resulting eigenvalues and eigenvectors of the decomposition.
 */
+ (instancetype)eigendecompositionOfMatrix:(MAVMatrix *)matrix;

@end
