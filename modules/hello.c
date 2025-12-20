#include <linux/init.h>
#include <linux/module.h>
#include <linux/printk.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>

static int major_number;
static dev_t hello_dev_number;

static struct cdev hello_cdev;

/* * The "GET" Handler
 * file  = The connection context
 * buf   = The client's response buffer (User Space Memory!)
 * count = How many bytes the client wants (Content-Length)
 * ppos  = The cursor position (Offset)
 */
ssize_t hello_read(struct file* file, char __user* buf, size_t count, loff_t* ppos) {
    char greet[] = "Hello World!\n";
    int msg_len = 14;
    int bytes_to_copy;

    if (*ppos >= msg_len) {
        return 0;
    }

    bytes_to_copy = msg_len - *ppos;
    if (bytes_to_copy > count) {
        bytes_to_copy = count;
    }

    if (copy_to_user(buf, greet + *ppos, bytes_to_copy)) {
        return -EFAULT;
    }

    *ppos += bytes_to_copy;

    return bytes_to_copy;
}

static struct file_operations hello_fops = {
    .owner = THIS_MODULE,
    .read = hello_read,
};

static int __init hello_init(void) {
    pr_info("Hello, World!\n");

    int result;

    result = alloc_chrdev_region(&hello_dev_number, 0, 1, "helloworld");
    if (result < 0) {
        return result;
    }
    major_number = MAJOR(hello_dev_number);

    cdev_init(&hello_cdev, &hello_fops);

    result = cdev_add(&hello_cdev, hello_dev_number, 1);

    if (result < 0) {
        unregister_chrdev_region(hello_dev_number, 1);
        return result;
    }
    pr_info("helloworld: Registered with major %d\n", major_number);

    return 0;
}

static void __exit hello_exit(void) {
    pr_info("Goodbye, World!\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
