//
//  axiom.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/22.
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

struct Parsec<T, S:CollectionType> {
    typealias Parser = (BasicState<S>)->(T?, ParsecStatus)
}

