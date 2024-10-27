all: src project release-build

clean:
	bash -c "if test -e libcmark_gfm.xcodeproj ; then xcodebuild clean ; fi"
	rm -rf build
.PHONY: clean

ultra-clean:
	rm -rf src extensions libcmark_gfm.xcodeproj build
.PHONY: ultra-clean

src:
	./bin/import-src.sh
.PHONY: src

project:
	bash -c "if test ! -e libcmark_gfm.xcodeproj ; then xcodegen generate ; fi"
.PHONY: project

release-build:
	xcodebuild -configuration Release
.PHONY: release-build
