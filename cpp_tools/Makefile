CXX = g++
CPPFLAGS = -I. -O3
LDFLAGS = -L. -lgzstream -lz
AR = ar cr
default: parse_stlfr
gzstream.o : gzstream.C gzstream.h
	${CXX} ${CPPFLAGS} -c -o gzstream.o gzstream.C
libgzstream.a : gzstream.o
	${AR} libgzstream.a gzstream.o
parse_stlfr : parse_stlfr.cpp gzstream.h libgzstream.a
	${CXX} -o parse_stlfr parse_stlfr.cpp gzstream.h ${LDFLAGS}
clean:
	rm -f *.o libgzstream.a parse_stlfr