//
//  PatternMatch.swift
//  JSONCoder
//
//  Created by kemchenj on 26/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

extension Optional where Wrapped: Equatable {
    static func ~=(lhs: Wrapped, rhs: Optional<Wrapped>) -> Bool {
        guard let rhs = rhs else { return false }
        return lhs ~= rhs
    }
}

extension RangeExpression {
    static func ~=(lhs: Self, rhs: Optional<Bound>) -> Bool {
        guard let rhs = rhs else { return false }
        return lhs ~= rhs
    }
}
