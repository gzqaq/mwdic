//
//  main.swift
//  mw-lookup
//
//  Created by Ziqin Gong on 2024/4/14.
//

import ArgumentParser
import Foundation

@main
struct MWLookup: AsyncParsableCommand {
    @Argument(help: "The word to look up.")
    var word: String

    @Option(name: [.customShort("k"), .long], help: "API key. Can also be passed by MW_API_KEY.")
    var apiKey: String?

    mutating func run() async throws {
        let validKey: String

        if let apiKey {
            validKey = apiKey
        } else if let key = ProcessInfo.processInfo.environment["MW_API_KEY"] {
            validKey = key
        } else {
            fatalError("No API key provided!")
        }
        print("You want to look up `\(word)' via the API key \(validKey).")

        let response = try await queryAndParse(word: word, apiKey: validKey)
        printResponse(response)
    }
}
