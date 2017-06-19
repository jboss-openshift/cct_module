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

import argparse
import importlib
import json
import logging
import time

from probe.api import qualifiedClassName, Status

class ProbeRunner(object):
    """
    Simply executes a series of Probes, returning the combined Status and
    messages.
    """
    
    def __init__(self, probes = []):
        self.probes = probes
        self.logger = logging.getLogger(qualifiedClassName(self))

    def addProbe(self, probe):
        self.probes.append(probe)

    def executeProbes(self):
        self.logger.info("Running the following probes: [%s]", ", ".join(qualifiedClassName(probe) for probe in self.probes))
        results = set()
        output = {}
        for probe in self.probes:
            self.logger.info("Running probe: %s", qualifiedClassName(probe))
            (statuses, messages) = probe.execute()
            self.logger.info("Probe %s returned statuses [%s]", qualifiedClassName(probe), ", ".join(str(status) for status in statuses))
            if self.logger.isEnabledFor(logging.DEBUG):
                self.logger.debug("Probe %s returned messages %s", qualifiedClassName(probe), json.dumps(messages, indent=4, separators=(',', ': ')))
            results |= statuses
            output[qualifiedClassName(probe)] = messages
        return (results, output)

def toStatus(value):
    """
    Helper method which converts a string to a Status.  Used by the
    ArgumentParser.
    """
    
    return Status[value]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Executes the specified probes returning cleanly if probe status matches desired status")
    parser.add_argument("-c", "--check", required = True, type = toStatus, action = "append", help = "The acceptable probe statuses, may be: READY, NOT_READY.")
    parser.add_argument("-d", "--debug", action = "store_true", help = "Enable debugging")
    parser.add_argument("-r", "--maxruns", default = 1, type = int, help = "Number of runs to try without success before exiting.")
    parser.add_argument("-s", "--sleep", default = 1, type = int, help = "Number of seconds to sleep between runs.")
    parser.add_argument("--logfile", help = "Log file.")
    parser.add_argument("--loglevel", default = "CRITICAL", choices = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], help = "Log level.")
    parser.add_argument("probes", nargs = argparse.REMAINDER, help = "The probes to execute.")
    
    args = parser.parse_args()
    
    # don't spam warnings (e.g. when not verifying ssl connections)
    logging.captureWarnings(True)
    
    if args.logfile:
        logging.basicConfig(filename = args.logfile, format = '%(asctime)s %(levelname)s [%(name)s] %(message)s', level = args.loglevel.upper())
    else:
        logging.basicConfig(level = args.loglevel.upper())
    
    logger = logging.getLogger(__name__)

    logger.debug("Starting probe runner with args: %s", args)

    runner = ProbeRunner()
    for probe in args.probes:
        logger.info("Loading probe: %s", probe)
        probeModule = importlib.import_module(probe.rsplit(".", 1)[0])
        probeClass = getattr(probeModule, probe.rsplit(".", 1)[1])
        runner.addProbe(probeClass())
    
    maxruns = args.maxruns
    okStatus = set(args.check)
    
    logger.info("Probes will fail for the following states: [%s]", ", ".join(str(status) for status in set(Status) - okStatus))

    probeStatus = set()
    output = {}
    while True:
        maxruns -= 1
        logger.info("Running probes")
        (probeStatus, output) = runner.executeProbes()
        if okStatus >= probeStatus:
            logger.info("Probes succeeded")
            if args.debug:
                print(json.dumps(output, indent=4, separators=(',', ': ')))
            exit(0)
        if Status.HARD_FAILURE in probeStatus:
            logger.error("Probes detected HARD_FAILURE.  Exiting retry loop.")
            break
        if maxruns > 0:
            logger.error("Probes failed.  Retries remaining: %s.", maxruns)
            logger.info("Retrying probes in %ss", args.sleep)
            time.sleep(args.sleep)
        else:
            break

    # we didn't succeed
    logger.error("Probe failure.  Probes did not succeed after %s attempts.", args.maxruns - maxruns)
    # print so the output is available to users in the OpenShift event log
    print(json.dumps(output, indent=4, separators=(',', ': ')))
    exit(1)
