//
//  DownloadMetaData.swift
//  Singer
//
//  Created by Daniel Gogozan on 09.11.2021.
//

import Foundation

struct MetaDataDownload {
    var downloadTask: URLSessionDownloadTask
    var sourceUrl: URL
    var destinationUrl: URL?
    var progress: ((Float) -> Void)
    var completion: ((URL) -> Void)
    var resumedData: Data?
}
