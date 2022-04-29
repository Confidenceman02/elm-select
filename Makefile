Y=yarn -s --prefer-offline

.PHONY: install
install: .yarn.INSTALLED .yarn.examples-optimized.INSTALLED
.yarn.INSTALLED: package.json yarn.lock
	yarn install
	@touch $@

.yarn.examples-optimized.INSTALLED: ./examples-optimized/package.json ./examples-optimized/yarn.lock
	yarn --cwd examples-optimized install
	@touch $@

.PHONY: elm-examples
elm-examples: install
	cd examples && elm reactor & yarn --cwd examples-optimized start

.PHONY: elm-tests
elm-tests:
	yarn elm-test

.PHONY: ts-tests
ts-tests: install
	./bin/test-ts.sh

.PHONY: ci-e2e-test
ci-e2e-test: 
	yarn start-server-and-test  'make elm-examples' '8000|1234' 'make ts-tests'

.PHONY: elm-live
elm-live: install
	yarn elm-live --no-server

.PHONY: elm-analyse
elm-analyse: install
	yarn elm-analyse
