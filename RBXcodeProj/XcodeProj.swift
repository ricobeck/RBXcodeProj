//
//  XcodeProject.swift
//  RBXcodeProj
//
//  Created by rick on 30/03/15.
//  Copyright (c) 2015 ricobeck. All rights reserved.
//

import Cocoa


private struct XcodeProjectStructure {
    static let RootObject = "rootObject"
    static let Classes = "classes"
    static let ObjectVersion = "objectVersion"
    static let ArchiveVersion = "archiveVersion"
    static let Objects = "objects"
}

public struct XcodeProjectInfo {
    let developmentRegion: String?
}


public enum XcodeProjectObjectType: String {
    case BuildFile = "PBXBuildFile"
    case FileReference = "PBXFileReference"
    case FrameworksBuildPhase = "PBXFrameworksBuildPhase"
    case Group = "PBXGroup"
    case NativeTarget = "PBXNativeTarget"
    case Project = "PBXProject"
    case ResourcesBuildPhase = "PBXResourcesBuildPhase"
    case ShellScriptBuildPhase = "PBXShellScriptBuildPhase"
    case SourcesBuildPhase = "PBXSourcesBuildPhase"
    case VariantGroup = "PBXVariantGroup"
    case BuildConfiguration = "XCBuildConfiguration"
    case ConfigurationList = "XCConfigurationList"
}

public enum XcodeProjectFileReferenceType: String {
    case SourceCodeHeader = "sourcecode.c.h"
    case SourceCodeSwift = "sourcecode.swift"
    case SourceCodeObjC = "sourcecode.c.objc"
    case SourceCodeObjCPlusPlus = "sourcecode.cpp.objcpp"
    case SourceCodeCPlusPlus = "sourcecode.cpp.cpp"
    case Framework = "wrapper.framework"
    case Bundle = "wrapper.cfbundle"
    case PropertyListStrings = "text.plist.strings"
    case PropertyListXML = "text.plist.xml"
    case Storyboard = "file.storyboard"
    case Xib = "file.xib"
    case ImageResourcePNG = "image.png"
    case ImageResourceJPG = "image.jpeg"
    case Archive = "archive.ar"
    case HTML = "text.html"
    case CSS = "text.css"
    case XML = "text.xml"
    case TEXT = "text"
    case XcodeProject = "wrapper.pb-project"
    case XcodeConfig = "text.xcconfig"
    
    case ReferenceFolder = "folder"
    case File = "file"
    case AssetCatalog = "folder.assetcatalog"
    
    case UnknownFileReferenceType = "unknown"
}

public enum XcodeProjectProductType: String {
    case Application = "com.apple.product-type.application"
    
    case UnknownProductType = "unknown"
}

public struct XcodeProjectInfoKeys {
    static let isa = "isa"
    static let FileRef = "fileRef"
    static let ExplicitFileType = "explicitFileType"
    static let FileEncoding = "fileEncoding"
    static let LastKnownFileType = "lastKnownFileType"
    static let Path = "path"
    static let SourceTree = "sourceTree"
    static let Files = "files"
    static let BuildActionMask = "buildActionMask"
    static let RunOnlyForDeploymentPostprocessing = "runOnlyForDeploymentPostprocessing"
    static let Children = "children"
    static let Name = "name"
    static let ProductType = "productType"
    static let KnownRegions = "knownRegions"
    static let ProjectDirPath = "projectDirPath"
    static let DevelopmentRegion = "developmentRegion"
    static let MainGroup = "mainGroup"
}

public protocol XcodeRootObjectConformable {
    var isa : XcodeProjectObjectType {get}
}

public protocol XcodeObjectConformable: XcodeRootObjectConformable {
    var isa : XcodeProjectObjectType {get}
    var project: XcodeProject? {get}
}

public protocol XcodeObjectChildConformable: XcodeRootObjectConformable {
    var parent: XcodeObjectConformable? {get}
}

public protocol XcodeGroupConformable: XcodeObjectConformable {
    
    var children: [XcodeObjectConformable]? {get}
}

public protocol XcodeFileConformable: XcodeObjectConformable {
    
    var files: [XcodeObjectConformable]? {get}
}


