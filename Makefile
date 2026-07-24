# Default SDK path — override: make SDK=/path/to/connectiq-sdk-lin-...
SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.2.0-2026-06-09-92a1605b2
MONKEYC := $(SDK)/bin/monkeyc
MONKEYDO := $(SDK)/bin/monkeydo
CONNECTIQ := $(SDK)/bin/connectiq

DEVICE ?= fenix7s
KEY ?= private_key.der
OUT ?= MiAlarmaX28.prg

# App IDs: beta keeps the historical id; production is a separate Connect IQ app.
VARIANT ?= beta
APP_ID_BETA := e5c2d0b9-a0b1-4409-a1ee-6b624232a567
APP_ID_PROD := 168e7243-c97c-4c5b-9129-702a41125c87
ifeq ($(VARIANT),prod)
  APP_ID := $(APP_ID_PROD)
  OUT_IQ ?= MiAlarmaX28-prod.iq
else ifeq ($(VARIANT),beta)
  APP_ID := $(APP_ID_BETA)
  OUT_IQ ?= MiAlarmaX28-beta.iq
else
  $(error VARIANT must be 'beta' or 'prod' (got '$(VARIANT)'))
endif

MANIFEST_TEMPLATE := manifest.template.xml
MANIFEST := manifest.xml

SETTINGS_SRC := $(patsubst %.prg,%-settings.json,$(OUT))
APP_BASE := $(basename $(notdir $(OUT)))
SETTINGS_VPATH := GARMIN/Settings/$(shell echo $(APP_BASE) | tr '[:lower:]' '[:upper:]')-settings.json

.PHONY: build run simulator release clean-manifest $(MANIFEST)

# Always regenerate so switching VARIANT=beta|prod updates the id.
$(MANIFEST): $(MANIFEST_TEMPLATE)
	sed 's/__APP_ID__/$(APP_ID)/g' $< > $@
	@echo "Generated $@ (VARIANT=$(VARIANT) APP_ID=$(APP_ID))"

clean-manifest:
	rm -f $(MANIFEST)

build: $(MANIFEST)
	$(MONKEYC) -f monkey.jungle -o $(OUT) -y $(KEY) -d $(DEVICE) -w

release: $(MANIFEST)
	$(MONKEYC) -f monkey.jungle -o $(OUT_IQ) -y $(KEY) -e -r -w

simulator:
	$(CONNECTIQ)

run: build
	@echo "Start the Connect IQ Simulator first (e.g. make simulator in another terminal), then this loads $(OUT) on $(DEVICE)."
	@if [ ! -f "$(SETTINGS_SRC)" ]; then echo "Missing $(SETTINGS_SRC); rebuild failed to emit app settings metadata." >&2; exit 1; fi
	$(MONKEYDO) $(OUT) $(DEVICE) -a "$(SETTINGS_SRC):$(SETTINGS_VPATH)"
