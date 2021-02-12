BUILD_DIR = build
INCLUDE_DIR = include
SRC_DIR = src

OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,\
	$(wildcard $(SRC_DIR)/*.c))
EXEC = network-status

vpath %.h $(INCLUDE_DIR)
vpath %.o $(BUILD_DIR)
vpath %.c $(SRC_DIR)

MACROS =

CFLAGS = -g -Wall -Werror -O2 $(MACROS)
CPPFLAGS = -I$(INCLUDE_DIR)
LDFLAGS =
LDLIBS =

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
