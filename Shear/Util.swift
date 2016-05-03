// Copyright 2016 The Shear Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import Foundation

/// Calculate the stride vector for indexing into the base array
let calculateStride = calculateStrideRowMajor

/// Stride for column-major ordering (first dimension on n-arrays)
private func calculateStrideColumnMajor(shape: [Int]) -> [Int] {
    var stride = shape.scan(1, combine: *)
    stride.removeLast()
    return stride
}

/// Stride for row-major ordering (last dimension on n-arrays)
private func calculateStrideRowMajor(shape: [Int]) -> [Int] {
    var stride = shape.reverse().scan(1, combine: *)
    stride.removeLast()
    return stride.reverse()
}

/// N.B. Does NOT check resulting indices are in bounds.
func convertIndices(linear index: Int, stride: [Int]) -> [Int] {
    var index = index
    return stride.map { s in
        let i: Int
        (i, index) = (index / s, index % s)
        return i
    }
}

/// N.B. Does NOT check resulting index is in bounds.
func convertIndices(cartesian indices: [Int], stride: [Int]) -> Int {
    return zip(indices, stride).map(*).reduce(0, combine: +)
}

/// Returns true iff the indicies are within bounds of the given shape.
func checkBounds(indices: [Int], forShape shape: [Int]) -> Bool {
    return indices.count == shape.count &&
        !zip(indices, shape).contains { !checkBounds($0, forCount: $1) }
}

/// Returns true iff the index is within the bounds of a given count.
func checkBounds(index: Int, forCount count: Int) -> Bool {
    return 0 ..< count ~= index
}

/// Returns a shape define in terms of it's non-unitary dimensions, if given an otherwise valid shape. Otherwise returns nil.
func checkAndReduce(shape: [Int]) -> [Int]? {
    guard !shape.contains({ $0 < 1 }) else { return nil }
    return shape.filter { $0 > 1 }
}
