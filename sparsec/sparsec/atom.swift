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
func equals<T:Equatable>(a:T)->Props<T>.Pred{
    return {(x:T)->Bool in
        return a==x
    }
}

struct One<S:CollectionType where S.Generator.Element:Equatable>:Parsec {
    typealias ItemType = S.Generator.Element
    var element:S.Generator.Element
    let pred:Props<ItemType>.Pred
    func walk(state: BasicState<S>) -> Result<S> {
        return state.next(self.pred)
    }
    
    init(_ element:ItemType){
        self.element = element
        self.pred = equals(element)
    }
    init(_ element:ItemType , subject:(ItemType)->Props<ItemType>.Pred){
        self.element = element
        self.pred = subject(element)
    }
}

struct Eof<S:CollectionType>:Parsec {
    typealias ItemType = S.Generator.Element
    func walk(state: BasicState<S>) -> Result<S> {
        var re = state.next()
        switch re.status {
        case .Failed:
            switch re.value {
            case .Eof:
                return Result<S>(value:Data.Eof, pos:state.pos, status:Status.Success)
            default:
                return Result<S>(value: re.value, pos:state.pos, status: re.status)
            }
        default:
            var message:String = "Except EOF but \(re.value) at \(state.pos)"
            return Result<S>(value: re.value, pos:state.pos, status:Status.Failed(message))
        }
    }
}

class Digit: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props<ItemType>.Pred = {(c:ItemType)->Bool in
        return digits.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> Result<S> {
        return state.next(pred)
    }
}

class Letter: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props<ItemType>.Pred = {(c:ItemType)->Bool in
        return letters.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> Result<S> {
        return state.next(pred)
    }
}

//typealias Char = One<Character, String>
typealias Char = One<String.UnicodeScalarView>
