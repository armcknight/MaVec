//
//  EigenvalueDecomposition.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMatrix;
@class MCVector;

@interface MCEigendecomposition : NSObject

/**
 @property eigenvectors
 @brief An MCMatrix object whose columns are the eigenvectors of the eigendecomposition. The order of eigenvectors matches the order of the eigenvalues.
 */
@property (strong, nonatomic) MCMatrix *eigenvectors;

/**
 @property eigenvalues
 @brief An MCVector object containing the eigenvalues of the eigendecomposition. The order of values matches the order of the eigenvectors.
 */
@property (strong, nonatomic) MCVector *eigenvalues;

/**
 @brief Creates a new instance of MCEigendecomposition by calculating the eigendecomposition of the supplied matrix.
 @param matrix The MCMatrix object to decompose.
 @return A new instance of MCEigendecomposition containing the resulting eigenvalues and eigenvectors of the decomposition.
 */
- (instancetype)initWithMatrix:(MCMatrix *)matrix;

/**
 @brief Class convenience method to create a new instance of MCEigendecomposition by calculating the eigendecomposition of the supplied matrix.
 @param matrix The MCMatrix object to decompose.
 @return A new instance of MCEigendecomposition containing the resulting eigenvalues and eigenvectors of the decomposition.
 */
+ (instancetype)eigendecompositionOfMatrix:(MCMatrix *)matrix;

@end
