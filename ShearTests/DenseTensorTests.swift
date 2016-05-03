// Copyright 2016 The Shear Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import XCTest
import Shear

class DenseTensorTests: XCTestCase {
    
    let iotaVec = iota(8)
    let iotaSq = iota(16).reshape([4, 4])
    let iotaCube = iota(27).reshape([3, 3, 3])
    let vEvens = iota(4) * 2
    let vOdds = iota(4) * 2 + 1
    let FiveFactorial = iota(120).reshape([1, 2, 3, 1, 4, 5, 1, 1])
    let Scalar = iota(1)
    
    var allTensors: [DenseTensor<Int>] = []
    
    override func setUp() {
        super.setUp()
        allTensors = [iotaVec, iotaSq, iotaCube, vEvens, vOdds, FiveFactorial, Scalar].map { DenseTensor($0) }
    }
    
    func testInits() {
        let aLonelyNumber = DenseTensor(shape: [], repeatedValue: 1)
        XCTAssert(aLonelyNumber.shape.isEmpty)
        XCTAssert(aLonelyNumber[[] as [Int]] == 1)
        XCTAssert(aLonelyNumber.isScalar)
        XCTAssert(aLonelyNumber.scalar! == 1)
        
        let eight = DenseTensor(shape: [1, 2, 4, 11], repeatedValue: "8")
        XCTAssert(eight.shape == [2, 4, 11])
        eight.allElements.forEach {
            XCTAssert($0 == "8")
        }
        
        let reshape = DenseTensor(shape: [1, 11, 1, 8, 1], baseTensor: eight)
        XCTAssert(reshape.shape == [11, 8])
        reshape.allElements.forEach {
            XCTAssert($0 == "8")
        }
        
        let slice = Shear.Tensor(eight)
        let rereshape = DenseTensor(shape: [1, 11, 1, 8, 1], baseTensor: slice)
        XCTAssert(rereshape.shape == [11, 8])
        rereshape.allElements.forEach {
            XCTAssert($0 == "8")
        }
        
        let collated = DenseTensor(collection: slice.sequenceFirst)
        XCTAssert(collated.shape == [2, 4, 11])
        collated.allElements.forEach {
            XCTAssert($0 == "8")
        }
        
        let recollated = DenseTensor(collectionOnLastAxis: slice.sequence(1))
        XCTAssert(recollated.shape == [2, 11, 4])
        recollated.allElements.forEach {
            XCTAssert($0 == "8")
        }
    }
    
    func testShape() {
        let correctBehavior = [
            [8],
            [4, 4],
            [3, 3, 3],
            [4],
            [4],
            [2, 3, 4, 5],
            []
        ]
        
        zip(allTensors, correctBehavior).forEach {
            XCTAssertEqual($0.0.shape, $0.1)
        }
    }
    
    func testAllElements() {
        let correctBehavior = [
            [Int](0..<8),
            [Int](0..<16),
            [Int](0..<27),
            [0, 2, 4, 6],
            [1, 3, 5, 7],
            [Int](0..<120),
            [0]
        ]
        
        zip(allTensors, correctBehavior).forEach {
            XCTAssertEqual($0.0.allElements.map { $0 }, $0.1)
        }
    }
    
    func testLinearIndexing() {
        let spotChecks = [0, 1, 2, 37, 28, 83, 118, 119]
        spotChecks.forEach {
            XCTAssertEqual(FiveFactorial[linear: $0], $0)
        }
    }
    
    func testLinearIndexAssignment() {
        var eight = DenseTensor(shape: [1, 2, 4, 11], repeatedValue: "8")
        XCTAssert(eight[linear: 55] == "8")
        eight[linear: 55] = "55"
        XCTAssert(eight[linear: 55] == "55")
    }
    
    func testScalarIndexing() {
        let spotChecks = [
            [([0], 0), ([4], 4)],
            [([2, 1], 9)],
            [([2, 2, 2], 26)],
            [],
            [],
            [([0, 1, 2, 3], 33)],
            [([], 0)]
        ]
        
        zip(allTensors, spotChecks).forEach { (array, checks) in
            checks.forEach { (indices, value) in
                XCTAssertEqual(array[indices], value)
            }
        }
    }
    
    func testScalarIndexAssignment() {
        var eight = DenseTensor(shape: [1, 2, 4, 11], repeatedValue: "8")
        XCTAssert(eight[0, 2, 5] == "8")
        eight[0, 2, 5] = "025"
        XCTAssert(eight[0, 2, 5] == "025")
    }
    
    // MARK: - Slicing
    
    func testSliceIndexingFull() {
        let testVec = allTensors.map { $0.shape.map { _ in $ } }
        
        zip(allTensors, testVec).forEach { (array, indices) in
            XCTAssert(array[indices] == array)
        }
    }
    
    func testSliceIndexingSingular() {
        // First value
        let testVec = allTensors.map { $0.shape.map { _ in TensorIndex.SingleValue(0) } }
        
        zip(allTensors, testVec).forEach { (array, indices) in
            XCTAssert(Array(array[indices].allElements) == [array.allElements.first!])
        }
        
        // Last value
        let testVec2 = allTensors.map { $0.shape.map { count in TensorIndex.SingleValue(count - 1) } }
        
        zip(allTensors, testVec2).forEach { (array, indices) in
            XCTAssert(Array(array[indices].allElements) == [array.allElements.last!])
        }
        
        
        let randish = 893746573 // Arbitrary value that won't change between test runs.
        let indices = allTensors.map { $0.shape.map { count in randish % count } }
        let testVec3 = indices.map { $0.map { TensorIndex.SingleValue($0) } }
        
        let values = zip(allTensors, indices).map { $0[$1] }
        let slices = zip(allTensors, testVec3).map { $0[$1] }
        
        zip(slices, values).forEach { (slice, value) in
            XCTAssert(slice.allElements.first! == value)
        }
    }
    
    func testSliceIndexingRange() {
        let testVec = [
            ([3..<8], (3, 7)),
            ([0...3, 2..<4], (2, 15)),
            ([0..<3, 1...1, 1...2], (4, 23)),
            ([0..<4], (0, 6)),
            ([1...2], (3, 5)),
            ([0..<2, 0...2, 2...3, 3..<4], (13, 118)),
            ([], (0, 0))
        ]
        
        zip(allTensors, testVec).forEach { (array, test) in
            let slice = array[test.0]
            XCTAssert(slice.allElements.first == test.1.0)
            XCTAssert(slice.allElements.last == test.1.1)
        }
    }
    
    func testSliceIndexingList() {
        let testVec: [([TensorIndex], (Int, Int))] = [
            ([[7, 3]], (7, 3)),
            ([[0, 3], [2, 3]], (2, 15)),
            ([[2, 1, 0], [1], [2, 1]], (23, 4)),
            ([[0, 1, 3]], (0, 6)),
            ([[1, 2]], (3, 5)),
            ([[0, 1], [0, 2], [2, 3], [3]], (13, 118)),
            ([], (0, 0))
        ]
        
        zip(allTensors, testVec).forEach { (array, test) in
            let slice = array[test.0]
            XCTAssert(slice.allElements.first == test.1.0)
            XCTAssert(slice.allElements.last == test.1.1)
        }
    }
    
}