public protocol XcodePathComponentConformable {
    
    var path: String? {get}
}

//MARK: - Build File

public struct XcodeBuildFile: XcodeObjectConformable {
    
    public var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.BuildFile
    }
    public var project: XcodeProject?
    
    let fileRef: String
}


public extension XcodeBuildFile {
    
    public init(fromDictionary dictionary: [String: AnyObject]) {
        fileRef = dictionary[XcodeProjectInfoKeys.FileRef] as! String
    }

}

//MARK: - File Reference

struct XcodeFileReference: XcodeObjectConformable, XcodeObjectChildConformable, XcodePathComponentConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.FileReference
    }
    var project: XcodeProject?
    var parent: XcodeObjectConformable?
    
    let explicitFileType: String
    let fileEncoding: Int
    let lastKnownFileType: String
    var path: String?
    let sourceTree: String
    let fileType: XcodeProjectFileReferenceType
}

extension XcodeFileReference {
    
    init(fromDictionary dictionary: [String: AnyObject]) {
        explicitFileType = dictionary[XcodeProjectInfoKeys.ExplicitFileType] as? String ?? "Unknown"
        fileEncoding = dictionary[XcodeProjectInfoKeys.FileEncoding] as? Int ?? 0
        lastKnownFileType = dictionary[XcodeProjectInfoKeys.LastKnownFileType] as? String ?? "Unknown"
        path = dictionary[XcodeProjectInfoKeys.Path] as? String
        sourceTree = dictionary[XcodeProjectInfoKeys.SourceTree] as! String
        
        if let lastKnownFileType = dictionary[XcodeProjectInfoKeys.LastKnownFileType] as? String {
            if let type = XcodeProjectFileReferenceType(rawValue: lastKnownFileType) {
                fileType = type
            } else {
                fileType = XcodeProjectFileReferenceType.UnknownFileReferenceType
            }
        } else {
            fileType = XcodeProjectFileReferenceType.UnknownFileReferenceType
        }
    }
    
}

extension XcodeFileReference {
    
    func relativePath() -> String {
        var paths = [String]()
        if let parent = parent as? XcodeGroup {
            paths.append(parent.relativePath())
        }
        if let path = path {
            paths.append(path)
        }
        
        return paths.joinWithSeparator("/")
    }
}

extension XcodeGroup {
    
    func relativePath() -> String {
        var paths = [String]()
        if let parent = parent as? XcodeGroup {
            paths.append(parent.relativePath())
        }
        if let path = path {
            paths.append(path)
        }
        return paths.joinWithSeparator("/")
    }
}

//MARK: - Framework Build Phase

struct XcodeFrameworkBuildPhase: XcodeFileConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.FrameworksBuildPhase
    }
    var project: XcodeProject?
    
    let buildActionMask: Int
    let runOnlyForDeploymentPostprocessing: Bool
    
    let fileKeys: [String]
    var files: [XcodeObjectConformable]? {
        return [XcodeObjectConformable]?()
    }
}

extension XcodeFrameworkBuildPhase {
    
    init(fromDictionary dictionary: [String: AnyObject]) {
        buildActionMask = dictionary[XcodeProjectInfoKeys.BuildActionMask] as! Int
        fileKeys = dictionary[XcodeProjectInfoKeys.Files] as! [String]
        runOnlyForDeploymentPostprocessing = dictionary[XcodeProjectInfoKeys.RunOnlyForDeploymentPostprocessing] as! Bool
    }
    
}

//MARK: - Group

struct XcodeGroup: XcodeGroupConformable, XcodeObjectChildConformable, XcodePathComponentConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.Group
    }
    var project: XcodeProject?
    var parent: XcodeObjectConformable?
    
    var path: String?
    let sourceTree: String
    
    let childrenKeys: [String]
    var children: [XcodeObjectConformable]? {
        return [XcodeObjectConformable]?()
    }
}

extension XcodeGroup {
    
    init(fromDictionary dictionary: [String: AnyObject]) {
        if let storedPath = dictionary[XcodeProjectInfoKeys.Path] as? String {
            path = storedPath
        } else {
            path = String?()
        }
        childrenKeys = dictionary[XcodeProjectInfoKeys.Children] as! [String]
        sourceTree = dictionary[XcodeProjectInfoKeys.SourceTree] as! String
    }
}

