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
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var p = state.pos
        var (re, status) = self.parsec.walk(state)
        switch status {
        case .Failed:
            state.pos = p
            return (re, status)
        default:
            return (re, status)
        }
    }
}

struct Either<S:CollectionType, L:Parsec, R:Parsec
                where R.S==S, L.S==S, L.ItemType==R.ItemType>:Parsec {
    typealias ItemType=L.ItemType
    let left:L
    let right:R
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var p = state.pos
        var (re, status) = self.left.walk(state)
        switch status {
        case .Success:
            return (re, ParsecStatus.Success)
        default:
            if state.pos == p {
                return self.right.walk(state)
            } else {
                return (re, status)
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
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var (re, status) = self.parsec.walk(state)
        switch status {
        case .Success:
            return (re, status)
        default:
            return (nil, ParsecStatus.Failed(message))
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
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        return Either(left: parsec, right: Return(value: value)).walk(state)
    }
}

struct OneOf<ItemType:Equatable, C:CollectionType, S:CollectionType
        where S.Generator.Element==ItemType, C.Generator.Element==ItemType>: Parsec {
    let elements:C
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var re = state.next()
        if re == nil {
            return (nil, ParsecStatus.Failed("Except one of [\(elements)] but Eof"))
        }
        
        for e in elements {
            if e == re! {
                return (e, ParsecStatus.Success)
            }
        }
        return (nil, ParsecStatus.Failed("Missmatch any one of [\(elements)]."))
    }
}

struct NoneOf<ItemType:Equatable, C:CollectionType, S:CollectionType
        where C.Generator.Element==ItemType, S.Generator.Element==ItemType>:Parsec {
    let elements:C
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var re = state.next()
        if re == nil {
            return (nil, ParsecStatus.Failed("Try to check none of [\(elements)] but Eof"))
        }
        
        for e in elements {
            if e == re! {
                var message = "Except None match [\(elements)] but found \(e)"
                return (e, ParsecStatus.Failed(message))
            }
        }
        return (nil, ParsecStatus.Success)
    }
}

struct Bind<Pre:Parsec, P:Parsec, S:CollectionType where Pre.S==S, P.S==S>:Parsec{
    typealias ItemType=P.ItemType
    typealias Binder = (Pre.ItemType?)->P
    let prefix: Pre
    let binder: Binder
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var (re, status) = self.prefix.walk(state)
        switch status {
        case .Success:
            var postfix = self.binder(re)
            return postfix.walk(state)
        default:
            return (nil, status)
        }
    }
}

struct Bind_<Pre:Parsec, P:Parsec, S:CollectionType where Pre.S==S, P.S==S>:Parsec{
    typealias ItemType = P.ItemType
    let prefix: Pre
    let parsec: P
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var (re, status) = self.prefix.walk(state)
        switch status {
        case .Success:
            return parsec.walk(state)
        default:
            return (nil, status)
        }
    }
}

struct Between<B:Parsec, E:Parsec, P:Parsec, S:CollectionType
    where B.S==S, E.S==S, P.S==S> :Parsec{
    typealias ItemType = P.ItemType
    let begin:B
    let end:E
    let parsec:P

    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var keep = {(data:ItemType?)->Bind_<E, Return<ItemType, S>,  S> in
            return Bind_(prefix:self.end, parsec:Return(value:data))
        }
        return Bind_(prefix:begin, parsec:Bind(prefix:parsec, binder:keep)).walk(state)
    }
}

struct Many<P:Parsec, S:CollectionType where P.S==S>:Parsec {
    typealias ItemType=[P.ItemType?]
    let parsec:P
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        return Option(value: [], parsec:Many1<P, S>(parsec:self.parsec)).walk(state)
    }
}

struct Many1<P:Parsec, S:CollectionType where P.S==S>:Parsec {
    typealias ItemType=[P.ItemType?]
    let parsec:P
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var head = {(value:P.ItemType?) -> Bind<Many<P, S>, Return<ItemType, S>, S> in
            var tail = {(data:ItemType?)->Return<ItemType, S> in
                var val = data
                val!.append(value)
                return Return<ItemType, S>(value: val)
            }
            return Bind(prefix:Many(parsec: self.parsec), binder:tail)
        }
        return Bind(prefix: parsec, binder:head).walk(state)
    }
}

struct SepBy<P:Parsec, Sep:Parsec, S:CollectionType where P.S==S, Sep.S==S>:Parsec {
    typealias ItemType = [P.ItemType?]
    let parsec:P
    let sep:Sep
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        return Option(value: [], parsec: SepBy1<P, Sep, S>(parsec:parsec, sep:sep)).walk(state)
    }
}

struct SepBy1<P:Parsec, Sep:Parsec, S:CollectionType where P.S==S, Sep.S==S>:Parsec {
    typealias ItemType = [P.ItemType?]
    let parsec:P
    let sep:Sep
    func walk(state: BasicState<S>) -> (ItemType?, ParsecStatus) {
        var head = {(value: P.ItemType?)->Bind<Many<Bind_<Sep, P, S>, S>, Return<ItemType, S>, S> in
            var tail = {(data:ItemType?)->Return<ItemType, S> in
                var buf = data!
                buf.append(value)
                return Return<ItemType, S>(value: buf)
            }
            return Bind(prefix:Many(parsec:Bind_(prefix:self.sep, parsec:self.parsec)), binder:tail)
        }
        return Bind(prefix:parsec, binder:head).walk(state)
    }
}