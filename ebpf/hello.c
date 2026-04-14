#include <stdio.h>
#include <unistd.h>
#include <bpf/libbpf.h>
#include "hello.skel.h"

int main(void)
{
    struct hello_bpf *skel = hello_bpf__open_and_load();
    if (!skel)
        return 1;

    if (hello_bpf__attach(skel))
        return 1;

    puts("attached!");

    for (;;)
        sleep(1);
}