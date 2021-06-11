CXX = g++
CPPFLAGS = -I. -O3
LDFLAGS = -L. -lgzstream -lz -lhts
AR = ar cr
default: correct_barcode_stlfr
gzstream.o : gzstream.C gzstream.h
	${CXX} ${CPPFLAGS} -c -o gzstream.o gzstream.C
libgzstream.a : gzstream.o
	${AR} libgzstream.a gzstream.o
correct_barcode_stlfr: correct_barcode_stlfr.cpp libgzstream.a
	${CXX} ${CPPFLAGS} correct_barcode_stlfr.cpp -o correct_barcode_stlfr ${LDFLAGS}
