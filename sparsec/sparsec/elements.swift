//
//  utils.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

enum Status{
    case Success
    case Failed(String?)
}

enum Data<T>{
    case Value(T?)
    case Eof
}

struct Result<E, S:CollectionType> {
    let value : Data<E>
    let pos : S.Index?
    let status: Status
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
    typealias ItemType = S.Generator.Element
    func walk (state: BasicState<S>) -> Result<ItemType, S>
}

