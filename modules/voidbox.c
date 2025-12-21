#include <linux/init.h>
#include <linux/module.h>
#include <linux/printk.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/mutex.h>

#define DEVICE_NAME "voidbox"
#define BUF_SIZE 1024

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Fauzan");
MODULE_DESCRIPTION("A Read-Once Secure Drop-Box");

struct voidbox_dev {
    char data[BUF_SIZE];
    unsigned long len;
    struct mutex lock;
    struct cdev cdev;
};

static int major_number;
static struct voidbox_dev void_device;

ssize_t voidbox_read(struct file* file, char __user* buf, size_t count, loff_t* ppos) {
    mutex_lock(&void_device.lock);

    int bytes_to_copy;

    if (void_device.len < 1) {
        mutex_unlock(&void_device.lock);
        return 0;
    }

    if (*ppos >= void_device.len) {
        mutex_unlock(&void_device.lock);
        return 0;
    }

    bytes_to_copy = void_device.len - *ppos;
    if (bytes_to_copy > count) {
        bytes_to_copy = count;
    }

    if (copy_to_user(buf, void_device.data + *ppos, bytes_to_copy)) {
        mutex_unlock(&void_device.lock);
        return -EFAULT;
    }

    *ppos += bytes_to_copy;

    void_device.data[0] = '\0';
    void_device.len = 0;

    mutex_unlock(&void_device.lock);

    return bytes_to_copy;
}

ssize_t voidbox_write(struct file* file, const char __user* buf, size_t count, loff_t* ppos) {
    mutex_lock(&void_device.lock);

    if (void_device.len > 0) {
        mutex_unlock(&void_device.lock);
        return -EBUSY;
    }

    int bytes_to_copy = (int)count;
    if (bytes_to_copy > BUF_SIZE) {
        bytes_to_copy = (int)BUF_SIZE;
    }

    if (copy_from_user(void_device.data, buf, bytes_to_copy)) {
        mutex_unlock(&void_device.lock);
        return -EFAULT;
    }

    void_device.len = bytes_to_copy;

    mutex_unlock(&void_device.lock);
    return bytes_to_copy;
}

static struct file_operations void_ops = {
    .owner = THIS_MODULE,
    .read = voidbox_read,
    .write = voidbox_write,
};

static int __init voidbox_init(void) {
    int ret;
    dev_t dev_num;

    // 1. Dynamic Major Number Allocation
    ret = alloc_chrdev_region(&dev_num, 0, 1, DEVICE_NAME);
    if (ret < 0) {
        printk(KERN_ALERT "Voidbox: Failed to allocate major number\n");
        return ret;
    }
    major_number = MAJOR(dev_num);

    mutex_init(&void_device.lock);

    cdev_init(&void_device.cdev, &void_ops);
    void_device.cdev.owner = THIS_MODULE;

    ret = cdev_add(&void_device.cdev, dev_num, 1);
    if (ret < 0) {
        unregister_chrdev_region(dev_num, 1);
        return ret;
    }

    pr_info("Voidbox: Registered with Major %d\n", major_number);
    return 0;
}

static void __exit voidbox_exit(void) {
    dev_t dev_num = MKDEV(major_number, 0);

    cdev_del(&void_device.cdev);
    unregister_chrdev_region(dev_num, 1);

    printk(KERN_INFO "Voidbox: Unloaded into the void.\n");
}

module_init(voidbox_init);
module_exit(voidbox_exit);
