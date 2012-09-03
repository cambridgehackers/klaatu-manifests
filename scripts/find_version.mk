BUILD_SYSTEM=build/core
include ${BUILD_SYSTEM}/version_defaults.mk

all:
	echo "invoke with either 'make build_id' or 'make platform_version'"

build_id:
	@echo ${BUILD_ID}

platform_version:
	@echo ${PLATFORM_VERSION}
