#!/usr/bin/python

import subprocess
import os
import argparse
from sys import argv

def enter():
    print "Compiling ...",
    subprocess.call(["(cd src; make)"], shell=True)
    print " done."

def check_file(filename):
    print "==================="
    if not os.path.isfile(filename):
        print "%s is not a valid file!" % (filename)
        return
    print "checking file `" + filename + "` ...",
    codefile = open(filename, "r")
    result = subprocess.check_output(["src/amki"], stdin=codefile, stderr=subprocess.STDOUT)
    codefile.close()
    print " done\n"
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
