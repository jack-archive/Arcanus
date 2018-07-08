// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import HeliumLogger
import LoggerAPI

// TODO: Make this support more than one output
private struct LogFile: TextOutputStream {
    var file: FileHandle

    init(_ argPath: String? = nil) throws {
        var path: String
        if argPath == nil {
            path = "log.log"
        } else {
            path = argPath!
        }

        if !FileManager.default.fileExists(atPath: path) {
            try "Opening \(path) for Logging\n".write(toFile: path, atomically: true, encoding: .utf8)
        }
        guard let fh = FileHandle(forWritingAtPath: path) else {
            throw ArcanusError.badPath
        }
        self.file = fh
        self.file.seekToEndOfFile()
    }

    mutating func write(_ string: String) {
        do {
            guard let data = string.data(using: .utf8) else {
                throw ArcanusError.failedToConvertData
            }
            self.file.write(data)
        } catch {
            // Ignore Error
        }
    }
}

public class ArcanusLog {
    public class func setLogFile(_ path: String, minLevel: LoggerMessageType = .verbose) throws {
        Log.logger = HeliumStreamLogger(minLevel, outputStream: try LogFile(path))
    }

    public class func setConsole(minLevel: LoggerMessageType = .verbose) {
        HeliumLogger.use(minLevel)
    }
}
