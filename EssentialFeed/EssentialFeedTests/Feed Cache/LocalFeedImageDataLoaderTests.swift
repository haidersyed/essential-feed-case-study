//	
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
	typealias Result = Swift.Result<Data?, Error>

	func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader : FeedImageDataLoader {
	
	private struct Task: FeedImageDataLoaderTask {
		func cancel() {}
	}
	
	public enum Error: Swift.Error {
		case failed
	}

	private let store: FeedImageDataStore

	init(store: FeedImageDataStore) {
		self.store = store
	}

	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		store.retrieve(dataForURL: url) { result in
			completion(.failure(Error.failed))
		}
		return Task()
	}
}

class LocalFeedImageDataLoaderTests: XCTestCase {

	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertTrue(store.receivedMessages.isEmpty)
	}

	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
		let store = StoreSpy()
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private class StoreSpy:FeedImageDataStore {
		enum Message: Equatable {
			case retrieve(dataFor: URL)
		}
		
		private var completions = [(FeedImageDataStore.Result) -> Void]()
		private(set) var receivedMessages = [Message]()

		func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
			receivedMessages.append(.retrieve(dataFor: url))
			completions.append(completion)
		}
	}

}
