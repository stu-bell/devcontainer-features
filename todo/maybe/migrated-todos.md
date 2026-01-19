# TODO Maybe

- test-builds.sh: when loading scenarios.json, ensure that there are no objects in the array with matching name keys, error if so
- test-builds.sh: add optional scenario description to scenarios.json, to print alongside tests that fail, if the description is provided
- test-builds.sh: if scenarios.json param is blank, or resolves to a non existant, or invalid file, output a message explaining where the file should be and rerun with --generate-example to see an example
- test-builds.sh: accept an array of expected output strings to test for, all should be present
- test-builds.sh: pass grep options for testing expected output
- test-builds.sh: option to test starting and executing a test script in the started dev container (rather than just building the image). start container after build, provide a command on scenarios.json to exec after container starts. Can still use the expected output and return codes on the entire build/start/exec process? will need to stop and clean up container after use. Could we also mount local .sh files to allow the exec to execute a test file, which could also report results? similar to the way devcontainer cli feature tests work? Or you could just add your validation command to exec and check for exit code and expected output, eg "exec": "mytool --version". include a test-script property on each scenario which includes a path to a test script for that scenario. Multiple scenarios might share the same test. Script should exit 0 to pass, 1 to fail
- test-builds.sh: can we run some builds concurrently? How do we keep within resource limits?
- test-builds.sh: validate scenarios schema?

