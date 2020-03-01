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
import Security

struct CodeSignTool: ParsableCommand {
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: String(describing: Self.self))
    }

    @Flag(name: .shortAndLong, help: "Verbose mode.")
    var verbose: Bool

    func run() throws {
        do {
            Logger.logMode = .commandLine
            Logger.logLevel = self.verbose ? .debug : .info

            try CodeSign.signMainExecutableOnceAndRun()
        }
        catch {
            Logger.log(fatalError: error)
        }
    }
}

CodeSignTool.main()
