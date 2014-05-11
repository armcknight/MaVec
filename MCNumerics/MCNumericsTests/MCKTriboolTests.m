//
//  MCKTriboolTests.m
//  MCKNumerics
//
//  Created by andrew mcknight on 3/15/14.
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

#import <XCTest/XCTest.h>

#import "MCKTribool.h"

@interface MCKTriboolTests : XCTestCase

@end

@implementation MCKTriboolTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTriboolConjunction
{
    MCKTriboolValue yes = MCKTriboolValueYes;
    MCKTriboolValue no = MCKTriboolValueNo;
    MCKTriboolValue unknown = MCKTriboolValueUnknown;
    
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool conjunctionOfTriboolValueA:yes triboolValueB:yes], @"+ ∧ + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool conjunctionOfTriboolValueA:yes triboolValueB:unknown], @"+ ∧ 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool conjunctionOfTriboolValueA:yes triboolValueB:no], @"+ ∧ - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool conjunctionOfTriboolValueA:unknown triboolValueB:yes], @"0 ∧ + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool conjunctionOfTriboolValueA:unknown triboolValueB:unknown], @"0 ∧ 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool conjunctionOfTriboolValueA:unknown triboolValueB:no], @"0 ∧ - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool conjunctionOfTriboolValueA:no triboolValueB:yes], @"- ∧ + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool conjunctionOfTriboolValueA:no triboolValueB:unknown], @"- ∧ 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool conjunctionOfTriboolValueA:no triboolValueB:no], @"- ∧ - computed incorrectly.");
}

- (void)testTriboolDisjunction
{
    MCKTriboolValue yes = MCKTriboolValueYes;
    MCKTriboolValue no = MCKTriboolValueNo;
    MCKTriboolValue unknown = MCKTriboolValueUnknown;
    
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool disjunctionOfTriboolValueA:yes triboolValueB:yes], @"+ v + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool disjunctionOfTriboolValueA:yes triboolValueB:unknown], @"+ v 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool disjunctionOfTriboolValueA:yes triboolValueB:no], @"+ v - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool disjunctionOfTriboolValueA:unknown triboolValueB:yes], @"0 v + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool disjunctionOfTriboolValueA:unknown triboolValueB:unknown], @"0 v 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool disjunctionOfTriboolValueA:unknown triboolValueB:no], @"0 v - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool disjunctionOfTriboolValueA:no triboolValueB:yes], @"- v + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool disjunctionOfTriboolValueA:no triboolValueB:unknown], @"- v 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool disjunctionOfTriboolValueA:no triboolValueB:no], @"- v - computed incorrectly.");
}

- (void)testTriboolKleeneImplication
{
    MCKTriboolValue yes = MCKTriboolValueYes;
    MCKTriboolValue no = MCKTriboolValueNo;
    MCKTriboolValue unknown = MCKTriboolValueUnknown;
    
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool kleeneImplicationOfTriboolValueA:yes triboolValueB:yes], @"+ → + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool kleeneImplicationOfTriboolValueA:yes triboolValueB:unknown], @"+ → 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool kleeneImplicationOfTriboolValueA:yes triboolValueB:no], @"+ → - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool kleeneImplicationOfTriboolValueA:unknown triboolValueB:yes], @"0 → + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool kleeneImplicationOfTriboolValueA:unknown triboolValueB:unknown], @"0 → 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool kleeneImplicationOfTriboolValueA:unknown triboolValueB:no], @"0 → - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool kleeneImplicationOfTriboolValueA:no triboolValueB:yes], @"- → + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool kleeneImplicationOfTriboolValueA:no triboolValueB:unknown], @"- → 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool kleeneImplicationOfTriboolValueA:no triboolValueB:no], @"- → - computed incorrectly.");
}

- (void)testTriboolLukasiewiczImplication
{
    MCKTriboolValue yes = MCKTriboolValueYes;
    MCKTriboolValue no = MCKTriboolValueNo;
    MCKTriboolValue unknown = MCKTriboolValueUnknown;
    
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool lukasiewiczImplicationOfTriboolValueA:yes triboolValueB:yes], @"+ → + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool lukasiewiczImplicationOfTriboolValueA:yes triboolValueB:unknown], @"+ → 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool lukasiewiczImplicationOfTriboolValueA:yes triboolValueB:no], @"+ → - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool lukasiewiczImplicationOfTriboolValueA:unknown triboolValueB:yes], @"0 → + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool lukasiewiczImplicationOfTriboolValueA:unknown triboolValueB:unknown], @"0 → 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool lukasiewiczImplicationOfTriboolValueA:unknown triboolValueB:no], @"0 → - computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool lukasiewiczImplicationOfTriboolValueA:no triboolValueB:yes], @"- → + computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool lukasiewiczImplicationOfTriboolValueA:no triboolValueB:unknown], @"- → 0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool lukasiewiczImplicationOfTriboolValueA:no triboolValueB:no], @"- → - computed incorrectly.");
}

- (void)testTriboolNegation
{
    MCKTriboolValue yes = MCKTriboolValueYes;
    MCKTriboolValue no = MCKTriboolValueNo;
    MCKTriboolValue unknown = MCKTriboolValueUnknown;
    
    XCTAssertEqual(MCKTriboolValueNo, [MCKTribool negationOfTriboolValue:yes], @"¬+ computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueUnknown, [MCKTribool negationOfTriboolValue:unknown], @"¬0 computed incorrectly.");
    XCTAssertEqual(MCKTriboolValueYes, [MCKTribool negationOfTriboolValue:no], @"¬- computed incorrectly.");
}

@end
