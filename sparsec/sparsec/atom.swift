//
//  atom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func equals<T:Equatable>(a:T)->Equal<T>.Pred{
    return {(x:T)->Bool in
        return a==x
    }
}

func one<T:Equatable, S:CollectionType where S.Generator.Element==T>(one: T)->Parsec<T, S>.Parser{
    var pred = equals(one)
    return {(state: BasicState<S>)->(T?, ParsecStatus) in
        var re = state.next(pred)
        switch re {
        case .Success:
            return (one, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) missmatch."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) Eof."))
        }
    }
}

func subject<T:Equatable, S:CollectionType where S.Generator.Element==T >
        (one: T, curry:(T)->(T)->Bool)->Parsec<T, S>.Parser {
    var pred:(T)->Bool = curry(one)
    return {(state: BasicState<S>)->(T?, ParsecStatus) in
        var re = state.next(pred)
        switch re {
        case .Success:
            return (one, ParsecStatus.Success)
        case .Failed:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) missmatch."))
        case .Eof:
            return (nil, ParsecStatus.Failed("Except \(one) but \(state[state.pos]) Eof."))
        }
    }
}

func eof<T, S:CollectionType where S.Generator.Element==T>(state: BasicState<S>)->(T?, ParsecStatus){
    var item = state.next()
    if item == nil {
        return (nil, ParsecStatus.Success)
    } else {
        return (item, ParsecStatus.Failed("Except Eof but \(item)"))
    }
}

func text(value:String)->Parsec<String, String.UnicodeScalarView>.Parser {
    return {(state: BasicState<String.UnicodeScalarView>)->(String?, ParsecStatus) in
        var scalars = value.unicodeScalars
        for idx in scalars.startIndex...scalars.endIndex {
            var re = state.next()
            if re == nil {
                return (nil, ParsecStatus.Failed("Except Text \(value) but Eof"))
            } else {
                var rune = re!
                if rune != scalars[idx] {
                    return (nil, ParsecStatus.Failed("Text[\(idx)]:\(scalars[idx]) not match Data[\(state.pos)]:\(rune)"))
                }
            }
        }
        return (value, ParsecStatus.Success)
    }
}

func pack<T, S:CollectionType>(value:T?)->Parsec<T, S>.Parser {
    return {(state:BasicState)->(T?, ParsecStatus) in
        return (value, ParsecStatus.Success)
    }
}

func fail<T, S:CollectionType>(message:String)->Parsec<T, S>.Parser {
    return {(state:BasicState)->(T?, ParsecStatus) in
        return (nil, ParsecStatus.Failed(message))
    }
}




