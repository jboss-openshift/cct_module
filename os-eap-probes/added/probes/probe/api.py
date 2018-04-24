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

import json
import logging
import sys

from enum import Enum

def qualifiedClassName(obj):
    """
    Utility method for returning the fully qualified class name of an instance.
    Objects must be instances of "new classes."
    """

    return obj.__module__ + "." + type(obj).__name__

class Status(Enum):
    """
    Represents the outcome of a test.
        HARD_FAILURE: An unrecoverable failure, causing an immediate failure of
            the probes, i.e. no extra tries to see if the probe will pass.
        FAILURE: A test failed, but may succeed on a subsequent execution
        NOT_READY: The functionality being tested is not in a failed state, but
        is also not ready, e.g. it may still be starting up, rebalancing, etc.
        READY: The functionality being tested is ready to handle requests.
    """

    HARD_FAILURE = 1
    FAILURE = 2
    NOT_READY = 4
    READY = 8
    
    def __str__(self):
        return self.name

    def __cmp__(self, other):
        if type(other) is self.__class__:
            return self.value - other.value
        return NotImplemented

    def __le__(self, other):
        if type(other) is self.__class__:
            return self.value <= other.value
        return NotImplemented

    def __lt__(self, other):
        if type(other) is self.__class__:
            return self.value < other.value
        return NotImplemented

    def __ge__(self, other):
        if type(other) is self.__class__:
            return self.value >= other.value
        return NotImplemented

    def __gt__(self, other):
        if type(other) is self.__class__:
            return self.value > other.value
        return NotImplemented

class Test(object):
    """
    An object which provides a query and evaluates the response.  A Probe may
    consist of many tests, which determine the liveness or readiness of the
    server.
    """

    def __init__(self, query):
        self.query = query
        
    def getQuery(self):
        """
        Returns the query used by this test.  The return value is Probe
        specific.  Many Probe implementations use JSON for submitting queries,
        which means this function would return a dict.
        """
        return self.query
        
    def evaluate(self, results):
        """
        Evaluate the response from the server, returning Status and messages.
        messages should be returned as an object, list or dict. 
        """
        raise NotImplementedError("Implement evaluate() for Test: " + qualifiedClassName(self))

class Probe(object):
    """
    Runs a series of tests against a server to determine its readiness or
    liveness.
    """

    def __init__(self, tests = []):
        self.tests = tests

    def addTest(self, test):
        """
        Adds a test to this Probe.  The Test must provide a query that is
        compatible with the Probe implementation (e.g. a DMR request formatted
        as JSON).  The Test must be capable of understanding the results
        returned by the Probe (e.g. a JSON response from DMR).
        """
        
        self.tests.append(test)

    def execute(self):
        """
        Executes the queries and evaluates the tests and returns a set of Status
        and messages collected for each test.
        """
        
        raise NotImplementedError("Implement execute() for Probe: " + qualifiedClassName(self))

class BatchingProbe(Probe):
    """
    Base class which supports batching queries to be sent to a server and
    splitting the results to correspond with the individual tests.
    """
    
    def __init__(self, tests = []):
        super(BatchingProbe, self).__init__(tests)
        self.logger = logging.getLogger(qualifiedClassName(self))

    def execute(self):
        self.logger.info("Executing the following tests: [%s]", ", ".join(qualifiedClassName(test) for test in self.tests))
        request = self.createRequest()

        try:
            results = self.sendRequest(request)
            status = set()
            output = {}
            for index, test in enumerate(self.tests):
                self.logger.info("Executing test %s", qualifiedClassName(test))
                try:
                    testResults = self.getTestInput(results, index)
                    if self.logger.isEnabledFor(logging.DEBUG):
                        self.logger.debug("Test input = %s", json.dumps(testResults, indent=4, separators=(',', ': ')))
                    (state, messages) = test.evaluate(testResults)
                    self.logger.info("Test %s returned status %s", qualifiedClassName(test), str(state))
                    status.add(state)
                    output[qualifiedClassName(test)] = messages
                except:
                    self.logger.exception("Unexpected failure running test %s", qualifiedClassName(test))
                    status.add(Status.FAILURE)
                    output[qualifiedClassName(test)] = "Exception executing test: %s" % (sys.exc_info()[1])
            return (status, output)
        except:
            self.logger.exception("Unexpected failure sending probe request")
            return (set([Status.FAILURE]), "Error sending probe request: %s" % (sys.exc_info()[1]))

    def createRequest(self):
        """
        Create the request to send to the server.  Subclasses should include the
        queries from all tests in the request.
        """
        
        raise NotImplementedError("Implement createRequest() for BatchingProbe: " + qualifiedClassName(self))

    def sendRequest(self, request):
        """
        Send the request to the server.
        """

        raise NotImplementedError("Implement sendRequest() for BatchingProbe: " + qualifiedClassName(self))

    def getTestInput(self, results, testIndex):
        """
        Return the results specific to the indexed test.
        """
        
        raise NotImplementedError("Implement getTestInput() for BatchingProbe: " + qualifiedClassName(self))
