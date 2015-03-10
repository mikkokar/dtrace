#!/usr/sbin/dtrace -qs

dtrace:::BEGIN
{
        printf("Tracing for process $1 ... Hit Ctrl-C to end.\n");
}

hotspot*:::method-entry
{
        this->class = (char *) copyin(arg1, arg2 + 1);
        this->class[arg2] = '\0';
        this->method = (char *) copyin(arg3, arg4 + 1);
        this->method[arg4] = '\0';
        printf("%d %s.%s\n", arg0, stringof(this->class), stringof(this->method));
}

