//
//  Response.swift
//  mwdic
//
//  Created by Ziqin Gong on 2024/4/15.
//

import Foundation

// MARK: - Printable

protocol Printable {
    func repr(indent: Int) -> String
}

private func getIndentation(_ length: Int) -> String {
    return String(repeating: " ", count: length)
}

// MARK: - ParseError

enum ParseError: Error {
    case unsupportedKey(_ key: String, of: String)
}

// MARK: - AqItem

/// Attributes of quote.
struct AqItem: Codable {
    let auth, source, aqdate, subsource: String?
}

// MARK: - VisItem

/// Verbal illustrations.
struct VisItem: Codable, Printable {
    let t: String
    let aq: AqItem?

    func repr(indent: Int = 0) -> String {
        let tab = getIndentation(indent)
        return "\(tab)- \(t)\n"
    }
}

// MARK: - DtItem

/// Defining text.
indirect enum DtItem: Codable, Printable {
    case text(String)
    case vis([VisItem])
    case uns([[DtItem]])

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let key = try container.decode(String.self)

        switch key {
        case "text":
            self = try DtItem.text(container.decode(String.self))
        case "vis":
            self = try DtItem.vis(container.decode([VisItem].self))
        case "uns":
            self = try DtItem.uns(container.decode([[DtItem]].self))
        case _:
            self = DtItem.text("\u{1b}[7mUnsupported key `\(key)` in `DtItem`\u{1b}[0m")
        }
    }

    func repr(indent: Int = 0) -> String {
        var repr = ""

        switch self {
        case .text(let content):
            repr = getIndentation(indent) + content + "\n"

        case .vis(let visItems):
            for it in visItems {
                repr.append(it.repr(indent: indent + 2))
            }

        case .uns(let dtItemsArray):
            for dtItems in dtItemsArray {
                for dtItem in dtItems {
                    repr.append(dtItem.repr(indent: indent + 2))
                }
            }
        }

        return repr
    }
}

// MARK: - SdSense

/// Divided sense.
struct SdSense: Codable, Printable {
    let sd: String
    let dt: [DtItem]

    func repr(indent: Int = 0) -> String {
        var repr = getIndentation(indent)
        repr.append("\u{1b}[3m\(sd)\u{1b}[0m\n")

        for item in dt {
            repr.append(item.repr(indent: indent + 2))
        }

        return repr
    }
}

// MARK: - Sense

/// Sense.
struct Sense: Codable, Printable {
    let sn: String?
    let dt: [DtItem]
    let sdsense: SdSense?

    func repr(indent: Int = 0) -> String {
        var repr = ""

        if let sn {
            let snBold = "\u{1b}[1m\(sn)\u{1b}[0m"
            repr.append(getIndentation(indent) + snBold + "\n")
        }

        for it in dt {
            repr.append(it.repr(indent: indent + 2))
        }

        if let sdsense {
            repr.append(sdsense.repr(indent: indent + 2))
        }

        return repr
    }
}

// MARK: - Bs

/// Binding substitute.
struct Bs: Codable, Printable {
    let sense: Sense

    func repr(indent: Int = 0) -> String {
        return sense.repr(indent: indent)
    }
}

// MARK: - Sen

/// Truncated sense.
struct Sen: Codable, Printable {
    let sn: String?

    func repr(indent: Int = 0) -> String {
        var repr = ""

        if let sn {
            let snBold = "\u{1b}[1m\(sn)\u{1b}[0m"
            repr.append(getIndentation(indent) + snBold + "\n")
        }

        return repr
    }
}

// MARK: - SensesItem

/// Sense, binding substitute, parenthesized sense sequence and truncated sense.
indirect enum SensesItem: Codable, Printable {
    case sense(Sense)
    case bs(Bs)
    case pseq([SensesItem])
    case sen(Sen)

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let key = try container.decode(String.self)

        switch key {
        case "sense":
            self = try SensesItem.sense(container.decode(Sense.self))
        case "bs":
            self = try SensesItem.bs(container.decode(Bs.self))
        case "pseq":
            self = try SensesItem.pseq(container.decode([SensesItem].self))
        case "sen":
            self = try SensesItem.sen(container.decode(Sen.self))
        case _:
            throw ParseError.unsupportedKey(key, of: "SensesItem")
        }
    }

    func repr(indent: Int = 0) -> String {
        var repr = getIndentation(indent)

        switch self {
        case .sense(let sense):
            repr = sense.repr(indent: indent)
        case .bs(let bs):
            repr = bs.repr(indent: indent)
        case .pseq(let pseq):
            repr = ""
            for it in pseq {
                repr.append(it.repr(indent: indent))
            }
        case .sen(let sen):
            repr = sen.repr(indent: indent)
        }

        return repr
    }
}

