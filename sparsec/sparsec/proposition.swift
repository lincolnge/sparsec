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

func charSet(title:String, charSet:NSCharacterSet)->Parsec<UnicodeScalar, String.UnicodeScalarView>.Parser {
    let pred = {(c:UnicodeScalar)-> Bool in
        return charSet.longCharacterIsMember(c.value)
    }
    return {(state:BasicState<String.UnicodeScalarView>)->(UnicodeScalar?, ParsecStatus) in
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

func char(c:UnicodeScalar)->Parsec<UnicodeScalar, String.UnicodeScalarView>.Parser {
    return one(c)
}

let uint = bind(many1(digit), {(x:[UnicodeScalar?]?)->Parsec<String.UnicodeScalarView, String.UnicodeScalarView>.Parser in
        var re = "".unicodeScalars
        var values = unbox(x!)
        for c in  values {
            re.append(c)
        }
        return pack(re)
})

let int = option(try(char("-")), nil) >>= {(x:UnicodeScalar?)->Parsec<String.UnicodeScalarView, String.UnicodeScalarView>.Parser in
    return {(state:BasicState<String.UnicodeScalarView>)->(String.UnicodeScalarView?, ParsecStatus) in
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

