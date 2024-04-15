//
//  Response.swift
//  mw-lookup
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
        return "\(tab)\(t)\n"
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
            throw ParseError.unsupportedKey(key, of: "DtItem")
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
        repr.append("\(sd)\n")

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
            repr.append(getIndentation(indent) + sn + "\n")
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
            repr.append(getIndentation(indent) + sn + "\n")
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
            repr.append(getIndentation(indent) + vd + "\n")
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
        return "\(tab)\(id) (\(stemsStr))\n"
    }
}

// MARK: - Entry

/// Entry.
struct Entry: Codable, Printable {
    let meta: Meta
    let def: [DefItem]

    func repr(indent: Int = 0) -> String {
        var repr = meta.repr(indent: indent)

        for it in def {
            repr.append(it.repr(indent: indent))
        }

        return repr
    }
}

typealias LookupResult = [Entry]


func printResponse(_ response: LookupResult) {
    for entry in response {
        print(entry.repr())
    }
}
