# default targets
TARGETS = gonk
# debug build or not
DEBUG = 1
# objects needed for targets
GONK_OBJECTS=main.o fruit/fruit.o dairy/dairy.o

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

# target 'all' builds the default targets
all:	$(TARGETS)

# collect the objects, generate the names of deps
OBJECTS = $(GONK_OBJECTS)
DEPS    = $(OBJECTS:.o=.d)

# target 'clean' wipes the build clean
.PHONY:	clean
clean:
	rm -f $(TARGETS) $(OBJECTS) $(DEPS)

# include dependencies unless cleaning
ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

# create dependencies (and add a dep for this Makefile as well)
%.d:	%.cc
	($(CC) -MP -MM -MT $(basename $<).o -MT $(basename $<).d $(CFLAGS) $< && echo "$(basename $<).o $(basename $<).d: Makefile") > $@

# compile sources to objects
%.o:	%.cc %.d
	$(CC) -c -o $@ $(CFLAGS) $<

# link objects to executable (and strip it unless debug-build)
gonk:	$(GONK_OBJECTS)
	$(LD) -o $@ $(LDFLAGS) $(LDLIBS) $^
ifeq ($(DEBUG),)
	strip -s $@
endif

# vim: set noet ts=8 sw=8 list:
