# Void Box (`/dev/voidbox`)

Challenger: Gemini 3.0
* **Status:** Draft / In-Progress
* **Target:** Linux Kernel 6.17.7 (UML)
* **Difficulty:** Low-Level Entry

## 🎯 Objective
Create a "Read-Once" secure drop-box character device driver. The device allows User Space processes to write data into Kernel Memory. When read, the data is returned to User Space and immediately **incinerated** (zeroed out) from Kernel Memory.

This project enforces the "Holy Trinity" of Kernel Hacking:
1.  **Device Registration** (`cdev` interface).
2.  **User/Kernel Boundary** (`copy_to_user` / `copy_from_user`).
3.  **Concurrency Control** (Preventing race conditions with Mutexes).

## 🛠️ Specifications

| Feature         | Requirement                                  |
| :---             | :---                                        |
| **Module Name** | `voidbox.ko`                                 |
| **Device Node** | `/dev/voidbox`                               |
| **Device Type** | Character Device                             |
| **Buffer Size** | Fixed (e.g., 1024 bytes)                     |
| **Concurrency** | Thread-safe (Must use `mutex` or `spinlock`) |

### 1. The `write` Operation
* **Input:** Accepts a string/data from User Space.
* **Behavior:**
    1.  Acquire Lock.
    2.  Copy data from User Space -> Kernel Buffer.
    3.  Store the length of data.
    4.  Release Lock.
* **Edge Cases:** Handle buffer overflow (truncate or return error).

### 2. The `read` Operation
* **Input:** A read request from User Space.
* **Behavior:**
    1.  Acquire Lock.
    2.  Check if data exists.
    3.  Copy data from Kernel Buffer -> User Space.
    4.  **Self-Destruct:** Overwrite the Kernel Buffer with `0x00` (memset).
    5.  Reset data length to 0.
    6.  Release Lock.
* **Return:** Number of bytes read (or 0 if empty/EOF).

## 🧪 Verification Protocol (The Test)

The driver is successful only if it passes the "Spy Exchange" test inside the UML environment:

```bash
# 1. Load the module (via HostFS)
insmod /mnt/modules/voidbox/voidbox.ko

# 2. Fix permissions (if udev is not configured)
chmod 666 /dev/voidbox

# 3. The Drop (Terminal 1)
echo "The Void Stares Back" > /dev/voidbox

# 4. The Retrieval (Terminal 2)
cat /dev/voidbox
# Output: "The Void Stares Back"

# 5. The Evidence Check (Terminal 2)
cat /dev/voidbox
# Output: (Empty/Nothing) -> SUCCESS
```

## 🚫 Constraints & Rules

1. **No AI Copy-Paste:** You may use AI to find header files (e.g., "Where is `mutex_init` defined?"), but you must write the logic yourself.
2. **Build for UML:** Ensure your `Makefile` handles `ARCH=um` correctly so the module loads in your User-Mode Linux instance.
3. **Crash Test:** Intentionally remove the `mutex_lock` and run two writer scripts simultaneously. Watch the data corruption (or crash) in GDB to understand *why* locking matters.

## 📚 Required Resources

* **Headers:** `<linux/fs.h>`, `<linux/uaccess.h>`, `<linux/mutex.h>`, `<linux/module.h>`
* **Reference:** *Linux Device Drivers 3*, Chapter 3 (Char Drivers).
* **Kernel Source:** Check `linux-6.17.7/include/linux/uaccess.h` for the latest API definitions.