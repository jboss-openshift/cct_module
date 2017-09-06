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
import re

from probe.api import Status, Test
from probe.jolokia import JolokiaProbe

class JdgProbe(JolokiaProbe):
    """
    JDG probe which uses the Jolokia interface to query server state (i.e.
    RESTful JMX queries).  It defines tests for cache status, join status and
    state transfer state for all caches.  Note, some of these are not
    accessible via DMR in JDG 6.5.
    """

    def __init__(self):
        super(JdgProbe, self).__init__(
            [
                CacheStatusTest(),
                JoinStatusTest(),
                StateTransferStateTest(),
                CacheManagerTest()
            ]
        )

__nameGrabber = re.compile(r'.*name="([^"]*)"')
def getName(text):
    return __nameGrabber.match(text).group(1)

class CacheStatusTest(Test):
    """
    Checks the cache statuses.
    """

    def __init__(self):
        super(CacheStatusTest, self).__init__(
            {
                "type": "read",
                "attribute": "cacheStatus",
                "mbean": "jboss.datagrid-infinispan:type=Cache,name=*,manager=\"clustered\",component=Cache"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for "RUNNING"
            NOT_READY for INITIALIZING OR INSTANTIATED
            HARD_FAILURE for FAILED
            FAILURE if the query itself failed, or all other states (STOPPING or TERMINATED)
        """

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

        if not results["value"]:
            return (Status.READY, "No caches")

        status = set()
        messages = {}
        for key, value in results["value"].items():
            cacheStatus = value["cacheStatus"]
            messages[getName(key)] = cacheStatus
            if cacheStatus == "RUNNING":
                status.add(Status.READY)
            elif cacheStatus == "FAILED":
                status.add(Status.HARD_FAILURE)
            elif cacheStatus == "INITIALIZING":
                status.add(Status.NOT_READY)
            elif cacheStatus == "INSTANTIATED":
                status.add(Status.NOT_READY)
            else:
                status.add(Status.FAILURE)
        return (min(status), messages)

class CacheManagerTest(Test):
    """
    Checks that all defined caches are running.
    """

    def __init__(self):
        super(CacheManagerTest, self).__init__(
            {
                "type": "read",
                "attribute": [ "definedCacheCount", "createdCacheCount", "runningCacheCount" ],
                "mbean": "jboss.datagrid-infinispan:type=CacheManager,name=\"clustered\",component=CacheManager"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for definedCacheCount = createdCacheCount = runningCacheCount
            NOT_READY for definedCacheCount > createdCacheCount 
            FAILURE for definedCacheCount = createdCacheCount > runningCacheCount
            FAILURE if the query itself failed, or all other states (STOPPING or TERMINATED)
        """

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

	if not results["value"]:
            return (Status.FAILURE, "No CacheManager attributes")

        status = set()
        messages = {}
        messages["results"] = results["value"]
        for key, value in results["value"].items():
            if key == "createdCacheCount":
		createdCacheCount = value
		messages["createdCacheCount"] = createdCacheCount
	    elif key == "definedCacheCount":
		definedCacheCount = value
		messages["definedCacheCount"] = definedCacheCount
	    elif key == "runningCacheCount":
		runningCacheCount = value
		messages["runningCacheCount"] = runningCacheCount
  
        if runningCacheCount == 0:
	    status.add(Status.NOT_READY)
        elif createdCacheCount == runningCacheCount:
            status.add(Status.READY)
        else:
            status.add(Status.FAILURE)
 
        return (min(status), messages)

class JoinStatusTest(Test):
    """
    Checks the join status of the caches.
    """

    def __init__(self):
        super(JoinStatusTest, self).__init__(
            {
                "type": "read",
                "attribute": "joinComplete",
                "mbean": "jboss.datagrid-infinispan:type=Cache,name=*,manager=\"clustered\",component=StateTransferManager"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if all caches have joined the cluster
            NOT_READY if any caches have not joined the cluster
            FAILURE if the query itself failed
        """

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

        if not results["value"]:
            return (Status.READY, "No caches")

        status = set()
        messages = {}
        for key, value in results["value"].items():
            joinComplete = value["joinComplete"]
            messages[getName(key)] = "JOINED" if joinComplete else "NOT_JOINED"
            if joinComplete:
                status.add(Status.READY)
            else:
                status.add(Status.NOT_READY)
        return (min(status), messages)

class StateTransferStateTest(Test):
    """
    Checks whether or not a state transfer is in progress (only initial state transfer).
    """

    def __init__(self):
        super(StateTransferStateTest, self).__init__(
            {
                "type": "read",
                "attribute": "stateTransferInProgress",
                "mbean": "jboss.datagrid-infinispan:type=Cache,name=*,manager=\"clustered\",component=StateTransferManager"
            }
        )
        self.stateTransferMarker = os.path.join(os.getenv("JBOSS_HOME", "/tmp"), "InitialStateTransferComplete.marker")

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if no state transfer is in progress or the marker file exists
            NOT_READY if state transfer is in progress and marker file does not exist
        """

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

        if not results["value"]:
            return (Status.READY, "No caches")

        status = set()
        messages = {}
        for key, value in results["value"].items():
            stateTransferInProgress = value["stateTransferInProgress"]
            messages[getName(key)] = "IN_PROGRESS" if stateTransferInProgress else "COMPLETE"
            if stateTransferInProgress:
                status.add(Status.NOT_READY)
            else:
                status.add(Status.READY)
        if os.path.exists(self.stateTransferMarker):
            return (Status.READY, messages)
        else:
            status = min(status)
            if status is Status.READY:
                # create the marker file
                try:
                    open(self.stateTransferMarker, 'a').close()
                except:
                    # worst case we try again next time or go offline when a
                    # state transfer is initiated
                    pass
        return (status, messages)