//MARK: - Native Target

struct XcodeNativeTarget: XcodeObjectConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.NativeTarget
    }
    var project: XcodeProject?
    
    let name: String
    let productType: XcodeProjectProductType
    
}

extension XcodeNativeTarget {
    
    init(fromDictionary dictionary: [String: AnyObject]) {
        name = dictionary[XcodeProjectInfoKeys.Name] as! String
        var castedProductType = XcodeProjectProductType.UnknownProductType
        if let productTypeInfo = dictionary[XcodeProjectInfoKeys.ProductType] as? String {
            if let type = XcodeProjectProductType(rawValue: productTypeInfo) {
                castedProductType = type
            }
        }
        productType = castedProductType
    }
}

//MARK: - Xcode Project

public struct XcodeProject: XcodeRootObjectConformable {
    
    public var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.Project
    }
    
    let developmentRegion: String
    let knownRegions: [String]?
    let projectDirPath: String
    let mainGroupRef: String
    let path: String?
}

extension XcodeProject {
    
    init(fromDictionary dictionary: [String: AnyObject], atPath path: String) {
        self.path = path
        developmentRegion = dictionary[XcodeProjectInfoKeys.DevelopmentRegion] as! String
        projectDirPath = dictionary[XcodeProjectInfoKeys.ProjectDirPath] as! String
        if let castedKnownRegions = dictionary[XcodeProjectInfoKeys.KnownRegions] as? [String] {
            knownRegions = castedKnownRegions
        } else {
            knownRegions = [String]?()
        }
        mainGroupRef = dictionary[XcodeProjectInfoKeys.MainGroup] as! String
    }
}

//MARK: - Resource Build Phase

struct XcodeResourcesBuildPhase: XcodeObjectConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.ResourcesBuildPhase
    }
    var project: XcodeProject?
}

//MARK: - Shell Script Phase

struct XcodeShellScriptBuildPhase: XcodeObjectConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.ShellScriptBuildPhase
    }
    var project: XcodeProject?
}

//MARK: - Sources Build Phase

struct XcodeSourcesBuildPhase: XcodeObjectConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.SourcesBuildPhase
    }
    var project: XcodeProject?
}

//MARK: - Variant Group

public struct XcodeVariantGroup: XcodeGroupConformable, XcodeObjectChildConformable {
    
    public var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.VariantGroup
    }
    public var project: XcodeProject?
    public var parent: XcodeObjectConformable?
    
    let name: String
    let sourceTree: String
    let childrenKeys: [String]
    public var children: [XcodeObjectConformable]? {
        return [XcodeObjectConformable]?()
    }
}


extension XcodeVariantGroup {
    
    init(fromDictionary dictionary: [String: AnyObject]) {
        name = dictionary[XcodeProjectInfoKeys.Name] as! String
        childrenKeys = dictionary[XcodeProjectInfoKeys.Children] as! [String]
        sourceTree = dictionary[XcodeProjectInfoKeys.SourceTree] as! String
    }
}

extension XcodeVariantGroup {
    
    func relativePath() -> String {
        var path = ""
        if let parent = parent as? XcodeGroup {
            path += parent.relativePath()
        }
        return (path as NSString).stringByAppendingPathComponent(name)
    }
    
    public func absolutePath() -> String {
        return (project!.path! as NSString).stringByAppendingPathComponent(self.relativePath())
    }
}

//MARK: - Build Configuration

struct XcodeBuildConfiguration: XcodeObjectConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.BuildConfiguration
    }
    var project: XcodeProject?
}

//MARK: - Configuration List

struct XcodeConfigurationList: XcodeObjectConformable {
    
    var isa : XcodeProjectObjectType {
        return XcodeProjectObjectType.ConfigurationList
    }
    var project: XcodeProject?
}



public class RBXcodeProject {
    
    private let projectObjects: [String: AnyObject]
    private let projectPath: String
    private var project: XcodeProject!
    
    public var objects = [XcodeRootObjectConformable]()
    
