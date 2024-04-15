//
//  main.swift
//  mwdic
//
//  Created by Ziqin Gong on 2024/4/14.
//

import ArgumentParser
import Foundation

@main
struct Mwdic: AsyncParsableCommand {
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

        let data = try await queryAPI(word: word, apiKey: validKey)
        let (result, suggestions) = parseReturnedData(data)

        if let result {
            printResponse(result)
        } else if let suggestions {
            printSuggestions(suggestions)
        } else {
            let rawString = String(decoding: data, as: UTF8.self)
            print("Error when parsing \(rawString)")
        }
    }
}
