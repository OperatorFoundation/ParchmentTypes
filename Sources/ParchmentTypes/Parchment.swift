// Parchment mmaps a file to a [UInt64]. It can either mmap the whole file or any contiguous subset of the file.

import Foundation

import Chord
import Datable
import Gardener

public protocol Parchment: Sequence, Collection, MutableCollection, BidirectionalCollection, RandomAccessCollection
{
    static func create(_ url: URL, value: UInt64) throws -> any Parchment

    var fileSize: Int { get }

    init(_ url: URL, offsetUInt64: UInt64, sizeUInt64: UInt64?) throws

    func append(_ newElement: UInt64) throws
    func append(_ contentsOf: [UInt64]) throws
    func set(offset uint64Offset: UInt64, to uint64s: [UInt64]) throws
    func set(offset uint64Offset: UInt64, to uint64: UInt64) throws
    func get(offset uint64Offset: UInt64, length: UInt64) throws -> [UInt64]
    func get(offset uint64Offset: UInt64) throws -> UInt64
    func delete(offset uint64Offset: UInt64) throws
    func delete(offset uint64Offset: UInt64, length: UInt64) throws
    func compact() throws
}

public class ParchmentIterator<T>: IteratorProtocol where T: Parchment
{
    public typealias Element = UInt64

    let parchment: T
    var index: UInt64

    public init(_ parchment: T, _ index: UInt64)
    {
        self.parchment = parchment
        self.index = index
    }

    public func next() -> UInt64?
    {
        do
        {
            let result = try self.parchment.get(offset: self.index)
            self.index = self.index + 1
            return result
        }
        catch
        {
            return nil
        }
    }
}

public enum ParchmentError: Error
{
    case fileCouldNotBeCreated(URL)
    case noMmapFile
    case cannotAppend
    case fileDoesNotExist
    case fileSizeNotAligned(Int)
    case invalidSize(Int)
    case invalidOffset(UInt64)
    case fileExists
    case maxUInt64ValueNotAllowed
}