typealias Senses = [SensesItem]
typealias SSeq = [Senses]

// MARK: - DefItem

/// Definition section.
struct DefItem: Codable, Printable {
    let vd: String?
    let sseq: SSeq

    func repr(indent: Int = 0) -> String {
        var repr = ""

        if let vd {
            let vdBold = "\u{1b}[1m\(vd)\u{1b}[0m"
            repr.append(getIndentation(indent) + vdBold + "\n")
        }

        for senses in sseq {
            for sense in senses {
                repr.append(sense.repr(indent: indent + 2))
            }
        }

        return repr
    }
}

// MARK: - Meta

/// Entry metadata.
struct Meta: Codable, Printable {
    let id, uuid, sort: String
    let stems: [String]
    let offensive: Bool

    func repr(indent: Int = 0) -> String {
        let tab = String(repeating: " ", count: indent)
        let stemsStr = stems.joined(separator: ", ")
        return "\(tab)\u{1b}[1;32m\(id)\u{1b}[0m (\(stemsStr))\n"
    }
}

// MARK: - Entry

/// Entry.
struct Entry: Codable, Printable {
    let meta: Meta
    let fl: String?
    let def: [DefItem]?

    func repr(indent: Int = 0) -> String {
        var repr = meta.repr(indent: indent)
        if let fl {
            if fl != "verb" {
                repr.append("\(getIndentation(indent))\u{1b}[1m\(fl)\u{1b}[0m\n")
            }
        }

        if let def {
            for it in def {
                repr.append(it.repr(indent: indent))
            }
        }

        return repr
    }
}


// MARK: - Misspelling

/// Suggestions for possible misspelling.
typealias Misspelling = String

// MARK: - LookupResult

/// Array of `Entry`s is returned by the API.
typealias LookupResult = [Entry]

/// If there is no word in the dictionary, the API will provide spelling suggestions.
typealias SpellingSuggestions = [Misspelling]

// MARK: - parse data

func parseLookupResult(_ data: Data) throws -> LookupResult {
    return try JSONDecoder().decode(LookupResult.self, from: data)
}

func parseReturnedData(_ data: Data) -> (LookupResult?, SpellingSuggestions?) {
    if let response = try? parseLookupResult(data) {
        return (response, nil)
    } else if let response = try? JSONDecoder().decode(SpellingSuggestions.self, from: data) {
        return (nil, response)
    } else {
        return (nil, nil)
    }
}

// MARK: - print utilities

func cleanTokens(repr: String) -> String {
    return repr.replacing("{bc}", with: "\u{1b}[1m: \u{1b}[0m")
        .replacing("{b}", with: "\u{1b}[1m")
        .replacing("{/b}", with: "\u{1b}[0m")
        .replacing("{it}", with: "\u{1b}[3m")
        .replacing("{/it}", with: "\u{1b}[0m")
        .replacing("{wi}", with: "\u{1b}[3m")
        .replacing("{/wi}", with: "\u{1b}[0m")
        .replacing(/{sx\|([a-zA-Z ]+)\|(.*?)\|(.*?)}/) { result in
            var label: Substring = ""

            if result.2 != "" {
                label = result.2
            } else {
                label = result.1
            }

            if result.3 != "" {
                label.append(contentsOf: " \(result.3)")
            }

            return "\u{1b}[34m\(label)\u{1b}[0m"
        }
}

func printResponse(_ response: LookupResult) {
    for entry in response {
        print(cleanTokens(repr: entry.repr()))
    }
}

func printSuggestions(_ response: SpellingSuggestions) {
    print("""
    The word you've entered isn't in the dictionary.\
    Some spelling suggestions:
    """)
    print(response.joined(separator: ", "))
}
