.PHONY: all dist clean gen test copy-schemas

all: gen

gen:
	GO111MODULE=on go run ./cmd/apigen/ cmd/apigen/specs/swagger-v1.13.0.json cmd/apigen/templates ./src/

src/api.ts: gen
src/shapes.ts: gen

dist: src/api.ts src/shapes.ts copy-schemas
	npx tsc
	npx tsc -d --emitDeclarationOnly --allowJs false
	cp README.md LICENSE package.json @jkcfg/kubernetes
	cp -R src/schemas @jkcfg/kubernetes/

clean:
	rm -rf @jkcfg
	rm -f src/api.ts src/shapes.ts

test: gen
	npm test
	npm run lint

copy-schemas:
	git submodule update -- ./schemas
	mkdir -p build/schemas
	for d in schemas/*-local; do   \
		cp -R "$$d" src/schemas/; \
	done
