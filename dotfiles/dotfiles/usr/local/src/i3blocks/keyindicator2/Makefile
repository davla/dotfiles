ifdef ACTIVE_COLOR
	MACROS = -D'ACTIVE_COLOR="$(ACTIVE_COLOR)"'
endif
ifdef CAPS_LABEL
	MACROS := $(MACROS) -D'CAPS_LABEL="$(CAPS_LABEL)"'
endif
ifdef INACTIVE_COLOR
	MACROS := $(MACROS) -D'INACTIVE_COLOR="$(INACTIVE_COLOR)"'
endif
ifdef NO_CAPS
	MACROS := $(MACROS) -D NO_CAPS
endif
ifdef NO_NUM
	MACROS := $(MACROS) -D NO_NUM
endif
ifdef NUM_LABEL
	MACROS := $(MACROS) -D'NUM_LABEL="$(NUM_LABEL)"'
endif

INDICATOR = keyindicator2
OBJECTS =
CFLAGS = -g -Wall -Werror -O2 $(MACROS)
LDFLAGS = -L/usr/X11/lib
LDLIBS = -lX11

$(INDICATOR): $(OBJECTS)

clean:
	$(RM) $(INDICATOR) $(OBJECTS)

install : $(INDICATOR)
	install --directory $(PREFIX)
	install --mode 755 $< $(PREFIX)/$<