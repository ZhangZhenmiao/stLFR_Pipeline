#include "cmdline.h"
#include "gzstream.h"
#include <string>
#include <vector>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <algorithm>

int main(int argc, char *argv[])
{
    cmdline::parser argParser;
    argParser.add("number", 'n', "Barcode as index numbers");
    argParser.add("library", 'l', "Add library after barcode");
    argParser.add<std::string>("bc_white", 'b', "Path to barcode whitelist (needed if -n is not specified)", false, "stLFR_read_demux/scripts/barcode.list");
    argParser.add<std::string>("reads1", '1', "Path to reads1 (gzipped)", true, "");
    argParser.add<std::string>("reads2", '2', "Path to reads2 (gzipped)", true, "");
    argParser.add<std::string>("output", 'o', "Prefix to output", true, "");
    argParser.parse_check(argc, argv);

    std::string reads1 = argParser.get<std::string>("reads1");
    std::string reads2 = argParser.get<std::string>("reads2");
    std::string bc_white = argParser.get<std::string>("bc_white");
    std::string output = argParser.get<std::string>("output");
    bool number = argParser.exist("number");
    bool library = argParser.exist("library");
    std::vector<std::string> barcodes;

    std::string line;
    std::vector<std::string> barcodeList;
    if (!number)
    {
        std::fstream barcodeListf(bc_white, std::fstream::in);
        while (getline(barcodeListf, line))
            barcodeList.push_back(line.substr(0, line.find_first_of('\t')));
        barcodeListf.close();
    }

    igzstream reads1f(reads1.c_str());
    igzstream reads2f(reads2.c_str());
    std::ofstream interleaved_out((output + "_interleaved.fq").c_str());
    std::string line1, line2, tmp_memory, tmp_memory1, tmp_memory2;;
    bool is_pair = true;
    unsigned long long cnt_line = 0, cnt_unpaired = 0;
    std::cout << "Start parsing reads ..." << std::endl;
    while (getline(reads1f, line1))
    {
        getline(reads2f, line2);
        if (cnt_line % 4 == 0)
        {
            if (is_pair && !tmp_memory1.empty() && !tmp_memory2.empty())
                tmp_memory += (tmp_memory1 + tmp_memory2);
            tmp_memory1.clear();
            tmp_memory2.clear();
            if (cnt_line % 40000 == 0 && !tmp_memory.empty())
            {
                interleaved_out << tmp_memory;
                tmp_memory.clear();
            }
            if (cnt_line % 40000000 == 0)
                std::cout << "\rParsed " << cnt_line / 4 << " read pairs (" << cnt_unpaired << " unpaired)." << std::flush;

            std::size_t pos1 = line1.find_first_of('#');
            std::size_t pos2 = line1.find_first_of('/', pos1 + 1);
            std::string identifier1, identifier2, barcode, barcode_trans, bc1, bc2, bc3;
            identifier1 = line1.substr(0, pos2);
            identifier2 = line2.substr(0, pos2);
            is_pair = true;
            if (identifier1.compare(identifier2))
            {
                is_pair = false;
                cnt_unpaired++;
            }
            
            barcode = line1.substr(pos1 + 1, pos2 - pos1 - 1);
            std::size_t i = 0;
            while (barcode.at(i) != '_')
                bc1 += barcode.at(i++);
            while (barcode.at(++i) != '_')
                bc2 += barcode.at(i);
            while (++i < barcode.size())
                bc3 += barcode.at(i);
            if (bc1.compare("0") && bc2.compare("0") && bc1.compare("0"))
            {
                if (!number)
                    barcode_trans = barcodeList[atoi(bc1.c_str()) - 1] + barcodeList[atoi(bc2.c_str()) - 1] + barcodeList[atoi(bc3.c_str()) - 1];
                else
                    barcode_trans = barcode;
            }
            if (barcode_trans.empty())
            {
                tmp_memory1 += (identifier1 + '\n');
                tmp_memory2 += (identifier2 + '\n');
            }
            else
            {
                if (library)
                    barcode_trans += "-1";
                tmp_memory1 += (identifier1 + "\tBX:Z:" + barcode_trans + '\n');
                tmp_memory2 += (identifier2 + "\tBX:Z:" + barcode_trans + '\n');
            }
        }
        else
        {
            tmp_memory1 += (line1 + '\n');
            tmp_memory2 += (line2 + '\n');
        }
        cnt_line += 1;
    }
    if (is_pair && !tmp_memory1.empty() && !tmp_memory2.empty())
        tmp_memory += (tmp_memory1 + tmp_memory2);
    tmp_memory1.clear();
    tmp_memory2.clear();
    if (!tmp_memory.empty())
    {
        interleaved_out << tmp_memory;
        tmp_memory.clear();
    }
    std::cout << "\rParsed " << cnt_line / 4 << " read pairs (" << cnt_unpaired << " unpaired)." << std::endl;
    reads1f.close();
    reads2f.close();
    interleaved_out.close();
    return 0;
}
