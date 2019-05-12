//
//  URLSession+Task.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

extension URLSession {
    
    func dataTask<T: Decodable>(with request: URLRequest, type: T.Type, completionHandler: @escaping (_ model: T?, _ error: Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else {
                    completionHandler(nil, nil)
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    func dataTask<T: Decodable>(with url: URL, type: T.Type, completionHandler: @escaping (_ model: T?, _ error: Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else {
                    completionHandler(nil, nil)
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}

// MARK: Progress support

extension URLSession {
    
    func startDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Progress {
        var progress: Progress?
        let task = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
        if #available(macOSApplicationExtension 10.13,
            iOSApplicationExtension 11.0,
            tvOSApplicationExtension 11.0,
            watchOSApplicationExtension 4.0, *) {
            return task.progress
        } else {
            progress = Progress(parent: Progress.current())
            progress!.totalUnitCount = 100
            progress!.cancellationHandler = task.cancel
            progress!.isPausable = true
            progress!.pausingHandler = task.suspend
            progress!.resumingHandler = task.resume
            return progress!
        }
    }
    
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Progress {
        var progress: Progress?
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        if #available(macOSApplicationExtension 10.13,
            iOSApplicationExtension 11.0,
            tvOSApplicationExtension 11.0,
            watchOSApplicationExtension 4.0, *) {
            return task.progress
        } else {
            progress = Progress(parent: Progress.current())
            progress!.totalUnitCount = 100
            progress!.cancellationHandler = task.cancel
            progress!.isPausable = true
            progress!.pausingHandler = task.suspend
            progress!.resumingHandler = task.resume
            return progress!
        }
    }
    
    func startDataTask<T: Decodable>(with request: URLRequest, type: T.Type, completionHandler: @escaping (_ model: T?, _ error: Error?) -> Void) -> Progress {
        var progress: Progress?
        let task = dataTask(with: request) { data, response, error in
            progress?.completedUnitCount = 100
            do {
                if let error = error { throw error }
                guard let data = data else {
                    completionHandler(nil, nil)
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        defer { task.resume() }
        if #available(macOSApplicationExtension 10.13,
            iOSApplicationExtension 11.0,
            tvOSApplicationExtension 11.0,
            watchOSApplicationExtension 4.0, *) {
            return task.progress
        } else {
            progress = Progress(parent: Progress.current())
            progress!.totalUnitCount = 100
            progress!.cancellationHandler = task.cancel
            progress!.isPausable = true
            progress!.pausingHandler = task.suspend
            progress!.resumingHandler = task.resume
            return progress!
        }
    }
    
    func startDataTask<T: Decodable>(with url: URL, type: T.Type, completionHandler: @escaping (_ model: T?, _ error: Error?) -> Void) -> Progress {
        var progress: Progress?
        let task = dataTask(with: url) { data, response, error in
            progress?.completedUnitCount = 100
            do {
                if let error = error { throw error }
                guard let data = data else {
                    completionHandler(nil, nil)
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        defer { task.resume() }
        if #available(macOSApplicationExtension 10.13,
            iOSApplicationExtension 11.0,
            tvOSApplicationExtension 11.0,
            watchOSApplicationExtension 4.0, *) {
            return task.progress
        } else {
            progress = Progress(parent: Progress.current())
            progress!.totalUnitCount = 100
            progress!.cancellationHandler = task.cancel
            progress!.isPausable = true
            progress!.pausingHandler = task.suspend
            progress!.resumingHandler = task.resume
            return progress!
        }
    }
}
