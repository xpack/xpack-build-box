
The `dispatch/object.h` requires a small patch:

```
$ sudo vi /usr/include/dispatch/object.h

#if OS_OBJECT_USE_OBJC
typedef void (^dispatch_block_t)(void);
#else
typedef void (*dispatch_block_t)(void);
#endif

```

