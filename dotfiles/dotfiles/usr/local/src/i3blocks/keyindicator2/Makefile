#######################################
# Build-time program parameters
#######################################

# Colors
ACTIVE_KEY_COLOR ?= \#FFFFFF
INACTIVE_KEY_COLOR ?= \#000000

# Text style
LABEL_SEPARATOR ?=
PANGO_PROPS ?=

#######################################
# Build flags
#######################################

MACROS += -D'ACTIVE_KEY_COLOR="$(ACTIVE_KEY_COLOR)"' \
    -D'INACTIVE_KEY_COLOR="$(INACTIVE_KEY_COLOR)"' \
    -D'LABEL_SEPARATOR="$(LABEL_SEPARATOR)"' \
    -D'PANGO_PROPS="$(PANGO_PROPS)"'

ifdef CAPS_LABEL
	MACROS += -D'CAPS_LABEL="$(CAPS_LABEL)"'
endif
ifdef NUM_LABEL
	MACROS += -D'NUM_LABEL="$(NUM_LABEL)"'
endif

CFLAGS = -g -Wall -Werror -O2 $(MACROS)
LDFLAGS = -L/usr/X11/lib
LDLIBS = -lX11

#######################################
# Target variables
#######################################

EXEC = keyindicator2

#######################################
# Targets
#######################################

.PHONY: clean clear

clean:
	$(RM) $(EXEC)

clear: clean

install : $(EXEC)
	install --directory $(PREFIX)
	install --mode 755 $< $(PREFIX)/$<
