//
//  CodeSign.swift
//  CodeSignKit
//
//  Created by Pedro José Pereira Vieito on 08/12/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import LoggerKit

public enum CodeSign {
    private static let defaultBaseIdentity = "Apple Developement"
    private static var defaultIdentity: String? {
        return ProcessInfo.processInfo.environment["CODESIGNKIT_DEFAULT_IDENTITY"]
    }
    
    public static func sign(
        at url: URL, identity: String? = nil, entitlementsURL: URL? = nil, force: Bool = false) throws {
        Logger.log(debug: "Signing executable at “\(url.path)” with entitlements “\(entitlementsURL?.path ?? "default")” (force: \(force))…")
        
        var arguments: [String] = []
        
        let identity = identity ?? Self.defaultIdentity ?? Self.defaultBaseIdentity
        arguments += ["-s", identity]
        
        if let entitlementsURL = entitlementsURL {
            arguments += ["--entitlements", entitlementsURL.path]
        }
        
        if force {
            arguments += ["-f"]
        }
        
        arguments += [url.path]
        
        let process = try Process(
            executableName: "codesign",
            arguments: arguments)
        
        let standardErrorPipe = Pipe()
        process.standardError = standardErrorPipe.fileHandleForWriting
        
        do {
            try process.runAndWaitUntilExit()
        }
        catch {
            standardErrorPipe.fileHandleForWriting.closeFile()
            FileHandle.standardError.write(standardErrorPipe.fileHandleForReading.readDataToEndOfFile())
            throw error
        }
    }
}

extension CodeSign {
    private static var executableSignedEnvironmentKey: String {
        return "CODESIGNKIT_EXECUTABLE_SIGNED__" + ProcessInfo.processInfo.processName.uppercased()
    }
    
    private static var isExecutableSigned: Bool {
        return ProcessInfo.processInfo.environment[Self.executableSignedEnvironmentKey] != nil
    }
    
    private static func signMainExecutableAndRun(entitlementsURL: URL? = nil, _file: String = #filePath) throws {
        let targetDirectory = _file.pathURL.deletingLastPathComponent()
        let targetEntitlementsURL = targetDirectory
            .appendingPathComponent(targetDirectory.lastPathComponent)
            .appendingPathExtension("entitlements")
        let defaultEntitlementsURL = FileManager.default.fileExists(at: targetEntitlementsURL) ? targetEntitlementsURL: nil
        let entitlementsURL = entitlementsURL ?? defaultEntitlementsURL

        try Self.sign(
            at: Bundle.main.executableURL!,
            entitlementsURL: entitlementsURL,
            force: true)
        
        var environment = ProcessInfo.processInfo.environment
        environment[executableSignedEnvironmentKey] = "TRUE"
        let process = Process()
        process.executableURL = Bundle.main.executableURL!
        process.arguments = Array<String>(CommandLine.arguments.dropFirst())
        process.environment = environment
        try process.runReplacingCurrentProcess()
    }
    
    public static func signMainExecutableOnceAndRun(entitlementsURL: URL? = nil, _file: String = #filePath) throws {
        guard !Self.isExecutableSigned else {
            return
        }
        
        try Self.signMainExecutableAndRun(entitlementsURL: entitlementsURL, _file: _file)
    }
}
