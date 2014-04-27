//
//  main.cpp
//  TestGenerator
//
//  Created by andrew mcknight on 4/27/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#include <iostream>
#include <gsl/gsl_matrix.h>

int main(int argc, const char * argv[])
{
    //
    
    gsl_matrix *m = gsl_matrix_calloc(2,2);
    
    gsl_matrix_set(m, 0, 0, 1234.0);
    gsl_matrix_set(m, 1, 1, 1234.0);
    
    std::cout << gsl_matrix_get(m, 0, 0) << gsl_matrix_get(m, 0, 1) << std::endl << gsl_matrix_get(m, 1, 0) << gsl_matrix_get(m, 1, 1) << std::endl;
    
    gsl_matrix_free(m);
    
    return 0;
}

