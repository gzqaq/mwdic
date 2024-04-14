//
//  Response.swift
//  mw-lookup
//
//  Created by Ziqin Gong on 2024/4/14.
//

import Foundation

// MARK: - LookupResultElement

struct LookupResultElement: Codable {
    let meta: Meta
    let hom: Int?
    let hwi: Hwi
    let fl: String
    let def: [Def]
    let et: [[String]]?
    let date: String
    let shortdef: [String]
    let ins: [In]?
    let uros: [Uro]?
    let syns: [Syn]?
}

// MARK: - Def

struct Def: Codable {
    let sseq: [[[SseqElement]]]
    let vd: String?
}

enum SseqElement: Codable {
    case enumeration(SseqEnum)
    case sseqClass(SseqClass)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(SseqEnum.self) {
            self = .enumeration(x)
            return
        }
        if let x = try? container.decode(SseqClass.self) {
            self = .sseqClass(x)
            return
        }
        throw DecodingError.typeMismatch(SseqElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SseqElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .enumeration(let x):
            try container.encode(x)
        case .sseqClass(let x):
            try container.encode(x)
        }
    }
}

// MARK: - SseqClass

struct SseqClass: Codable {
    let sn: String?
    let dt: [[SseqDt]]
    let sls: [String]?
    let sdsense: Sdsense?
}

enum SseqDt: Codable {
    case string(String)
    case unionArray([DtDtUnion])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([DtDtUnion].self) {
            self = .unionArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(SseqDt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SseqDt"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .unionArray(let x):
            try container.encode(x)
        }
    }
}

enum DtDtUnion: Codable {
    case dtClass(DtClass)
    case stringArrayArray([[String]])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([[String]].self) {
            self = .stringArrayArray(x)
            return
        }
        if let x = try? container.decode(DtClass.self) {
            self = .dtClass(x)
            return
        }
        throw DecodingError.typeMismatch(DtDtUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for DtDtUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .dtClass(let x):
            try container.encode(x)
        case .stringArrayArray(let x):
            try container.encode(x)
        }
    }
}

// MARK: - DtClass

struct DtClass: Codable {
    let t: String
    let aq: Aq?
}

// MARK: - Aq

struct Aq: Codable {
    let source, auth: String?
}

// MARK: - Sdsense

struct Sdsense: Codable {
    let sd: String
    let dt: [[PtUnion]]
}

enum PtUnion: Codable {
    case ptClassArray([PtClass])
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([PtClass].self) {
            self = .ptClassArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(PtUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for PtUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .ptClassArray(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - PtClass

struct PtClass: Codable {
    let t: String
}

enum SseqEnum: String, Codable {
    case sense
}

// MARK: - Hwi

struct Hwi: Codable {
    let hw: String
    let prs: [PR]?
}

// MARK: - PR

struct PR: Codable {
    let mw: String
    let sound: Sound?
}

// MARK: - Sound

struct Sound: Codable {
    let audio: String
    let ref: Ref
    let stat: String
}

enum Ref: String, Codable {
    case c
    case owl
}

// MARK: - In

struct In: Codable {
    let inIf: String

    enum CodingKeys: String, CodingKey {
        case inIf = "if"
    }
}

// MARK: - Meta

struct Meta: Codable {
    let id, uuid, sort: String
    let src: Src
    let section: Section
    let stems: [String]
    let offensive: Bool
}

enum Section: String, Codable {
    case alpha
}

enum Src: String, Codable {
    case collegiate
}

// MARK: - Syn

struct Syn: Codable {
    let pl: String
    let pt: [[PtUnion]]
}

// MARK: - Uro

struct Uro: Codable {
    let ure: String
    let prs: [PR]?
    let fl: String
    let vrs: [VR]?
}

// MARK: - VR

struct VR: Codable {
    let vl, va: String
    let prs: [PR]
}

typealias LookupResult = [LookupResultElement]
