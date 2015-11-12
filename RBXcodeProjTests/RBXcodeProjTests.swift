//
//  XcodeProjectTests.swift
//  RBXcodeProj
//
//  Created by rick on 07/04/15.
//  Copyright (c) 2015 ricobeck. All rights reserved.
//

import Cocoa
import XCTest
import RBXcodeProj

class XcodeProjectTests: XCTestCase {

    func testThatParsedObjectCountMatches() {
        
        let projectFileURL = NSBundle(forClass: self.dynamicType).URLForResource("iOSProjectSwift/iOSProjectSwift", withExtension: "xcodeproj")!
        if let project = RBXcodeProject(path: projectFileURL.path!) {
            project.parse()
            
            XCTAssert(project.objects.count == 16, "Expected number of objects in project did not match (\(project.objects.count)")
            guard let variantGroups = project.variantGroups else {
                XCTFail("Project has variant groups")
                return
            }
            XCTAssert(variantGroups.count == 2, "Expected number of variant groups in project did not match (\(variantGroups.count)")
            
        } else {
            XCTFail("could not locate test project at \(projectFileURL)")
        }
    }

}
