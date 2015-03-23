//
//  atom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

func equals<T:Equatable>(a:T)->Props1<T>.Pred{
    return {(x:T)->Bool in
        return a==x
    }
}

func one<ItemType:Equatable, S:CollectionType where S.Generator.Element==ItemType>(one: ItemType)->Parsec<ItemType, S>.Parser{
    var pred = equals(one)
    return {(state: BasicState<S>)->(ItemType?, ParsecStatus) in
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

func subject<ItemType:Equatable, S:CollectionType where S.Generator.Element==ItemType >
        (one: ItemType, curry:(ItemType)->(ItemType)->Bool)->Parsec<ItemType, S>.Parser {
    var pred:(ItemType)->Bool = curry(one)
    return {(state: BasicState<S>)->(ItemType?, ParsecStatus) in
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

func eof<ItemType, S:CollectionType where S.Generator.Element==ItemType>(state: BasicState<S>)->(ItemType?, ParsecStatus){
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

func pack<ItemType, S:CollectionType>(value:ItemType?)->Parsec<ItemType, S>.Parser {
    return {(state:BasicState)->(ItemType?, ParsecStatus) in
        return (value, ParsecStatus.Success)
    }
}

func fail<ItemType, S:CollectionType>(message:String)->Parsec<ItemType, S>.Parser {
    return {(state:BasicState)->(ItemType?, ParsecStatus) in
        return (nil, ParsecStatus.Failed(message))
    }
}




