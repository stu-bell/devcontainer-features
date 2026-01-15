
- test-builds.sh: accept non-local features, ie from ghcr.io (current behaviour is to treat feature as a local path and copy the folder)

test/test-builds.sh works by reading a scenarios.json file to test features. Run test-builds.sh with the -g flag to see the format, and -h for help. devcontainer property on scenarios.json gets copied to a temp .devcontainer folder which is then used to configure and test a devcontainer. Also copied is the feature path, relative to the scenarios.json, for testing local features. 

Task: extend test-builds.sh to work with online features from an OCI repo (eg ghcr.io). I think a safe way to do this would be that if the feature doesn't look like a local file path, or doesn't point to a local folder that exists, treat it as an OCI URL. I think no action is needed in this case, we just don't attempt to copy the file, and we leave that feature URI as is, and it will end up being copied to the temp .devcontainer/devcontainer.json

Test this by creating a new scenarios json file, eg in the `_global` folder, that uses a single scenario for alpine and uses a feature that's quick to install, such as ttyd

Review this task and check for anything relevant that I might have missed. Ask for any clarifications you need before commencing the work. 

