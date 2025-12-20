# Linux Module HTTP Router

> This logs is to documenting a **Char Device Driver** intended as a training to answer the [#1 Challenge](../challenges/create-voidbox-module.md). I called it HTTP Router is just becaused I came from web development, that's the common and easy term for me to understand it.

## The Anatomy

* **API Endpoint**: This is where we reserve a Device ID (Major/Minor numbers) so the Kernel knows our driver exists. This does not create the file node yet.
    - For registering it, we will use: `alloc_chrdev_region(dev_t *ptr_to_device_number, unsigned int first_minor_number, unsigned int total_minor, char *module_name)`
    - It will injecting a device number to `ptr_to_device_number` and then we can convert it to get a major number `MAJOR(hello_dev_number)`
* **The Controller**: When a user triggerred the "Endpoint", it will be handled by `file_operations`. This is where Driver Logic is registered, available operations:
    - **owner**: The first file_operations field is not an operation at all; it is a pointer to the module that “owns” the structure.
    - **llseek**: The llseek method is used to change the current read/write position in a file, and the new position is returned as a (positive) return value.
    - **read**: Used to retrieve data from the device. It's when a user trying to read from our endpoint.
    - **write**: Sends data to the device. The opposite from read, it's when a user trying to inject a data to our endpoint.
    - **ioctl**: The ioctl system call offers a way to issue device-specific commands (such as formatting a track of a floppy disk, which is neither reading nor writing).
* **HTTP Server**: The Kernel is the HTTP Server. `cdev_init` and `cdev_add` is effectively app.listen(). It tells the Kernel (Server) to start accepting traffic for your specific Device ID (Port) and route it to your fops (Controller).

### Key Terminology

* Major Number: The Driver ID (Protocol/Port).
* Minor Number: The Instance ID (Specific Device).
* User/Kernel Boundary: The line crossed when copy_to_user is called.

## Usage

1. Build: You should rebuild the kernel using `make build` and there's two types of linux kernel module build output:

    * **Built-In**
    * **Loadable**

2. Run: Run the kernel using `make run`. If you use the Built-In, after you run `make run` you should find a log contain `helloworld: Registered with major "$majornumber"`.

3. Expose (Create Node): Since alloc_chrdev_region only reserved the number, we must manually create the "Public URL" (File Node):

    ```sh
    mknod /dev/helloworld c $majornumber 0
    chmod 666 /dev/helloworld
    ```

4. Test:
    ```sh
    cat /dev/helloworld
    ```


## Code Example

I wrote a simple example for Char Drivers at [hello.c](../../modules/hello.c), please check it out!!