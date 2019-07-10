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
#CFLAGS += -DDEBUG
LDFLAGS += -ggdb3
endif


# place for generated files (objects, deps, etc.)
GEN=gen

# target 'all' builds the default targets
all:		$(TARGETS)

# collect the objects, generate the names of deps
OBJECTS = $(addprefix $(GEN)/,$(addsuffix .o,$(PARTS)))
DEPS    = $(addprefix $(GEN)/,$(addsuffix .d,$(PARTS)))

.PRECIOUS:	$(DEPS)

# target 'clean' wipes the build clean
.PHONY:	clean
clean:
		rm -rf $(TARGETS) $(GEN)

# include dependencies unless cleaning
ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

# create dependencies (and add a dep for this Makefile as well)
$(GEN)/%.d:	%.cc
		mkdir -p $(dir $@)
		($(CC) -MP -MM -MT $(@:.d=.o) -MT $@ $(CFLAGS) $< && echo "$(@:.d=.o) $@: Makefile") > $@

# compile sources to objects
$(GEN)/%.o:	%.cc $(GEN)/%.d
		$(CC) -c -o $@ $(CFLAGS) $<

# link objects to executable (and strip it unless debug-build)
gonk:		$(OBJECTS)
		$(LD) -o $@ $(LDFLAGS) $(LDLIBS) $^
ifeq ($(DEBUG),)
		strip -s $@
endif

# vim: set noet ts=8 sw=8:
