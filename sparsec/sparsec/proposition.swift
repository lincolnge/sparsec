//
//  proposition.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/19.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

let letters = NSCharacterSet.letterCharacterSet()
let digits = NSCharacterSet.decimalDigitCharacterSet()
let spaces = NSCharacterSet.whitespaceCharacterSet()
let spacesAndNewlines = NSCharacterSet.whitespaceAndNewlineCharacterSet()
let newlines = NSCharacterSet.newlineCharacterSet()

typealias UChr = UnicodeScalar
typealias UStr = String.UnicodeScalarView

func charSet(title:String, charSet:NSCharacterSet)->Parsec<UChr, UStr>.Parser {
    let pred = {(c:UnicodeScalar)-> Bool in
        return charSet.longCharacterIsMember(c.value)
    }
    return {(state:BasicState<UStr>)->(UChr?, ParsecStatus) in
        var pre = state.next(pred)
        switch pre {
        case let .Success(value):
            return (value, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except \(title) at \(state.pos) but not match."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except \(title) but Eof."))
        }
    }
}

let digit = charSet("digit", digits)
let letter = charSet("letter", letters)
let space = charSet("space", spaces)
let sol = charSet("space or newline", spacesAndNewlines)
let newline = charSet("newline", newlines)

func char(c:UChr)->Parsec<UChr, UStr>.Parser {
    return one(c)
}

let uint = many1(digit) >>= {(x:[UChr?]?)->Parsec<UStr, UStr>.Parser in
    return pack(cs2us(x!))
}

let int = option(try(char("-")), nil) >>= {(x:UChr?)->Parsec<UStr, UStr>.Parser in
    return {(state:BasicState<UStr>)->(UStr?, ParsecStatus) in
        var (re, status) = uint(state)
        switch status {
        case .Success:
            if x == nil {
                return (re, ParsecStatus.Success)
            }else{
                var s:String=""+String(re!)
                return (s.unicodeScalars, ParsecStatus.Success)
            }
        case .Failed:
            return (nil, ParsecStatus.Failed("Except a Unsigned Integer token but failed."))
        }
    }
}

func cs2us(cs:[UChr?]) -> UStr {
    var re = "".unicodeScalars
    var values = unbox(cs)
    for c in  values {
        re.append(c)
    }
    return re
}

func cs2str(cs:[UChr?]) -> String {
    var re = "".unicodeScalars
    var values = unbox(cs)
    for c in  values {
        re.append(c)
    }
    return String(re)
}