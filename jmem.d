#!/usr/sbin/dtrace -qs

/*
 * To use, need to activate extended Java DTrace probes:
 *
 * -XX:+ExtendedDTraceProbes
 */

dtrace:::BEGIN
{
    printf("Tracing for process $1 ... Hit Ctrl-C to end.\n");
}

hotspot$1:::object-alloc
{
  this->method = (char *)copyin(arg1, arg2 + 1);
  this->method[arg2] = '\0';

  printf("%d %s -> %d\n", arg0, stringof(this->method), arg3);
}

