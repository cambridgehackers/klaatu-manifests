CALLED_FROM_SETUP=true
BUILD_SYSTEM=build/core
include ${BUILD_SYSTEM}/config.mk

ifeq ($(MAKECMDGOALS),)
all:
	@echo "invoke with 'make <variable_name>'"
endif

$(MAKECMDGOALS):
	@echo $($(MAKECMDGOALS))
