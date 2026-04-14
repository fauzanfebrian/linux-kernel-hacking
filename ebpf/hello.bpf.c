#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "GPL";

SEC("tracepoint/syscalls/sys_enter_execve")
int hello(void *ctx)
{
    bpf_printk("Hello, World!\n");
    return 0;
}