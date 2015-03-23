//
//  combinator.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/16.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func try<ItemType, S:CollectionType>(parsec: Parsec<ItemType, S>.Parser) -> Parsec<ItemType, S>.Parser {
    return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
        var p = state.pos
        var (re, status) = parsec(state)
        switch status {
        case .Failed:
            state.pos = p
            fallthrough
        default:
            return (re, status)
        }
    }
}

func either<ItemType, S:CollectionType>(x: Parsec<ItemType, S>.Parser, y: Parsec<ItemType, S>.Parser)
    -> Parsec<ItemType, S>.Parser {
        return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
            var p = state.pos
            var (re, status) = x(state)
            switch status {
            case .Success:
                return (re, ParsecStatus.Success)
            default:
                if state.pos == p {
                    return y(state)
                } else {
                    return (re, status)
                }
            }

        }
}

infix operator <|> { associativity left }
func <|><ItemType, S:CollectionType >(left: Parsec<ItemType, S>.Parser,
        right: Parsec<ItemType, S>.Parser)  -> Parsec<ItemType, S>.Parser {
    return either(left, right)
}

func otherwise<ItemType, S:CollectionType >(x:Parsec<ItemType, S>.Parser, message:String)->Parsec<ItemType, S>.Parser {
    return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
        var (re, status) = x(state)
        switch status {
        case .Success:
            return (re, status)
        default:
            return (nil, ParsecStatus.Failed(message))
        }
    }
}

infix operator <?> { associativity left }
func <?><ItemType, S:CollectionType>(x: Parsec<ItemType, S>.Parser, message: String)  -> Parsec<ItemType, S>.Parser {
    return otherwise(x, message)
}

func option<ItemType, S:CollectionType>(parsec:Parsec<ItemType, S>.Parser, value:ItemType?) -> Parsec<ItemType, S>.Parser {
    return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
        return either(parsec, pack(value))(state)
    }
}

func oneOf<ItemType:Equatable, C:CollectionType, S:CollectionType
    where S.Generator.Element==ItemType, C.Generator.Element==ItemType>(elements:C)->Parsec<ItemType, S>.Parser {
    return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
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

func noneOf<ItemType:Equatable, C:CollectionType, S:CollectionType
        where C.Generator.Element==ItemType, S.Generator.Element==ItemType>(elements:C)->Parsec<ItemType, S>.Parser {
    return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
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
        return (re, ParsecStatus.Success)
    }
}

func bind<ItemType, ReType, S:CollectionType >(x:Parsec<ItemType, S>.Parser,
        binder:(ItemType?)->Parsec<ReType, S>.Parser) -> Parsec<ReType, S>.Parser{
    return {(state: BasicState<S>) -> (ReType?, ParsecStatus) in
        var (re, status) = x(state)
        switch status {
        case .Success:
            var postfix = binder(re)
            return postfix(state)
        default:
            return (nil, status)
        }
    }
}

infix operator >>= { associativity left }
func >>=<ItemType, ReType, S:CollectionType>(x: Parsec<ItemType, S>.Parser, binder:(ItemType?)->Parsec<ReType, S>.Parser)  -> Parsec<ReType, S>.Parser {
    return bind(x, binder)
}

func bind_<ItemType, ReType, S:CollectionType >(x: Parsec<ItemType, S>.Parser,
        y:Parsec<ReType, S>.Parser)->Parsec<ReType, S>.Parser{
    return {(state: BasicState<S>) -> (ReType?, ParsecStatus) in
        var (re, status) = x(state)
        switch status {
        case .Success:
            return y(state)
        default:
            return (nil, status)
        }
    }
}
infix operator >> { associativity left }
func >><ItemType, ReType, S:CollectionType>(x: Parsec<ItemType, S>.Parser, y:Parsec<ReType, S>.Parser)  -> Parsec<ReType, S>.Parser {
    return x >> y
}

func between<ItemType, S:CollectionType>(b:Parsec<ItemType, S>.Parser,
        e:Parsec<ItemType, S>.Parser,
        p:Parsec<ItemType, S>.Parser)->Parsec<ItemType, S>.Parser{
    return {(state: BasicState<S>) -> (ItemType?, ParsecStatus) in
        var keep = {(data:ItemType?)->Parsec<ItemType, S>.Parser in
            return bind_(e, pack(data))
        }
        return (b >> (p>>=keep))(state)
    }
}

func many<ItemType, S:CollectionType >(p:Parsec<ItemType, S>.Parser) -> Parsec<[ItemType?], S>.Parser {
    return {(state: BasicState<S>) -> ([ItemType?]?, ParsecStatus) in
        return option(many1(p), [])(state)
    }
}

func many1<ItemType, S>(p: Parsec<ItemType, S>.Parser)->Parsec<[ItemType?], S>.Parser {
    return {(state: BasicState<S>) -> ([ItemType?]?, ParsecStatus) in
        var head = {(value:ItemType?) -> Parsec<[ItemType?], S>.Parser in
            var tail = {(data:[ItemType?]?)->Parsec<[ItemType?], S>.Parser in
                var buf = data
                buf!.append(value)
                return pack(buf)
            }
            return many(p) >>= tail
        }
        return (p >>= head)(state)
    }
}

func sepBy<ItemType, SepType, S:CollectionType>(p: Parsec<ItemType, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[ItemType?], S>.Parser {
    return  {(state: BasicState<S>) -> ([ItemType?]?, ParsecStatus) in
        return option(sepBy1(p, sep), [])(state)
    }
}

func sepBy1<ItemType, SepType, S:CollectionType>(p: Parsec<ItemType, S>.Parser,
        sep:Parsec<SepType, S>.Parser)->Parsec<[ItemType?], S>.Parser {
    return {(state: BasicState<S>) -> ([ItemType?]?, ParsecStatus) in
        var head = {(value: ItemType?)->Parsec<[ItemType?], S>.Parser in
            var tail = {(data:[ItemType?]?)->Parsec<[ItemType?], S>.Parser in
                var buf = data!
                buf.append(value)
                return pack(buf)
            }
            return (many(sep >> p) >>= tail)
        }
        return (p >>= head)(state)
    }
}