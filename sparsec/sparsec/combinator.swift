//
//  combinator.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/16.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

struct Try<S:CollectionType, P:Parsec where P.S==S>:Parsec {
    typealias ItemType=P.ItemType
    let parsec: P
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var p = state.pos
        var re = self.parsec.walk(state)
        switch re.status {
        case .Failed:
            state.pos = p
            return re
        default:
            return re
        }
    }
}

struct Either<S:CollectionType, L:Parsec, R:Parsec
                where R.S==S, L.S==S, L.ItemType==R.ItemType>:Parsec {
    typealias ItemType=L.ItemType
    let left:L
    let right:R
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var p = state.pos
        var re = self.left.walk(state)
        switch re.status {
        case .Success:
            return re
        default:
            if state.pos == p {
                return self.right.walk(state)
            } else {
                return re
            }
        }
    }
}

infix operator <|> { associativity left }
func <|><S:CollectionType, L:Parsec, R:Parsec where L.S==S, R.S==S, L.ItemType==R.ItemType>(left: L, right: R)  -> Either<S, L, R> {
    return Either<S, L, R>(left: left, right: right)
}

struct Otherwise<S:CollectionType, P:Parsec where P.S==S>:Parsec {
    typealias ItemType=P.ItemType
    let parsec:P
    let message:String
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var re:Result<ItemType, S> = self.parsec.walk(state)
        switch re.status {
        case .Success:
            return re
        default:
            return Result<ItemType, S>(value:re.value, pos:state.pos, status:Status.Failed(message))
        }
    }
}

infix operator <?> { associativity left }
func <?><S:CollectionType, P:Parsec where P.S==S>(parsec: P, message: String)  -> Otherwise<S, P> {
    return Otherwise<S, P>(parsec:parsec, message:message)
}

struct Option<P:Parsec, S:CollectionType where P.S==S>:Parsec {
    typealias ItemType=P.ItemType
    let value:ItemType?
    let parsec:P
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        return Either(left: parsec, right: Return(value: value)).walk(state)
    }
}

struct OneOf<ItemType:Equatable, C:CollectionType, S:CollectionType
        where S.Generator.Element==ItemType, C.Generator.Element==ItemType>: Parsec {
    let elements:C
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var re = state.next()
        switch re.status {
        case .Success:
            switch re.value {
            case let .Value(value):
                for e in elements {
                    if e == value {
                        return Result<ItemType, S>(value: Data.Value(value), pos: state.pos, status: Status.Success)
                    }
                }
                return Result<ItemType, S>(value:Data.Value(nil), pos: state.pos, status: Status.Failed("OneOf failed: None match"))
            default:
                return Result<ItemType, S>(value: Data.Eof, pos: state.pos, status: Status.Failed("Eof"))
            }
        default:
            return Result<ItemType, S>(value: Data.Eof, pos: state.pos, status: Status.Failed("Eof"))
        }
    }
}

struct NoneOf<ItemType:Equatable, C:CollectionType, S:CollectionType
        where C.Generator.Element==ItemType, S.Generator.Element==ItemType>:Parsec {
    let elements:C
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var re = state.next()
        switch re.status {
        case .Success:
            switch re.value {
            case var .Value(value):
                for e in elements {
                    if e == value {
                        var message = "Except None match but found \(e)"
                        return Result<ItemType, S>(value: Data.Value(value), pos: state.pos, status: Status.Failed(message))
                    }
                }
                return Result<ItemType, S>(value:Data.Value(nil), pos: state.pos, status: Status.Success)
            default:
                return Result<ItemType, S>(value: Data.Eof, pos: state.pos, status: Status.Failed("Eof"))
            }
        default:
            return Result<ItemType, S>(value: Data.Eof, pos: state.pos, status: Status.Failed("Eof"))
        }
    }
}

struct Bind<Pre:Parsec, P:Parsec, S:CollectionType where Pre.S==S, P.S==S>:Parsec{
    typealias Binder = (Data<Pre.ItemType>)->P
    typealias ItemType=P.ItemType
    let prefix: Pre
    let binder: Binder
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var re = self.prefix.walk(state)
        switch re.status {
        case .Success:
            var postfix = self.binder(re.value)
            return postfix.walk(state)
        default:
            return Result<ItemType, S>(value: Data<ItemType>.Value(nil), pos: re.pos, status: re.status)
        }
    }
}

struct Bind_<Pre:Parsec, P:Parsec, S:CollectionType where Pre.S==S, P.S==S>:Parsec{
    typealias ItemType = P.ItemType
    let prefix: Pre
    let parsec: P
    func walk(state: BasicState<S>) -> Result<ItemType, S> {
        var re = self.prefix.walk(state)
        switch re.status {
        case .Success:
            return parsec.walk(state)
        default:
            return Result<ItemType, S>(value: Data<ItemType>.Value(nil), pos: re.pos, status: re.status)
        }
    }
}

struct Between<B:Parsec, E:Parsec, P:Parsec, S:CollectionType
    where B.S==S, E.S==S, P.S==S> :Parsec{
    typealias ItemType = P.ItemType
    typealias ResultType = Result<ItemType, S>
    typealias ReturnType = ReturnData<ItemType, S>
    let begin:B
    let end:E
    let parsec:P
    func walk(state: BasicState<S>) -> ResultType {
        var keep = {(data:Data<ItemType>)->Bind_<E, ReturnType, S> in
            return Bind_(prefix:self.end, parsec:ReturnData(data: data))
        }
        return Bind_(prefix:begin, parsec:Bind(prefix:parsec, binder:keep)).walk(state)
    }
}