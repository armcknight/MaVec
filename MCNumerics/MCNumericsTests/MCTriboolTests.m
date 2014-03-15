//
//  MCTriboolTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/15/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCTribool.h"

@interface MCTriboolTests : XCTestCase

@end

@implementation MCTriboolTests

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
    MCTriboolValue yes = MCTriboolValueYes;
    MCTriboolValue no = MCTriboolValueNo;
    MCTriboolValue unknown = MCTriboolValueUnknown;
    
    XCTAssertEqual(MCTriboolValueYes, [MCTribool conjunctionOfTriboolValueA:yes triboolValueB:yes], @"+ ∧ + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool conjunctionOfTriboolValueA:yes triboolValueB:unknown], @"+ ∧ 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool conjunctionOfTriboolValueA:yes triboolValueB:no], @"+ ∧ - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool conjunctionOfTriboolValueA:unknown triboolValueB:yes], @"0 ∧ + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool conjunctionOfTriboolValueA:unknown triboolValueB:unknown], @"0 ∧ 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool conjunctionOfTriboolValueA:unknown triboolValueB:no], @"0 ∧ - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool conjunctionOfTriboolValueA:no triboolValueB:yes], @"- ∧ + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool conjunctionOfTriboolValueA:no triboolValueB:unknown], @"- ∧ 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool conjunctionOfTriboolValueA:no triboolValueB:no], @"- ∧ - computed incorrectly.");
}

- (void)testTriboolDisjunction
{
    MCTriboolValue yes = MCTriboolValueYes;
    MCTriboolValue no = MCTriboolValueNo;
    MCTriboolValue unknown = MCTriboolValueUnknown;
    
    XCTAssertEqual(MCTriboolValueYes, [MCTribool disjunctionOfTriboolValueA:yes triboolValueB:yes], @"+ v + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool disjunctionOfTriboolValueA:yes triboolValueB:unknown], @"+ v 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool disjunctionOfTriboolValueA:yes triboolValueB:no], @"+ v - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool disjunctionOfTriboolValueA:unknown triboolValueB:yes], @"0 v + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool disjunctionOfTriboolValueA:unknown triboolValueB:unknown], @"0 v 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool disjunctionOfTriboolValueA:unknown triboolValueB:no], @"0 v - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool disjunctionOfTriboolValueA:no triboolValueB:yes], @"- v + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool disjunctionOfTriboolValueA:no triboolValueB:unknown], @"- v 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool disjunctionOfTriboolValueA:no triboolValueB:no], @"- v - computed incorrectly.");
}

- (void)testTriboolKleeneImplication
{
    MCTriboolValue yes = MCTriboolValueYes;
    MCTriboolValue no = MCTriboolValueNo;
    MCTriboolValue unknown = MCTriboolValueUnknown;
    
    XCTAssertEqual(MCTriboolValueYes, [MCTribool kleeneImplicationOfTriboolValueA:yes triboolValueB:yes], @"+ → + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool kleeneImplicationOfTriboolValueA:yes triboolValueB:unknown], @"+ → 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool kleeneImplicationOfTriboolValueA:yes triboolValueB:no], @"+ → - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool kleeneImplicationOfTriboolValueA:unknown triboolValueB:yes], @"0 → + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool kleeneImplicationOfTriboolValueA:unknown triboolValueB:unknown], @"0 → 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool kleeneImplicationOfTriboolValueA:unknown triboolValueB:no], @"0 → - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool kleeneImplicationOfTriboolValueA:no triboolValueB:yes], @"- → + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool kleeneImplicationOfTriboolValueA:no triboolValueB:unknown], @"- → 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool kleeneImplicationOfTriboolValueA:no triboolValueB:no], @"- → - computed incorrectly.");
}

- (void)testTriboolLukasiewiczImplication
{
    MCTriboolValue yes = MCTriboolValueYes;
    MCTriboolValue no = MCTriboolValueNo;
    MCTriboolValue unknown = MCTriboolValueUnknown;
    
    XCTAssertEqual(MCTriboolValueYes, [MCTribool lukasiewiczImplicationOfTriboolValueA:yes triboolValueB:yes], @"+ → + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool lukasiewiczImplicationOfTriboolValueA:yes triboolValueB:unknown], @"+ → 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueNo, [MCTribool lukasiewiczImplicationOfTriboolValueA:yes triboolValueB:no], @"+ → - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool lukasiewiczImplicationOfTriboolValueA:unknown triboolValueB:yes], @"0 → + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool lukasiewiczImplicationOfTriboolValueA:unknown triboolValueB:unknown], @"0 → 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool lukasiewiczImplicationOfTriboolValueA:unknown triboolValueB:no], @"0 → - computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool lukasiewiczImplicationOfTriboolValueA:no triboolValueB:yes], @"- → + computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool lukasiewiczImplicationOfTriboolValueA:no triboolValueB:unknown], @"- → 0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool lukasiewiczImplicationOfTriboolValueA:no triboolValueB:no], @"- → - computed incorrectly.");
}

- (void)testTriboolNegation
{
    MCTriboolValue yes = MCTriboolValueYes;
    MCTriboolValue no = MCTriboolValueNo;
    MCTriboolValue unknown = MCTriboolValueUnknown;
    
    XCTAssertEqual(MCTriboolValueNo, [MCTribool negationOfTriboolValue:yes], @"¬+ computed incorrectly.");
    XCTAssertEqual(MCTriboolValueUnknown, [MCTribool negationOfTriboolValue:unknown], @"¬0 computed incorrectly.");
    XCTAssertEqual(MCTriboolValueYes, [MCTribool negationOfTriboolValue:no], @"¬- computed incorrectly.");
}

@end
