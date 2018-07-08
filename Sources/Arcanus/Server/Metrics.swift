// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Kitura
import LoggerAPI
import SwiftMetrics
import SwiftMetricsDash
import SwiftMetricsPrometheus

var swiftMetrics: SwiftMetrics?
var swiftMetricsDash: SwiftMetricsDash?
var swiftMetricsPrometheus: SwiftMetricsPrometheus?

func initializeMetrics(router: Router) {
    do {
        let metrics = try SwiftMetrics()
        let dashboard = try SwiftMetricsDash(swiftMetricsInstance: metrics, endpoint: router)
        let prometheus = try SwiftMetricsPrometheus(swiftMetricsInstance: metrics, endpoint: router)

        swiftMetrics = metrics
        swiftMetricsDash = dashboard
        swiftMetricsPrometheus = prometheus
        Log.info("Initialized metrics.")
    } catch {
        Log.warning("Failed to initialize metrics: \(error)")
    }
}
