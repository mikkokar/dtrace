#!/usr/bin/python

"""
A post processing tool for jmem.d. Shows the Java object allocations
per thread, followed by per-thread summary.

Takes two arguments:

arg1: Output from jmem.d.

arg2: A thread map file, which describes a symbolic name for each
      thread id. For example:

	Reference Handler id=2
	Finalizer id=3
	Signal Dispatcher id=5

"""

import sys
import re

__author__ = 'Mikko Karjalainen'


class AllocRecord(object):
    def __init__(self, thread_id, class_name, size):
        self.thread_id = thread_id
        self.class_name = class_name
        self.size = size


def parse(line):
    try:
        fields = line.split()
        thread_id = int(fields[0])
        class_name = fields[1]
        size = int(fields[3])
        return AllocRecord(thread_id, class_name, size)
    except:
        return None


def resolve_thread_name(thread_map, thread_id):
    try:
        return thread_map[thread_id]
    except IndexError:
        pass
    return ""


def print_alloc_per_thread_summary(records, name_resolver):

    class Summary(object):
        def __init__(self, thread_id):
            self.thread_id = thread_id
            self.alloc_count = 0
            self.total_mem = 0

        def alloc(self, bytes):
            self.alloc_count += 1
            self.total_mem += bytes

    per_thread = {}

    for record in records:
        try:
            summary = per_thread[record.thread_id]
        except KeyError:
            summary = Summary(record.thread_id)
            per_thread[record.thread_id] = summary

        summary.alloc(record.size)

    thread_ids = per_thread.keys()
    thread_ids.sort()

    print("")
    print("Allocation summary per thread:")

    for tid in thread_ids:
        summary = per_thread[tid]
        print("%3d %-40s %5d allocations %6d bytes in total" % (
            summary.thread_id,
            resolver(summary.thread_id),
            summary.alloc_count,
            summary.total_mem))


def main(mem_trace, name_resolver):
    ifh = open(mem_trace)
    lines = ifh.readlines()
    ifh.close()

    records = [record for record in [parse(line) for line in lines] if record != None]

    i = 1
    for record in records:
        thread_name = name_resolver(record.thread_id)
        print("%5d. %3d %-40s %5d <- %s" % (i, record.thread_id, thread_name, record.size, record.class_name))
        i+= 1

    print_alloc_per_thread_summary(records, name_resolver)



def thread_name_resolver(thread_map_file):
    thread_resolver_map = {}

    ifh = open(thread_map_file)
    lines = ifh.readlines()
    ifh.close()

    for line in lines:
        mo = re.match("^(.*) id=([0-9]+).*$", line)
        if mo == None:
            continue
        else:
            thread_name = mo.group(1)
            thread_id = int(mo.group(2))
            thread_resolver_map[thread_id] = thread_name

    def resolver(id):
        try:
            return thread_resolver_map[id]
        except KeyError:
            return ""

    return resolver


if __name__ == "__main__":
    mem_trace = sys.argv[1]

    thread_map = sys.argv[2]
    resolver = thread_name_resolver(thread_map)

    main(mem_trace, resolver)
