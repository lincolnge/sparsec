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
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        return state.next(self.pred)
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
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var re = state.next()
        switch re.status {
        case .Failed:
            switch re.value {
            case .Eof:
                return Result<ItemType, S>(value:Data.Eof, pos:state.pos, status:Status.Success)
            default:
                return Result<ItemType, S>(value: re.value, pos:state.pos, status: re.status)
            }
        default:
            var message = "Except EOF but \(re.value) at \(state.pos)"
            var f:Status = .Failed(message)
            return Result<ItemType, S>(value:re.value, pos:state.pos, status:f)
        }
    }
}

struct Digit: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props1<ItemType>.Pred = {(c:ItemType)->Bool in
        return digits.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        return state.next(pred)
    }
}

struct Letter: Parsec {
    typealias ItemType = UnicodeScalar
    typealias S = String.UnicodeScalarView
    var pred: Props1<ItemType>.Pred = {(c:ItemType)->Bool in
        return letters.longCharacterIsMember(c.value)
    }
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        return state.next(pred)
    }
}

typealias Char = One<String.UnicodeScalarView>

struct Text: Parsec {
    typealias ItemType = String.UnicodeScalarView
    typealias S = String.UnicodeScalarView
    var value:ItemType
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        for idx in value.startIndex...value.endIndex {
            var re = state.next()
            switch re.status {
            case .Success:
                switch re.value {
                case let .Value(chr):
                    if chr != value[idx] {
                        return Result(value: Data.Value(nil), pos: state.pos, status: Status.Failed("Text \(value) mismatch."))
                    }
                default: //It means Eof
                    return Result(value: Data.Value(nil), pos: state.pos, status: Status.Failed("Text \(value) mismatch. Got Eof"))
                }
            default: //It means Eof or other error.
                return Result(value: Data.Value(nil), pos: state.pos, status: Status.Failed("Text \(value) mismatch. Got \(re)"))
            }
        }
        return Result<ItemType, S>(value: Data<ItemType>.Value(value), pos: state.pos, status: Status.Success)
    }
}

struct Return<E, S:CollectionType>:Parsec{
    typealias ItemType = E
    let value:ItemType?
    func walk(state: BasicState<S>) -> Result<E, S> {
        return Result<E, S>(value:Data.Value(value), pos: state.pos, status: Status.Success)
    }
}

struct ReturnData<E, S:CollectionType>:Parsec{
    typealias ItemType = E
    let data:Data<ItemType>
    func walk(state: BasicState<S>) -> Result<E, S> {
        return Result<E, S>(value:data, pos: state.pos, status: Status.Success)
    }
}

struct Fail<E, S:CollectionType>:Parsec {
    typealias ItemType = E
    let value:ItemType?
    let message:String?
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        return Result<ItemType, S>(value:Data.Value(value), pos: state.pos, status: Status.Failed(message))
    }
}


