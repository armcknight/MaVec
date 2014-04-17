//
//  MCNumberFormats.h
//  MCNumerics
//
//  Created by andrew mcknight on 4/13/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#ifndef MCNumerics_MCNumberFormats_h
#define MCNumerics_MCNumberFormats_h

typedef enum : UInt8 {
    MCValuePrecisionSingle,
    MCValuePrecisionDouble,
} MCValuePrecision;

typedef enum : UInt8 {
    MCValueTypeReal,
    MCValueTypeComplex,
} MCValueType;

#endif
