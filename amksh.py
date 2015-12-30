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
    return line.split("#")[0].strip()

def import_file(src_fname, dst_string):
    src_filename = "modules/" \
        + src_fname.replace(".", "/").replace("\n", "").replace("\r", "") \
        + ".mamk"
    f = open(src_filename, "r")
    lines = f.readlines()
    f.close()

    flag = 0
    totline = 0
    for line in lines:
        if simple_line(line) == "AXIOM":
            flag = 1
        elif simple_line(line) == "THEOREM":
            flag = 2
        elif flag == 1:
            dst_string += line
#            dst_file.write(line)
            totline += 1
    return (totline, dst_string)

def check_file(filename):
    print "==================="

    if not os.path.isfile(filename):
        print "%s is not a valid file!" % (filename)
        return

    print "checking file `" + filename + "` ...",

    codefile = open(filename, "r")
    codelines = codefile.readlines()
    codefile.close()

    dst_string = ""
#    tmpfile = open(".amk/curr.amk", "w")

    lineoff = 0
    for line in codelines:
        if line.split(" ")[0] == "import":
            dst_string += line
            (delta, new_dst_string) = import_file(line.split(" ")[1], dst_string)
            lineoff += delta 
            dst_string = new_dst_string
#            lineoff += import_file(line.split(" ")[1], tmpfile) - 1
        else:
            dst_string += line
#            tmpfile.write(line)

#    tmpfile.close()
#    tmpfile = open(".amk/curr.amk", "r")

#    result = subprocess.check_output(["src/amki", str(lineoff)], stdin=tmpfile, stderr=subprocess.STDOUT)
    p = subprocess.Popen(['./src/amki',str(lineoff)], stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    p.stdin.write(dst_string)
    (res_out, res_err) = p.communicate()

    print " done\n"
    
    print res_out
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

