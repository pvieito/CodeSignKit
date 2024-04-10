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
    private static let defaultBaseIdentity = "Apple Development"
    private static var defaultIdentity: String? {
        return ProcessInfo.processInfo.environment["CODESIGNKIT_DEFAULT_IDENTITY"]
    }
    
    public static func sign(at url: URL, identity: String? = nil, entitlementsURL: URL? = nil, force: Bool = false) throws {
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
    private static let entitlementsDefaultFileName = "Entitlements"
    private static let entitlementsExtension = "entitlements"

    private static var executableSignedEnvironmentKey: String {
        return "CODESIGNKIT_EXECUTABLE_SIGNED__" + ProcessInfo.processInfo.processName.uppercased()
    }
    
    private static var isExecutableSigned: Bool {
        return ProcessInfo.processInfo.environment[Self.executableSignedEnvironmentKey] != nil
    }
    
    private static func findPairedEntitlementsFile(to file: URL) -> URL? {
        var entitlementsFileNames = [self.entitlementsDefaultFileName]
        entitlementsFileNames += [file.deletingPathExtension().lastPathComponent]
        let targetDirectory: URL
        if FileManager.default.directoryExists(at: file) {
            targetDirectory = file
        }
        else if FileManager.default.nonDirectoryFileExists(at: file) {
            targetDirectory = file.deletingLastPathComponent()
            entitlementsFileNames += [targetDirectory.lastPathComponent]
        }
        else {
            return nil
        }
        for entitlementsFileName in entitlementsFileNames {
            let pairedEntitlementsFile = targetDirectory.appendingPathComponents(entitlementsFileName).appendingPathExtension(self.entitlementsExtension)
            if FileManager.default.fileExists(at: pairedEntitlementsFile) {
                return pairedEntitlementsFile
            }
        }
        return nil
    }
    
    private static func signMainExecutableAndRun(entitlementsURL: URL? = nil, _filePath: String = #filePath) throws {
        let entitlementsURL = entitlementsURL ?? findPairedEntitlementsFile(to: _filePath.pathURL)

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
    
    public static func signMainExecutableOnceAndRun(entitlementsURL: URL? = nil, _filePath: String = #filePath) throws {
        guard !Self.isExecutableSigned else {
            return
        }
        
        try Self.signMainExecutableAndRun(entitlementsURL: entitlementsURL, _filePath: _filePath)
    }
}
