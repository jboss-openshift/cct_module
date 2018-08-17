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

class EapProbe(JolokiaProbe):
    """
    Basic EAP probe which uses the Jolokia interface to query server state (i.e.
    RESTful JMX queries).  It defines tests for server status, boot errors and
    deployment status.
    """

    def __init__(self):
        super(EapProbe, self).__init__(
            [
                ServerStatusTest(),
                BootErrorsTest(),
                DeploymentTest(),
                HealthCheckTest()
            ]
        )

class ServerStatusTest(Test):
    """
    Checks the status of the server.
    """

    def __init__(self):
        super(ServerStatusTest, self).__init__(
            {
                "type": "read",
                "attribute": "serverState",
                "mbean": "jboss.as:management-root=server"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for "running"
            FAILURE if the query itself failed
            NOT_READY for all other states 
        """

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")
        if results["value"] == "running":
            return (Status.READY, results["value"])
        return (Status.NOT_READY, results["value"])

class BootErrorsTest(Test):
    """
    Checks the server for boot errors.
    """

    def __init__(self):
        super(BootErrorsTest, self).__init__(
            {
                "type": "exec",
                "operation": "readBootErrors",
                "mbean": "jboss.as:core-service=management"
            }
        )
        self.__disableBootErrorsCheck = os.getenv("PROBE_DISABLE_BOOT_ERRORS_CHECK", "false").lower() == "true"

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if no boot errors were returned
            HARD_FAILURE if any boot errors were returned
            FAILURE if the query itself failed
        """

        if self.__disableBootErrorsCheck:
            return (Status.READY, "Boot errors check is disabled")

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

        if results["value"]:
            errors = []
            errors.extend(results["value"])
            return (Status.HARD_FAILURE, errors)

        return (Status.READY, "No boot errors")

class DeploymentTest(Test):
    """
    Checks the state of the deployments.
    """

    def __init__(self):
        super(DeploymentTest, self).__init__(
            {
                "type": "read",
                "attribute": "status",
                "mbean": "jboss.as:deployment=*"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for a 404 due to InstanceNotFoundException as that means no deployments configured on the system
            READY if all deployments are OK
            HARD_FAILURE if any deployments FAILED
            FAILURE if the query failed or if any deployments are not OK, but not FAILED
        """

        if results["status"] == 404 and results.get("error_type") and re.compile(".*InstanceNotFoundException.*").match(results.get("error_type")):
            return (Status.READY, "No deployments")

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

        if not results["value"]:
            return (Status.READY, "No deployments")

        status = set()
        messages = {}
        for key, value in results["value"].items():
            deploymentStatus = value["status"]
            messages[key.rsplit("=",1)[1]] = deploymentStatus
            if deploymentStatus == "FAILED":
                status.add(Status.HARD_FAILURE)
            elif deploymentStatus == "OK":
                status.add(Status.READY)
            else:
                status.add(Status.FAILURE)
        return (min(status), messages)

class HealthCheckTest(Test):
    """
    Checks the state of the Health Check subsystem, if installed.
    """

    def __init__(self):
        super(HealthCheckTest, self).__init__(
            {
                "type": "exec",
                "operation": "check",
                "mbean": "jboss.as:subsystem=microprofile-health-smallrye"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for a 404 due to InstanceNotFoundException as that means no health check configured on the system
            HARD_FAILURE for any other non-200 as the query failed
            READY if the result value's outcome field is 'UP'
            HARD_FAILURE otherwise

        In no case do we return NOT_READY as MicroProfile Health Check is not a readiness check.
        """

        if results["status"] == 404 and results.get("error_type") and re.compile(".*InstanceNotFoundException.*").match(results.get("error_type")):
            return (Status.READY, "Health Check not configured")

        if results["status"] != 200 or not results.get("value"):
	        return (Status.HARD_FAILURE, "Jolokia query failed " + str(results))

        outcome = results["value"].get("outcome")

        if not outcome:
            return (Status.HARD_FAILURE, "No outcome")

        if re.compile("\W*UP\W*").match(outcome):
            return (Status.READY, "Status is UP")

        return (Status.HARD_FAILURE, outcome)

