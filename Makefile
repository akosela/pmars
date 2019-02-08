# generic UNIX makefile
CC = gcc			# req. for linux
#CC = cc				# if you don't have gcc
# Configuration options:
#
# No.   Name            Incompatible with   Description
# (1)   -DSERVER        2                   disables cdb debugger (koth server 
#                                           version)
# (2)   -DGRAPHX        1                   enables platform specific core 
#                                           graphics
# (3)   -DKEYPRESS                          only for curses display on SysV:
#                                           enter cdb upon keypress (use if
#                                           Ctrl-C doesn't work)
# (4)   -DEXT94                             ICWS'94 + SEQ,SNE,NOP,*,{,}
# (5)   -DSMALLMEM                          16-bit addresses, less memory
# (6)   -DXWINGRAPHX    1                   X-Windows graphics (UNIX)
# (7)   -DPERMUTATE                         enables -P switch

PREFIX = /usr
MAN_PREFIX = /usr/share
LFLAGS = -x

.SUFFIXES: .o .c .c~ .man .doc .6
SRC = src
MAINFILE = $(SRC)/pmars

HEADER = $(SRC)/global.h $(SRC)/config.h $(SRC)/asm.h $(SRC)/sim.h 
OBJ1 = $(SRC)/pmars.o $(SRC)/asm.o $(SRC)/eval.o $(SRC)/disasm.o $(SRC)/cdb.o \
	$(SRC)/sim.o $(SRC)/pos.o
OBJ2 = $(SRC)/clparse.o $(SRC)/global.o $(SRC)/token.o 
OBJ3 = $(SRC)/str_eng.o

$(MAINFILE): $(OBJ1) $(OBJ2) $(OBJ3)
	@echo Linking $(MAINFILE)
	@$(CC) -o $(MAINFILE) $(OBJ1) $(OBJ2) $(OBJ3) $(LIB)
	@strip $(MAINFILE)
	@echo done

$(SRC)/token.o $(SRC)/asm.o $(SRC)/disasm.o: $(SRC)/asm.h

$(SRC)/sim.o $(SRC)/cdb.o $(SRC)/pos.o $(SRC)/disasm.o: $(SRC)/sim.h

$(SRC)/sim.o: $(SRC)/curdisp.c $(SRC)/uidisp.c $(SRC)/lnxdisp.c $(SRC)/xwindisp.c

$(SRC)/xwindisp.c: $(SRC)/xwindisp.h $(SRC)/pmarsicn.h

$(SRC)/lnxdisp.c: $(SRC)/lnxdisp.h

$(OBJ1) $(OBJ2) $(OBJ3): Makefile $(SRC)/config.h $(SRC)/global.h

.c.o:
	@echo Compiling $*.o 
	@$(CC) $(CFLAGS) -c $*.c -o $*.o

curses:	CFLAGS = -O -DEXT94 -DCURSESGRAPHX -DPERMUTATE
curses:	LIB = -lncurses
curses:	$(MAINFILE)

svga:	CFLAGS = -O -DEXT94 -DGRAPHX -DPERMUTATE
svga:	LIB = -lvgagl -lvga
svga:	$(MAINFILE)

xwin:	CFLAGS = -O -DEXT94 -DXWINGRAPHX -DPERMUTATE
xwin:	LIB = -L/usr/X11R6/lib -lX11
xwin:	$(MAINFILE)

clean:
	rm -f $(OBJ1) $(OBJ2) $(OBJ3) $(SRC)/core $(SRC)/pmars

install:
	install -d $(PREFIX)/bin
	install -d $(MAN_PREFIX)/man/man6
	install -c -m 755 $(MAINFILE) $(PREFIX)/bin
	install -c -m 644 doc/pmars.6 $(MAN_PREFIX)/man/man6
	gzip $(MAN_PREFIX)/man/man6/pmars.6

uninstall:
	rm -f $(PREFIX)/bin/pmars
	rm -f $(MAN_PREFIX)/man/man6/pmars.6.gz

help:
	@echo
	@echo "Targets:"
	@echo "    curses"
	@echo "    svga"
	@echo "    xwin"
	@echo "    install"
	@echo "    uninstall"
	@echo "    clean"
	@echo
