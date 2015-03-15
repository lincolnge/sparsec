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

struct Result<T> {
    let value : Data<T>
    let status: Status
}

enum Exception {
    case Failed(String)
    case Eof
}

struct Props<T> {
    typealias Pred = (T)->Bool
}

extension String: CollectionType {}

extension String.UnicodeScalarView:CollectionType{}

protocol Parsec {
    typealias S:CollectionType
    typealias ItemType = S.Generator.Element
    func walk (state: BasicState<S>) -> Result<ItemType>
}

