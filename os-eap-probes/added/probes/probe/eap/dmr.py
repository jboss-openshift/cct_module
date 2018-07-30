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
from probe.dmr import DmrProbe

class EapProbe(DmrProbe):
    """
    Basic EAP probe which uses the DMR interface to query server state.  It
    defines tests for server status, boot errors and deployment status.
    """

    def __init__(self):
        super(EapProbe, self).__init__(
            [
                ServerStatusTest(),
                BootErrorsTest(),
                DeploymentTest()
            ]
        )

class ServerStatusTest(Test):
    """
    Checks the status of the server.
    """

    def __init__(self):
        super(ServerStatusTest, self).__init__(
            {
                "operation": "read-attribute",
                "name": "server-state"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for "running"
            FAILURE if the query itself failed
            NOT_READY for all other states 
        """

        if results["outcome"] != "success" and results.get("failure-description"):
            return (Status.FAILURE, "DMR query failed")
        if results["result"] == "running":
            return (Status.READY, results["result"])
        return (Status.NOT_READY, results["result"])

class BootErrorsTest(Test):
    """
    Checks the server for boot errors.
    """

    def __init__(self):
        super(BootErrorsTest, self).__init__(
            {
                "operation": "read-boot-errors",
                "address": {
                    "core-service": "management"
                }
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

        if results["outcome"] != "success" and results.get("failure-description"):
            return (Status.FAILURE, "DMR query failed")

        if results.get("result"):
            errors = []
            errors.extend(results["result"])
            return (Status.HARD_FAILURE, errors)

        return (Status.READY, "No boot errors")

class DeploymentTest(Test):
    """
    Checks the state of the deployments.
    """

    def __init__(self):
        super(DeploymentTest, self).__init__(
            {
                "operation": "read-attribute",
                "address": {
                    "deployment": "*"
                },
                "name": "status"
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            READY if all deployments are OK
            HARD_FAILURE if any deployments FAILED
            FAILURE if the query failed or if any deployments are not OK, but not FAILED
        """

        if results["outcome"] != "success" and results.get("failure-description"):
            return (Status.FAILURE, "DMR query failed")

        if not results["result"]:
            return (Status.READY, "No deployments")

        status = set()
        messages = {}
        for result in results["result"]:
            if result["outcome"] != "success" and result.get("failure-description"):
                status.add(Status.FAILURE)
                messages[result["address"][0]["deployment"]] = "DMR query failed"
            else:
                deploymentStatus = result["result"]
                messages[result["address"][0]["deployment"]] = deploymentStatus
                if deploymentStatus == "FAILED":
                    status.add(Status.HARD_FAILURE)
                elif deploymentStatus == "OK":
                    status.add(Status.READY)
                else:
                    status.add(Status.FAILURE)

        return (min(status), messages)

class HealthCheckProbe(DmrProbe):
    """
    Basic EAP probe which uses the DMR interface to query server state.  It
    defines tests for server status, boot errors and deployment status.
    """

    def __init__(self):
        super(HealthCheckProbe, self).__init__(
            [
                HealthCheckTest()
            ]
        )

class HealthCheckTest(Test):
    """
    Checks the state of the Health Check subsystem, if installed.
    We use a composite with a first step that does a simple read-resource
    and a second step that reads the health check status.
    A failure in the first step means the subsystem is not present and any
    failure in the second step should be ignored as meaningless.
    """

    def __init__(self):
        super(HealthCheckTest, self).__init__(
            {
                "operation": "composite",
                "address": [],
                "steps": [
                    {
                        "operation": "read-resource",
                        "address": {
                            "subsystem": "microprofile-health-smallrye"
                        },
                        "recursive" : False
                    },
                    {
                        "operation": "check",
                        "address": {
                            "subsystem": "microprofile-health-smallrye"
                        }
					}
				]
            }
        )

    def evaluate(self, results):
        """
        Evaluates the test:
            if the overall composite failed with JBAS014883 or WFLYCTL0030
                READY as the failure means no health check extension configured on the system 
            elsif the 'read-resource' step failed:
                READY as failure means no health check subsystem configured on the system
            elsif the 'check' step succeeded:
                READY if the 'check' step result's outcome field is 'UP'
                HARD_FAILURE otherwise
            else:
                HARD_FAILURE as the query failed

        In no case do we return NOT_READY as MicroProfile Health Check is not a readiness check.
        """

        if results.get("failure-description") and re.compile("JBAS014883|WFLYCTL0030").search(str(results.get("failure-description"))):
            return (Status.READY, "Health Check not configured")

        if not results.get("result") or not results["result"].get("step-1"):
            return (Status.FAILURE, "DMR operation failed")

        if results["result"]["step-1"].get("outcome") != "success" and results["result"]["step-1"].get("failure-description"):
            return (Status.READY, "Health Check not configured")

        if not results["result"].get("step-2"):
            return (Status.HARD_FAILURE, "DMR operation failed " + str(results))

        if results["result"]["step-2"].get("outcome") != "success" or not results["result"]["step-2"].get("result"):
            return (Status.HARD_FAILURE, "DMR health check step failed " + str(results["result"]["step-2"]))

        outcome = results["result"]["step-2"]["result"].get("outcome")
        if outcome == "UP":
            return (Status.READY, "Status is UP")

        if outcome == "DOWN":
            return (Status.HARD_FAILURE, "Status is DOWN")

        return (Status.HARD_FAILURE, "DMR health check step failed " + str(results["result"]["step-2"]["result"]))

