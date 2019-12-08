//
//  CodeSign.swift
//  CodeSignKit
//
//  Created by Pedro José Pereira Vieito on 08/12/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit

public enum CodeSign {
    private static let defaultBaseIdentity = "Apple Developement"
    private static var defaultIdentity: String? {
        return ProcessInfo.processInfo.environment["CODESIGNKIT_DEFAULT_IDENTITY"]
    }
    
    public static func sign(
        at url: URL, identity: String? = nil, entitlements: URL? = nil, force: Bool = false) throws {
        var arguments: [String] = []
        
        let identity = identity ?? Self.defaultIdentity ?? Self.defaultBaseIdentity
        arguments += ["-s", identity]

        if let entitlements = entitlements {
            arguments += ["--entitlements", entitlements.path]
        }
        
        if force {
            arguments += ["-f"]
        }
        
        arguments += [url.path]
        
        let process = try Process(
            executableName: "codesign",
            arguments: arguments)
        process.standardError = FileHandle.nullDevice
        try process.runAndWaitUntilExit()
    }
}

extension CodeSign {
    private static var executableSignedEnvironmentKey: String {
        return "CODESIGNKIT_EXECUTABLE_SIGNED__" + ProcessInfo.processInfo.processName.uppercased()
    }
    
    private static var isExecutableSigned: Bool {
        return ProcessInfo.processInfo.environment[Self.executableSignedEnvironmentKey] != nil
    }
    
    private static func signMainExecutableAndRun(file: String = #file) throws {
        let targetDirectory = file.pathURL.deletingLastPathComponent()
        let entitlements = targetDirectory
            .appendingPathComponent(targetDirectory.lastPathComponent)
            .appendingPathExtension("entitlements")
        
        var environment = ProcessInfo.processInfo.environment
        environment[executableSignedEnvironmentKey] = "TRUE"

        try Self.sign(
            at: Bundle.main.executableURL!,
            entitlements: entitlements,
            force: true)
        let process = Process()
        process.executableURL = Bundle.main.executableURL!
        process.arguments = CommandLine.arguments
        process.environment = environment
        try process.runReplacingCurrentProcess()
    }
    
    public static func signMainExecutableOnceAndRun(file: String = #file) throws {
        guard !Self.isExecutableSigned else {
            return
        }
        
        try Self.signMainExecutableAndRun(file: file)
    }
}
