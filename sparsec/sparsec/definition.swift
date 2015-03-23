//
//  utils.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/10.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation



struct Props1<T> {
    typealias Pred = (T)->Bool
}

struct Props2<P, Q> {
    typealias Binder = (P)->Q
}

func unbox<T>(box:[T?], trust:Bool=false)->[T] {
    var re:[T] = []
    if trust {
        for e in box {
            re.append(e!)
        }
    } else {
        for e in box {
            if e != nil {
                re.append(e!)
            }
        }
    }
    return re
}

extension String: CollectionType {}

extension String.UnicodeScalarView:CollectionType{}


