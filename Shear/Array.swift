//
//  Array.swift
//  Sheep
//
//  Created by Andrew Snow on 6/14/15.
//  Copyright © 2015 Andrew Snow. All rights reserved.
//

import Foundation

public protocol Array {
    
    // MARK: - Associated Types
    
    /// The type of element stored by this `Array`.
    typealias Element
    
    //    /// A collection of `Elements` that constitute an `Array`.
    //    typealias ElementsView = CollectionType // TODO: Not as typesafe as I'd like as there's no typecheck that `ElementsView` generates `Elements`
    
    // MARK: - Initializers
    
//    init(shape newShape: [Int], repeatedValue: Element)
//    init(shape newShape: [Int], baseArray: [Element])
//    init<A: Array where A.Element == Element>(shape newShape: [Int], baseArray: A)
    
    // MARK: - Properties
    
    /// The shape (lenght in each demision) of this `Array`.
    /// e.g. 
    ///     If the Array represents a 3 by 4 matrix, its shape is [3, 4]
    ///     If the Array is a column vector of 5 elements, its shape is [5, 1]
    ///     If the Array is a row vector of 6 elements, its shape is [1, 6]
    var shape: [Int] { get }
    
    /// The number of non-unitary demensions of this Array or zero for the Empty Array.
    /// e.g.
    ///     If the Array represents a 3 by 4 matrix, its shape is 2
    ///     If the Array is a column vector of 5 elements, its shape is 1
    ///     If the Array is a row vector of 6 elements, its shape is 1
    ///     If the Array is the Empty Array, its shape is 0
    var rank: Int { get }
    
    /// A view that provides a `CollectionType` over all the items stored in the array.
    /// The first element is at the all-zeros index of the array.
    var allElements: AnyForwardCollection<Element> { get } // TODO: Consider renaming "elementsView" "flatView" "linearView", something else that makes it clear you lose the position information
    // TODO: we'd prefer the type of allEmements to be a contrainted CollectionType but I'm not sure this currently possible with Swift's typesystem see ElementsView
    // TODO: we want an enumerate()-like function to return ([index], element) pairs
    
    // MARK: - Methods
    
//    func sequence<A: Array, C: CollectionType where C.Generator.Element == A, A.Element == Element>(dimension: Int) -> C
    
    subscript(indices: Int...) -> Element { get set }

//    subscript(indices: ArrayIndex...) -> AnyArray<Element> { get }
}

/// A type-erased `Array` over `Element` elements.
/// We use this to work around some type system limitations brought by associated types.
public struct AnyArray<Element> {

}

public extension Array {

    /// The number of non-unitary demensions of this Array.
    var rank: Int {
        get {
            if isEmpty { return 0 }
            
            return shape.filter {$0 != 1}.count
        }
    }
    
    var isEmpty: Bool {
        return shape.filter {$0 == 0}.count > 0
    }

    var isScalar: Bool {
        return !isEmpty && rank == 0
    }
    
    var isVector: Bool {
        return rank == 1
    }
    
    var isRowVector: Bool {
        return isVector && shape.count == 2 && shape[0] == 1
    }
    
    var isColumnVector: Bool {
        return isVector && shape.count == 2 && shape[1] == 1
    }
    
    var scalarValue: Element? {
        guard isScalar else { return nil }
        
        return allElements.first
    }

}

public extension Array {
    
    // The length of the Array in a particular dimension
    func size(d: Int) -> Int {
        return d < shape.count ? shape[d] : 1
    }
    
    // The length of the Array in several dimensions
    func size(ds: Int...) -> [Int] {
        return ds.map(size)
    }
    
}