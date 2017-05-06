#include <linux/module.h> /* Needed by all modules */
#include <linux/kernel.h> /* Needed for KERN_INFO  */
#include <linux/slab.h>   /* Needed for kmalloc    */

extern void adakernelmoduleinit (void);
//extern void adakernelmodulefinal (void);

extern void ada_foo(void);

void *nix;

void print_kernel(char* s)
{
  printk(KERN_ERR "%s\n", s);
}

int init_module(void)
{
  ssize_t maxV = -1; /*((ssize_t)0);*/
  int IV = (int)maxV;
  
    nix = kmalloc(8, GFP_KERNEL);
    
    adakernelmoduleinit();
    printk(KERN_ERR "Hello Ada.\n");
    ada_foo();
 
    return 0;
}


void cleanup_module(void)
{

  kfree (nix);
    //adakernelmodulefinal();
    printk(KERN_ERR "Goodbye Ada.\n");
}


//module_init(init_module);
//module_exit(cleanup_module);
