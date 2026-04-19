# Default SDK path — override: make SDK=/path/to/connectiq-sdk-lin-...
SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b
MONKEYC := $(SDK)/bin/monkeyc
MONKEYDO := $(SDK)/bin/monkeydo
CONNECTIQ := $(SDK)/bin/connectiq

DEVICE ?= fenix7spro
KEY ?= private_key.der
OUT ?= CloudX28.prg

# Compiler-generated settings schema (sibling of the .prg). Required on Linux for the
# simulator menu File → Edit Persistent Storage → Edit Application.properties data.
SETTINGS_SRC := $(patsubst %.prg,%-settings.json,$(OUT))
APP_BASE := $(basename $(notdir $(OUT)))
SETTINGS_VPATH := GARMIN/Settings/$(shell echo $(APP_BASE) | tr '[:lower:]' '[:upper:]')-settings.json

.PHONY: build run simulator

build:
	$(MONKEYC) -f monkey.jungle -o $(OUT) -y $(KEY) -d $(DEVICE) -w

# Launches the Connect IQ Simulator (GUI). Run in its own terminal; keep it open while developing.
simulator:
	$(CONNECTIQ)

# Requires Connect IQ Simulator already running (see BUILD).
run: build
	@echo "Start the Connect IQ Simulator first (e.g. make simulator in another terminal), then this loads $(OUT) on $(DEVICE)."
	@if [ ! -f "$(SETTINGS_SRC)" ]; then echo "Missing $(SETTINGS_SRC); rebuild failed to emit app settings metadata." >&2; exit 1; fi
	$(MONKEYDO) $(OUT) $(DEVICE) -a "$(SETTINGS_SRC):$(SETTINGS_VPATH)"
