Y=yarn -s --prefer-offline

.PHONY: install
install: .yarn.INSTALLED .yarn.examples-optimized.INSTALLED .yarn.elm-book.INSTALLED
.yarn.INSTALLED: package.json yarn.lock
	${Y} install
	@touch $@

.yarn.examples-optimized.INSTALLED: ./examples-optimized/package.json ./examples-optimized/yarn.lock
	yarn --cwd examples-optimized install
	@touch $@

.yarn.elm-book.INSTALLED: ./elm-book/package.json ./elm-book/yarn.lock
	${Y} --cwd=elm-book install
	@touch $@

.PHONY: elm-examples
elm-examples: install
	cd examples && elm reactor & yarn --cwd examples-optimized start

.PHONY: elm-reactor
elm-reactor:
	cd examples && elm reactor


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

.PHONY: preview-docs
preview-docs: install
	yarn elm-doc-preview

.PHONY: elm-book
elm-book: install
	${Y} --cwd=elm-book parcel --dist-dir=dist-book --open --port=8086 book.html
