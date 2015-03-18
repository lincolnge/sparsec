//
//  state.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/9.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Foundation

class BasicState<S:CollectionType> {
    typealias ItemType = S.Generator.Element
    var container: S
    var _pos : S.Index
    init(_ container: S) {
        self.container = container
        _pos = container.startIndex
    }
    var pos : S.Index { get {
            return _pos
        }
        set(index){
            _pos = index
        }
    }

    func next() -> ItemType? {
        if self.pos == self.container.endIndex.successor() {
            return nil
        }
        var item = container[self.pos]
        self.pos = self.pos.successor()
        return item
    }

    func next(pred : Props1<ItemType>.Pred) -> PredResult<ItemType> {
        if self.pos == self.container.endIndex.successor() {
            return PredResult<ItemType>.Eof
        }
        var item = container[self.pos]
        self.pos = self.pos.successor()
        var match = pred(item)
        if match {
            self.pos.successor()
            return PredResult.Success(item)
        }
        return PredResult.Failed
    }
    subscript(idx: S.Index) -> ItemType? {
        get {
            return container[idx]
        }
    }
}

class LinesState<S:CollectionType where S.Index: IntegerArithmeticType>:
        BasicState<S> {
    typealias ItemType = S.Generator.Element
    var newline:Props1<ItemType>.Pred
    var lines:[S.Index] = []
    var row, col : S.Index
    var line: S.Index {
        get {
            return row
        }
    }
    var column: S.Index {
        get {
            return col
        }
    }
    init(_ container: S, newline: Props1<ItemType>.Pred){
        self.newline = newline
        self.row = container.startIndex
        self.col = container.startIndex
        for index in container.startIndex ... container.endIndex {
            var item = container[index]
            if newline(item) {
                self.lines.append(index)
            }
        }
        super.init(container)
    }
    override var pos:S.Index {
        get {
            return _pos
        }
        set(p) {
            assert((self.container.startIndex<=p) && (pos<=self.container.endIndex))
            _pos = pos
            var top = self.lines.endIndex
            for idx in self.lines.startIndex ... self.lines.endIndex {
                var start = self.lines[idx]
                var row = top - idx
                if start < _pos {
                    row = row + 2
                    col = pos - start
                    return
                }
            }
        }
    }
}

