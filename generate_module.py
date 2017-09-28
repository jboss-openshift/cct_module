#!/bin/python

import argparse
import logging
import os
import yaml
from collections import OrderedDict

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Creates a module.yaml file for each of the specified directories")
    parser.add_argument("--loglevel", default = "INFO", choices = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], help = "Log level.")
    parser.add_argument("directories", nargs = argparse.REMAINDER, help = "The directories to scan for creating module.yaml files.")

    args = parser.parse_args()

    logging.basicConfig(level = args.loglevel.upper())
    logger = logging.getLogger("main")

    logger.debug("Starting generator with args: %s", args)

    # dump ordered dict as a regular dict
    represent_dict_order = lambda self, data:  self.represent_mapping('tag:yaml.org,2002:map', data.items())
    yaml.add_representer(OrderedDict, represent_dict_order)

    for directory in args.directories:
        directory = os.path.abspath(directory)
        if not os.path.isdir(directory):
            logger.info("Skipping %s is not a directory." % (directory))
            continue
        logger.info("Creating module.yaml in %s" % (directory))
        module = OrderedDict()
        module['schema_version'] = 1
        module['name'] = os.path.basename(directory)
        module['version'] = "1.0"
        module['description'] = "Legacy %s script package." % (module['name'])
        executes = []
        for child in os.listdir(directory):
            if os.path.isfile(os.path.join(directory, child)):
                executes.append({"script": child})
        if len(executes) > 0:
            module['execute'] = executes
        module_file = os.path.join(directory, "module.yaml")
        if os.path.exists(module_file):
            logger.warning("%s exists, skipping." % (module_file))
            continue
        logger.info("Creating module.yaml file %s" % (module_file))
        try:
            with open(module_file, 'w') as f:
                yaml.dump(module, f, default_flow_style=False)
        except:
            logger.exception("Failed to create %s" %s (module_file))

    logger.info("Finished generating module.yaml files.")
