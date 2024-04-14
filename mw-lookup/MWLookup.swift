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

    @Option(name: [.customShort("k"), .long], help: "API key.")
    var apiKey: String

    mutating func run() async throws {
        print("You want to look up `\(word)' via the API key \(apiKey).")

        let response = try await queryAndParse(word: word, apiKey: apiKey)
        for item in response {
            print("=== \(item.fl) ===")

            for (i, def) in item.def.enumerated() {
                print("\(i + 1).")

                for sseq in def.sseq {
                    print(sseq)
                }
            }
        }
    }
}
