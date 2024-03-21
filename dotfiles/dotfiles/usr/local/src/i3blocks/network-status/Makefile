#######################################
# Build constants
#######################################

BUILD_DIR = build
INCLUDE_DIR = include
SRC_DIR = src

#######################################
# Build-time program parameters
#######################################

# Colors
GOOD_CONNECTION_QUALITY_COLOR ?= \#FFFFFF
MEDIUM_CONNECTION_QUALITY_COLOR ?= \#AAAAAA
BAD_CONNECTION_QUALITY_COLOR ?= \#555555
INACTIVE_CONNECTION_COLOR ?= \#000000

# Connection quality thresholds
GOOD_CONNECTION_QUALITY_THRESHOLD ?= 65.0
MEDIUM_CONNECTION_QUALITY_THRESHOLD ?= 30.0

# Text style
LABEL_SEPARATOR ?=
PANGO_PROPS ?=

#######################################
# Build flags
#######################################

vpath %.h $(INCLUDE_DIR)
vpath %.o $(BUILD_DIR)
vpath %.c $(SRC_DIR)

MACROS += -D'GOOD_CONNECTION_QUALITY_COLOR="$(GOOD_CONNECTION_QUALITY_COLOR)"' \
    -D'MEDIUM_CONNECTION_QUALITY_COLOR="$(MEDIUM_CONNECTION_QUALITY_COLOR)"' \
    -D'BAD_CONNECTION_QUALITY_COLOR="$(BAD_CONNECTION_QUALITY_COLOR)"' \
    -D'INACTIVE_CONNECTION_COLOR="$(INACTIVE_CONNECTION_COLOR)"' \
    -D'GOOD_CONNECTION_QUALITY_THRESHOLD=$(GOOD_CONNECTION_QUALITY_THRESHOLD)' \
    -D'MEDIUM_CONNECTION_QUALITY_THRESHOLD=$(MEDIUM_CONNECTION_QUALITY_THRESHOLD)' \
    -D'LABEL_SEPARATOR="$(LABEL_SEPARATOR)"' \
    -D'PANGO_PROPS="$(PANGO_PROPS)"'

ifdef CABLE_LABEL
    MACROS += -D'CABLE_LABEL="$(CABLE_LABEL)"'
endif
ifdef WIRELESS_LABEL
    MACROS += -D'WIRELESS_LABEL="$(WIRELESS_LABEL)"'
endif
ifdef WAYLAND_DISPLAY
    MACROS += -DSWAYBAR
endif

CFLAGS = -g -Wall -Werror -O2 $(MACROS)
CPPFLAGS = -I$(INCLUDE_DIR)
LDFLAGS =
LDLIBS =

#######################################
# Target variables
#######################################

OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,\
	$(wildcard $(SRC_DIR)/*.c))
EXEC = network-status

#######################################
# Targets
#######################################

.PHONY: clean clear

$(EXEC) : $(OBJECTS)

$(OBJECTS) : $(BUILD_DIR)/%.o : %.c | $(BUILD_DIR)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(BUILD_DIR) :
	mkdir -p $(BUILD_DIR)

clean :
	$(RM) $(OBJECTS)

clear : clean
	$(RM) -r $(BUILD_DIR) $(EXEC)

install : $(EXEC)
	install --directory $(PREFIX)
	install --mode 755 $< $(PREFIX)/$<
