//
//  atom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

let letters = NSCharacterSet.letterCharacterSet()
let digits = NSCharacterSet.decimalDigitCharacterSet()
func equals<T:Equatable>(a:T)->Props1<T>.Pred{
    return {(x:T)->Bool in
        return a==x
    }
}

struct One<S:CollectionType where S.Generator.Element:Equatable>:Parsec {
    typealias ItemType = S.Generator.Element
    var element:S.Generator.Element
    let pred:Props1<ItemType>.Pred
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var pre = state.next(self.pred)
        switch pre {
        case let .Success(value):
            return (value, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Element \(self.element) Missmatch."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except \(self.element) but Eof."))
        }
    }
    
    init(_ element:ItemType){
        self.element = element
        self.pred = equals(element)
    }
    init(_ element:ItemType , subject:(ItemType)->Props1<ItemType>.Pred){
        self.element = element
        self.pred = subject(element)
    }
}

struct Eof<S:CollectionType>:Parsec {
    typealias ItemType = S.Generator.Element
    typealias StateType = BasicState<S>
    func walk(state: StateType) -> (ItemType?, ParsecStatus) {
        var item = state.next()
        if item == nil {
            return (nil, ParsecStatus.Success)
        } else {
            return (item, ParsecStatus.Failed("Except Eof but \(item)"))
        }
    }
}

struct Digit: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props1<ItemType>.Pred = {(c:ItemType)->Bool in
        return digits.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var pre = state.next(pred)
        switch pre {
        case let .Success(value):
            return (value, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except digit at \(state.pos) but not match."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except digit but Eof."))
        }
    }
}

struct Letter: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props1<ItemType>.Pred = {(c:ItemType)->Bool in
        return letters.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var pre = state.next(pred)
        switch pre {
        case let .Success(value):
            return (value, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except letter at \(state.pos) but not match."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except letter but Eof."))
        }
    }
}

typealias Char = One<String.UnicodeScalarView>

struct Text: Parsec {
    typealias ItemType = String.UnicodeScalarView
    typealias S = String.UnicodeScalarView
    var value:ItemType
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        for idx in value.startIndex...value.endIndex {
            var re = state.next()
            if re == nil {
                return (nil, ParsecStatus.Failed("Except Text \(value) but Eof"))
            } else {
                var rune = re!
                if rune != value[idx] {
                    return (nil, ParsecStatus.Failed("Text[\(idx)]:\(value[idx]) not match Data[\(state.pos)]:\(rune)"))
                }
            }
        }
        return (value, ParsecStatus.Success)
    }
}

struct Return<E, S:CollectionType>:Parsec{
    typealias ItemType = E
    let value:ItemType?
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        return (value, ParsecStatus.Success)
    }
}

struct Fail<E, S:CollectionType>:Parsec {
    typealias ItemType = E
    let message:String
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        return (nil, ParsecStatus.Failed(message))
    }
}