    public var variantGroups: [XcodeVariantGroup]? {
        let filteredObjects = objects.filter {$0 is XcodeVariantGroup}
        // Casting to [XcodeVariantGroup] currently crashes with “fatal error: can't unsafeBitCast between types of different sizes”
        let mappedObjects = filteredObjects.map {
            return $0 as! XcodeVariantGroup
        }
        return mappedObjects
    }
    
    var projectInfo: XcodeProjectInfo? {
        let objects = projectObjects[XcodeProjectStructure.Objects]! as! [String: AnyObject]
        let rootObjectKey =  projectObjects[XcodeProjectStructure.RootObject] as! String
        let rootObject = objects[rootObjectKey]! as! [String: AnyObject]

        return XcodeProjectInfo(developmentRegion: rootObject["developmentRegion"] as? String)
    }
    
    
    public init?(path: String) {
        projectPath = (path as NSString).stringByDeletingLastPathComponent
        if let data = NSData(contentsOfFile: (path as NSString).stringByAppendingPathComponent("project.pbxproj")) {
            
            let format = UnsafeMutablePointer<NSPropertyListFormat>()
            if let allObjects = try? NSPropertyListSerialization.propertyListWithData(data, options: [], format: format) as? [String : AnyObject], objects = allObjects {
                projectObjects = objects
            } else {
                projectObjects = [String: AnyObject]()
                return nil
            }
        } else {
            
            projectObjects = [String: AnyObject]()
            return nil
        }
    }
    
    
    func parseObject(fromDictionary dictionary: [String: AnyObject], parent: XcodeGroupConformable?) {
        if let isa = dictionary[XcodeProjectInfoKeys.isa] as? String, let objectType = XcodeProjectObjectType(rawValue: isa) {
            switch objectType {
            case .BuildFile:
                let buildFile = XcodeBuildFile(fromDictionary: dictionary)
                objects.append(buildFile)
            case .FileReference:
                let fileReference = XcodeFileReference(fromDictionary: dictionary)
                objects.append(fileReference)
            case .FrameworksBuildPhase:
                print("object type: \(objectType.rawValue)")
            case .Group:
                var group = XcodeGroup(fromDictionary: dictionary)
                group.parent = parent
                group.project =  project
                for child in group.childrenKeys {
                    if let dictionary = projectObjects[XcodeProjectStructure.Objects]![child] as? [String: AnyObject] {
                        parseObject(fromDictionary: dictionary, parent: group)
                    }
                }
                objects.append(group)
            case .NativeTarget:
                let nativeTarget = XcodeNativeTarget(fromDictionary: dictionary)
                objects.append(nativeTarget)
            case .Project:
                let project = XcodeProject(fromDictionary: dictionary, atPath: projectPath)
                objects.append(project)
            case .ResourcesBuildPhase:
                print("object type: \(objectType.rawValue)")
            case .ShellScriptBuildPhase:
                print("object type: \(objectType.rawValue)")
            case .SourcesBuildPhase:
                print("object type: \(objectType.rawValue)")
            case .VariantGroup:
                var variantGroup = XcodeVariantGroup(fromDictionary: dictionary)
                variantGroup.parent = parent
                variantGroup.project =  project
                for child in variantGroup.childrenKeys {
                    if let dictionary = projectObjects[XcodeProjectStructure.Objects]![child] as? [String: AnyObject] {
                        parseObject(fromDictionary: dictionary, parent: variantGroup)
                    }
                }
                objects.append(variantGroup)
            case .BuildConfiguration:
                print("object type: \(objectType.rawValue)")
            case .ConfigurationList:
                print("object type: \(objectType.rawValue)")
            }
        }
    }
    
    
    public func parse() {
        let rootObjectKey =  projectObjects[XcodeProjectStructure.RootObject] as! String
        let dictionary = projectObjects[XcodeProjectStructure.Objects]![rootObjectKey] as! [String: AnyObject]
        
        project = XcodeProject(fromDictionary: dictionary, atPath: projectPath)
        let mainGroup = projectObjects[XcodeProjectStructure.Objects]![project.mainGroupRef]
        parseObject(fromDictionary: mainGroup as! [String: AnyObject], parent: nil)
    }
    
}
