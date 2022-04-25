.PHONY: elm-examples
elm-examples:
	cd examples && elm reactor & cd examples-optimized && yarn start

.PHONY: elm-tests
elm-tests:
	yarn elm-test

.PHONY: ts-tests
ts-tests:
	./bin/test-ts.sh

.PHONY: ci-e2e-test
ci-e2e-test: 
	yarn start-server-and-test  'make elm-examples' '8000|1234' 'make ts-tests'

.PHONY: elm-live
elm-live: 
	yarn elm-live --no-server

