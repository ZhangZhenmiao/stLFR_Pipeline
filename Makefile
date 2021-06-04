default: correct_barcode_stlfr
correct_barcode_stlfr:
	g++ -O3 -o correct_barcode_stlfr correct_barcode_stlfr.cpp -lhts 
clean:
	rm -f correct_barcode_stlfr
