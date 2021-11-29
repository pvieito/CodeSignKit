//
//  main.swift
//  CodeSignTool
//
//  Created by Pedro José Pereira Vieito on 08/12/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import LoggerKit
import ArgumentParser
import CodeSignKit

struct CodeSignTool: ParsableCommand {
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: String(describing: Self.self))
    }
    
    @Option(name: .shortAndLong, help: "Input executable.")
    var input: String?

    @Option(name: .shortAndLong, help: "Signature entitlements.")
    var entitlements: String?

    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Force signature.")
    var force: Bool = false

    @Flag(name: .shortAndLong, help: "Verbose mode.")
    var verbose: Bool = false

    func run() throws {
        do {
            Logger.logMode = .commandLine
            Logger.logLevel = self.verbose ? .debug : .info

            let entitlementsURL = self.entitlements?.pathURL
            if let executableURL = input?.pathURL {
                try CodeSign.sign(at: executableURL, entitlementsURL: entitlementsURL, force: self.force)
            }
            else {
                try CodeSign.signMainExecutableOnceAndRun(entitlementsURL: entitlementsURL)
                Logger.log(success: "Running as self-signed executable…")
            }
        }
        catch {
            Logger.log(fatalError: error)
        }
    }
}

CodeSignTool.main()
