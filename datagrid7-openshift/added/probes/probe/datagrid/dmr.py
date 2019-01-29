"""
Copyright 2017 Red Hat, Inc.

Red Hat licenses this file to you under the Apache License, version
2.0 (the "License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.
"""

import os

from probe.api import Status, Test
from probe.dmr import DmrProbe
from probe.eap.dmr import EapProbe

class DatagridProbe(EapProbe):
    """
    Basic EAP probe which uses the DMR interface to query server state.  It
    defines tests for server status, boot errors and deployment status.
    """

    def __init__(self):
        EapProbe.__init__(self)
        self.user = os.getenv('USERNAME')
        self.password = os.getenv('PASSWORD')
        self.addTest(CacheHealthTest())
        self.addTest(ClusterAvailabilityTest())
        self.addTest(ClusterHealthTest())
        
class CacheHealthTest(Test):
    """
    Checks the state of the cache health.
    """

    def __init__(self):
        super(CacheHealthTest, self).__init__(
            {
                "operation": "read-attribute",
                "address": [
                    {"subsystem": "datagrid-infinispan"},
                    {"cache-container": "clustered"},
 		    {"health": "HEALTH"}
                ],
                "name": "cache-health"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if all caches HEALTHY
            HARD_FAILURE if UNHEALTHY caches
            FAILURE if the query failed, but not FAILED
        """

        if results["outcome"] != "success":
            return (Status.FAILURE, "DMR query failed")

        if "UNHEALTHY" in results["result"]:
            return (Status.HARD_FAILURE, results["result"])

        if "HEALTHY" not in results["result"]:
            return (Status.HARD_FAILURE, results["result"])

        return (Status.READY, results["result"]) 

class ClusterAvailabilityTest(Test):
    """
    Checks cache cluster status
    """

    def __init__(self):
        super(ClusterAvailabilityTest, self).__init__(
            {
                "operation": "read-attribute",
                "address": {
                    "subsystem": "datagrid-infinispan",
                    "cache-container": "clustered"
                },
                "name": "cluster-availability"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if cluster is available
            FAILURE if Dmr query fails
            HARD_FAILURE if the cluster is not available
        """

        if results["outcome"] != "success":
            return (Status.FAILURE, "Dmr query failed")

        if results["result"] != "AVAILABLE":
            return (Status.HARD_FAILURE, results["result"])

        return (Status.READY, results["result"])

class ClusterHealthTest(Test):
    """
    Checks cache cluster health
    """

    def __init__(self):
        super(ClusterHealthTest, self).__init__(
            {
                "operation": "read-attribute",
                "address": [
                    {"subsystem": "datagrid-infinispan"},
                    {"cache-container": "clustered"},
                    {"health": "HEALTH"}
                ],
                "name": "cluster-health"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if all cluster is HEALTHY
            FAILURE if Dmr query fails
            HARD_FAILURE if the cluster is not HEALTHY
        """

        if results["outcome"] != "success":
            return (Status.FAILURE, "Dmr query failed")

        if results["result"] != "HEALTHY":
            return (Status.HARD_FAILURE, results["result"])

        return (Status.READY, results["result"])

