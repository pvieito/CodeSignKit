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
import CommandLineKit
import CodeSignKit

let inputOption = StringOption(shortFlag: "i", longFlag: "input", helpMessage: "Input item.")
let simulatorOption = BoolOption(longFlag: "sim", helpMessage: "Read simulator entitlements.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(inputOption, simulatorOption, verboseOption, helpOption)

do {
    try cli.parse(strict: true)
}
catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(0)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .debug : .info

try CodeSign.signMainExecutableOnceAndRun()
