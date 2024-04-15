//
//  Request.swift
//  mwdic
//
//  Created by Ziqin Gong on 2024/4/14.
//

import Foundation

func queryAndParse(word: String, apiKey: String) async throws -> LookupResult {
    guard let requestURL = URL(string: "https://www.dictionaryapi.com/api/v3/references/collegiate/json/\(word)?key=\(apiKey)") else {
        fatalError("Invalid URL!")
    }
    let (data, _) = try await URLSession.shared.data(from: requestURL)

    return try JSONDecoder().decode(LookupResult.self, from: data)
}
