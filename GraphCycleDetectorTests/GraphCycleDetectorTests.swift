//
//  GraphCycleDetectorTests.swift
//  GraphCycleDetectorTests
//
//  Created by Cheng Zhang on 9/5/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import XCTest
@testable import GraphCycleDetector

class GraphCycleDetectorTests: XCTestCase {
    
    // MARK: - Check Cycle
    
    func testHasCycleWithoutCycle() {
        // 1. GIVEN (Condition): initialize courses
        let graphCycleDetector = GraphCycleDetector<Course>()
        let courses = coursesWithoutCycle
        
        // 2. WHEN (Execution)
        let hasCycle = graphCycleDetector.hasCycle(courses)
        
        // 3. THEN (Assertion)
        XCTAssertFalse(hasCycle, "Shouldn't find a cycle in graph.")
    }
    
    func testHasCycleWithCycle() {
        // 1. GIVEN (Condition): initialize courses
        let graphCycleDetector = GraphCycleDetector<Course>()
        let courses = coursesWithCycle
        
        // 2. WHEN (Execution)
        let hasCycle = graphCycleDetector.hasCycle(courses)
        
        // 3. THEN (Assertion)
        XCTAssertTrue(hasCycle, "Should find a cycle in graph.")
    }
    
    // MARK: - Find Order
    
    func testFindOrderWithoutCycle() {
        // 1. GIVEN (Condition): initialize courses
        let graphCycleDetector = GraphCycleDetector<Course>()
        let courses = coursesWithoutCycle
        
        // 2. WHEN (Execution)
        let path = graphCycleDetector.findOrder(courses)
        
        // 3. THEN (Assertion)
        XCTAssertTrue(path != nil, "Expected one valid path in graph")
        XCTAssertEqual(path!, [2, 3, 1, 0, 4].flatMap{ courses[$0]}, "Path should be as dependency relationship")
    }
    
    func testFindOrderWithCycle() {
        // 1. GIVEN (Condition): initialize courses
        let graphCycleDetector = GraphCycleDetector<Course>()
        let courses = coursesWithCycle
        
        // 2. WHEN (Execution)
        let path = graphCycleDetector.findOrder(courses)
        
        // 3. THEN (Assertion)
        XCTAssertTrue(path == nil, "Path should be nil as cycle exists in graph")
    }
}

/// Mocked courses
fileprivate extension GraphCycleDetectorTests {
    // Dependency: 2<-3<-1<-0<-4<-1
    var coursesWithCycle: [Course] {
        var courses = (0..<5).flatMap{Course($0)}
        courses[4].dependencies.append(courses[0])
        courses[0].dependencies.append(courses[1])
        courses[1].dependencies.append(courses[3])
        courses[3].dependencies.append(courses[2])
        courses[1].dependencies.append(courses[4])
        return courses
    }
    
    // Dependency: 2<-3<-1<-0<-4
    var coursesWithoutCycle: [Course] {
        var courses = (0..<5).flatMap{Course($0)}
        courses[4].dependencies.append(courses[0])
        courses[0].dependencies.append(courses[1])
        courses[1].dependencies.append(courses[3])
        courses[3].dependencies.append(courses[2])
        return courses
    }
}

/// Dependentable Course
struct Course: Dependentable, CustomStringConvertible {
    var id: Int
    var dependencies: [Course]
    
    init(_ id: Int, dependencies: [Course] = []) {
        self.id = id
        self.dependencies = dependencies
    }
    
    /// Hashable
    public var hashValue: Int {
        return id
    }
    
    /// Equatable
    public static func ==(lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// CustomStringConvertible
    var description: String {
        return "id: \(id)"
    }
}

