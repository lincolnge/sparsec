//
//  utils.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

enum PredResult<T>{
    case Success(T)
    case Failed
    case Eof
}

enum ParsecStatus{
    case Success
    case Failed(String)
}

struct Props1<T> {
    typealias Pred = (T)->Bool
}

struct Props2<P, Q> {
    typealias Binder = (P)->Q
}

extension String: CollectionType {}

extension String.UnicodeScalarView:CollectionType{}

protocol Parsec {
    typealias S:CollectionType
    typealias ItemType
    func walk (state: BasicState<S>) -> (ItemType?, ParsecStatus)
}

