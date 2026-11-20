SHELL:=/bin/bash

##

UV=uv

PYTHON=./python

SRCS=\
	pyskel \


##

all:

.PHONY: fgc
fgc: fix gen check


##

.PHONY: venv
venv:
	@if [ ! -d .venv ] ; then \
		${MAKE} sync || (rm -rf .venv ; exit 1) ; \
	fi

.PHONY: sync
sync:
	${UV} sync


##

.PHONY: dep-updates
dep-updates: venv
	${UV} lock --upgrade --dry-run


##

.PHONY: fix
fix: fix-docstrings fix-ruff

.PHONY: check
check: ruff mypy precheck

#

.PHONY: fix-docstrings
fix-docstrings: venv
	${PYTHON} \
		-m omdev.py.tools.fixdocstrings \
		-j- \
		-X '(?m)^# @om-generated$$' \
		-X '(?m)^# @om-no-fixdocstrings$$' \
		-W \
		${SRCS}

#

RUFF_FIX_CODES:=\
	COM812 \
	F401 \
	I001 \
	Q000 \
	W291 \
	W292 \
	W293 \

.PHONY: fix-ruff
fix-ruff: venv
	${PYTHON} -m ruff check --select "$(shell printf '%s' '$(strip $(RUFF_FIX_CODES))' | tr ' ' ',')" --fix ${SRCS}

.PHONY: ruff
ruff: venv
	${PYTHON} -m ruff check ${SRCS}

#

MYPY_OPTS=\
	--check-untyped-defs \

.PHONY: mypy
mypy: venv
	${PYTHON} -m mypy ${MYPY_OPTS} ${SRCS}

#

.PHONY: precheck
precheck: venv
	${PYTHON} -m omdev.precheck check ${SRCS}


##

.PHONY: gen
gen: gen-dataclass

#

.PHONY: gen-dataclass
gen-dataclass: venv
	${PYTHON} -m omdev.dataclasses codegen ${SRCS}

.PHONY: clean-dataclass
clean-dataclass:
	find ${SRCS} -type f -name _dataclasses.py -print -delete


##

PYTEST_OPTS=

.PHONY: test
test:
	${PYTHON} \
		-m pytest \
		${PYTEST_OPTS} \
		${SRCS}


##

.PHONY: package
package: venv
	${UV} build --wheel
