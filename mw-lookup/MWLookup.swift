//
//  main.swift
//  mw-lookup
//
//  Created by Ziqin Gong on 2024/4/14.
//

import ArgumentParser
import Foundation

@main
struct MWLookup: ParsableCommand {
    @Argument(help: "The word to look up.")
    var word: String

    @Option(name: [.customShort("k"), .long], help: "API key.")
    var apiKey: String

    mutating func run() throws {
        print("You want to look up `\(word)' via the API key \(apiKey).")
    }
}
