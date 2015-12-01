#!/usr/bin/python

import subprocess
import os
import argparse
from sys import argv

def enter():
    print "Compiling ...",
    subprocess.call(["(cd src; make)"], shell=True)
    print " done."

def simple_line(line):
    return line.split("#")[0].rstrip()

def import_file(src_fname, dst_file):
    src_filename = "modules/" \
        + src_fname.replace(".", "/").replace("\n", "").replace("\r", "") \
        + ".mamk"
    f = open(src_filename, "r")
    lines = f.readlines()
    f.close()

    flag = 0
    for line in lines:
        if simple_line(line) == "AXIOM":
            flag = 1
        elif simple_line(line) == "THEOREM":
            flag = 2
        elif flag == 1:
            dst_file.write(line)

def check_file(filename):
    print "==================="

    if not os.path.isfile(filename):
        print "%s is not a valid file!" % (filename)
        return

    print "checking file `" + filename + "` ...",

    codefile = open(filename, "r")
    codelines = codefile.readlines()
    codefile.close()

    tmpfile = open(".amk/curr.amk", "w")

    for line in codelines:
        if line.split(" ")[0] == "import":
            import_file(line.split(" ")[1], tmpfile)
        else:
            tmpfile.write(line)

    tmpfile.close()
    tmpfile = open(".amk/curr.amk", "r")
    
    result = subprocess.check_output(["src/amki"], stdin=tmpfile, stderr=subprocess.STDOUT)

    print " done\n"
    tmpfile.close()
    
    print result
    print "==================="

def exit():
    print "Exiting ...",
    subprocess.call(["(cd src; make clean)"], shell=True)
    print " done."

if __name__ == "__main__":
    enter()
    
    parser = argparse.ArgumentParser(description='AMK (Anti-Min-Ke) Project Interpreter 0.5')
    parser.add_argument("filename", metavar="filename", type=str, nargs='+', \
            help="The name of the '.amk' file you want to check the correctness of.")
    args = parser.parse_args()
    for fn in args.filename:
        check_file(fn)

#    exit()
