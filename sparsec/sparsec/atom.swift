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

struct One<E:Equatable, S:CollectionType where S.Generator.Element==E>:Parsec {
    let element:E
    let pred:Props<E>.Pred
    func walk(state: BasicState<S>) -> Result<E> {
        var re = state.next(self.pred)
        return re
    }
    
    init(_ element:E){
        self.element = element
        self.pred = equals(element)
    }
    init(_ element:E , subject:(E)->Props<E>.Pred){
        self.element = element
        self.pred = subject(element)
    }
}

struct Eof<E, S:CollectionType where S.Generator.Element==E>:Parsec {
    func walk(state: BasicState<S>) -> Result<E> {
        var re = state.next()
        switch re.status {
        case .Failed:
            switch re.value {
            case .Eof:
                return Result<E>(value: Data<E>.Eof, status:Status.Success)
            default:
                return Result<E>(value: re.value, status: re.status)
            }
        default:
            var message = "Except Eof but got \(re)"
            return Result<E>(value: re.value, status:Status.Failed(message))
        }
    }
}

class Digit: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props<ItemType>.Pred = {(c:ItemType)->Bool in
        return digits.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> Result<ItemType> {
        return state.next(pred)
    }
}

class Letter: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props<ItemType>.Pred = {(c:ItemType)->Bool in
        return letters.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> Result<ItemType> {
        return state.next(pred)
    }
}

//typealias Char = One<Character, String>
typealias Char = One<UnicodeScalar, String.UnicodeScalarView>
