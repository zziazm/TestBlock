# TestBlock
## 为什么外部变量加上__blcok之后就可以在block内部进行修改。 
通过clang把OC重写成C++来看一下__block究竟做了什么。
1.先看一下没有使用__block的非对象变量：
```
int main () {
    int num = 1;
    void (^aBlock) (void) = ^{
        printf(" 输出 num == %d", num);
    };
    aBlock();
    return 0;
}
```
重写完后的代码很多，挑主要的部分展示一下：
```
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int num = __cself->num; // bound by copy
  printf(" 输出 num == %d", num);
}

int main () {
    int num = 1;
    void (*aBlock) (void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, num));
    ((void (*)(__block_impl *))((__block_impl *)aBlock)->FuncPtr)((__block_impl *)aBlock);
    return 0;
}
```
__main_block_func_0这个函数里对应的是OC的block的{}的代码。从`  int num = __cself->num; // bound by copy`这里看以看出，之所以不能修改外部变量，是因为block里面使用的num是一个新定义的num，它是值拷贝，我们无法通过它修改外部的变量。在OC里面如果修改的话编译器也会直接报错。

接下来看一下加上__block之后的效果：
```
int main () {
    __block int num = 1;
    printf("输出前 num == %p", &num);
    void (^aBlock) (void) = ^{
        num ++;
        printf("输出中 num == %p", &num);
    };
    aBlock();
    printf("输出后 num == %p", &num);
    return 0;
}
```
把它重写之后的主要代码：
```
struct __Block_byref_num_0 {
    void *__isa;
    __Block_byref_num_0 *__forwarding;
    int __flags;
    int __size;
    int num;
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    __Block_byref_num_0 *num = __cself->num; // bound by ref
    
    (num->__forwarding->num) ++;
    printf("输出中 num == %p", &(num->__forwarding->num));
}

int main () {
    __attribute__((__blocks__(byref))) __Block_byref_num_0 num = {(void*)0,(__Block_byref_num_0 *)&num, 0, sizeof(__Block_byref_num_0), 1};
    printf("输出前 num == %p", &(num.__forwarding->num));
    void (*aBlock) (void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_num_0 *)&num, 570425344));
    ((void (*)(__block_impl *))((__block_impl *)aBlock)->FuncPtr)((__block_impl *)aBlock);
    printf("输出后 num == %p", &(num.__forwarding->num));
    return 0;
}
```
首先可以看到，加上__block之后的外部变量，重写之后main函数里第一行不再是`int num = 1`,而是定义了一个 `__Block_byref_num_0 num = ...`结构体，并且初始化时这个结构体的forwad是指向它自己的，我们定义的int 值存在了结构体的成员变量num里面。

再看一下这里的`__main_block_func_0`这个函数里，它里面不再像没有加__block那样新定义一个`int num`，而是新定义了一个指针`__Block_byref_num_0 *num`，在OC里面的a++在这里被重写成了```(num->__forwarding->num) ++```;也就是说它是通过指针实现了修改外部变量。

接下来在MRC和ARC环境下分别运行下面的代码：
```
    __block int num = 1;
    printf("输出前 num == %p\n", &num);
    void (^aBlock) (void) = ^{
        num ++;
        printf("输出中 num == %p\n", &num);
    };
    aBlock();
    printf("输出后 num == %p\n", &num);
```
MRC下打印出来的三个地址是一样的：
```
输出前 num == 0x7fff547606c8
输出中 num == 0x7fff547606c8
输出后 num == 0x7fff547606c8
```
而ARC下打印的地址后两个是一样的：
```
输出前 num == 0x7fff547606c8
输出中 num == 0x604000431018
输出后 num == 0x604000431018
```
MRC下上面的aBlock和num都是在栈上的，结构体的__forwarding指针始终指向它自己，所以三个地址打印出来的是一样的。
![[图片上传中...(1194012-5f5f486bab68191f.jpg-795226-1523414501068-0)]
](https://upload-images.jianshu.io/upload_images/1311714-e3ddb5a37855c89d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在ARC下，上面的aBlock是在堆上的，而num也会从栈上copy到对上，而原来在栈上的结构体__forwarding指针会指向在堆上的结构体，这时打印的地址是在堆上的num的地址。

![1194012-5f5f486bab68191f.jpg](https://upload-images.jianshu.io/upload_images/1311714-df1a0a37931cf772.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2.再来看一下外部对象变量：
```
NSObject *obj = [[NSObject alloc] init];
        NSLog(@"%@, %p", obj, &obj);
        void (^aBlock)(void) = ^{
            NSLog(@"%@, %p", obj, &obj);
        };
        aBlock();
        NSLog(@"%@, %p", obj, &obj);
```
重写之后的代码block里面的实现：
```
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    NSObject *obj = __cself->obj; // bound by copy
    
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_mn_jp2_90d16qb5m5_bbpyfj_8h0000gn_T_main_4c9416_mi_1, obj, &obj);
}

int main(int argc, char * argv[]) {

    NSObject *obj = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init"));
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_mn_jp2_90d16qb5m5_bbpyfj_8h0000gn_T_block3_e8baad_mi_0, obj, &obj);
    void (*aBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, obj, 570425344));
    ((void (*)(__block_impl *))((__block_impl *)aBlock)->FuncPtr)((__block_impl *)aBlock);
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_mn_jp2_90d16qb5m5_bbpyfj_8h0000gn_T_block3_e8baad_mi_2, obj, &obj);
    return 0;

}
```
可以看出来，block里的obj对象是新定义的一个指针，因此不能够通过修改它来修改外部的obj，所以在block里不能够修改obj的值。

再看一下加上__block之后的代码：
```
 __block NSObject *obj = [[NSObject alloc] init];
    void (^aBlock)(void) = ^{
        obj = [[NSObject alloc] init];
        NSLog(@"%@, %p", obj, &obj);
    };
    aBlock();
```
重写之后的代码：
```
struct __Block_byref_obj_0 {
  void *__isa;
__Block_byref_obj_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 NSObject *obj;
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
 __Block_byref_obj_0 *obj = __cself->obj; // bound by ref    (obj->__forwarding->obj) = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init"));
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_mn_jp2_90d16qb5m5_bbpyfj_8h0000gn_T_block4_6564ec_mi_1, (obj->__forwarding->obj), &(obj->__forwarding->obj));
}


int main(int argc, char * argv[]) {
    __attribute__((__blocks__(byref))) __Block_byref_obj_0 obj = {(void*)0,(__Block_byref_obj_0 *)&obj, 33554432, sizeof(__Block_byref_obj_0), __Block_byref_id_object_copy_131, __Block_byref_id_object_dispose_131, ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init"))};
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_mn_jp2_90d16qb5m5_bbpyfj_8h0000gn_T_block4_6564ec_mi_0, (obj.__forwarding->obj), &(obj.__forwarding->obj));
    void (*aBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_obj_0 *)&obj, 570425344));
    ((void (*)(__block_impl *))((__block_impl *)aBlock)->FuncPtr)((__block_impl *)aBlock);
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_mn_jp2_90d16qb5m5_bbpyfj_8h0000gn_T_block4_6564ec_mi_2, (obj.__forwarding->obj), &(obj.__forwarding->obj));
    return 0;
}
```
从上面可以看出，加上__block之后，对象obj会被编译成一个结构体`__Block_byref_obj_0  obj`，并且在block的实现里面` __Block_byref_obj_0 *obj = __cself->obj`使用一个新的结构体指针引，通过这个结构体指针就可以访问到结构体里存储的obj对象并进行修改。
