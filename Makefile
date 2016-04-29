# default targets
TARGETS = gonk
# debug build or not
DEBUG = 1
# objects needed for targets
PARTS=main fruit/fruit dairy/dairy

# tools
CC = g++
LD = g++

# tool options
CFLAGS += -Wall -Werror
LDLIBS += -lcurses
ifneq ($(DEBUG),)
CFLAGS += -O3
else
CFLAGS += -O0 -ggdb3
LDFLAGS += -ggdb3
endif

# place for generated files (objects, deps, etc.)
GEN=gen

# target 'all' builds the default targets
all:	$(TARGETS)

# collect the objects, generate the names of deps
OBJECTS = $(addsuffix .o,$(PARTS))
DEPS    = $(addsuffix .d,$(PARTS))

.PRECIOUS:	$(addprefix $(GEN)/,$(DEPS))

# target 'clean' wipes the build clean
.PHONY:	clean
clean:
	rm -rf $(TARGETS) $(GEN)

# include dependencies unless cleaning
ifneq ($(MAKECMDGOALS),clean)
-include $(addprefix $(GEN)/,$(DEPS))
endif

# create dependencies (and add a dep for this Makefile as well)
$(GEN)/%.d:	%.cc
	mkdir -p $(dir $@)
	($(CC) -MP -MM -MT $(GEN)/$(basename $<).o -MT $(GEN)/$(basename $<).d $(CFLAGS) $< && echo "$(GEN)/$(basename $<).o $(GEN)/$(basename $<).d: Makefile") > $@

# compile sources to objects
$(GEN)/%.o:	%.cc $(GEN)/%.d
	$(CC) -c -o $@ $(CFLAGS) $<

# link objects to executable (and strip it unless debug-build)
gonk:	$(addprefix $(GEN)/,$(OBJECTS))
	$(LD) -o $@ $(LDFLAGS) $(LDLIBS) $^
ifeq ($(DEBUG),)
	strip -s $@
endif

# vim: set noet ts=8 sw=8 list:
