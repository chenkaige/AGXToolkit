# AGXRuntime

运行时工具代码.

##### Components

- AGXProtocol

    运行时 - 协议对象.

```objectivec
+allProtocols

+protocolWithObjCProtocol:
+protocolWithName:

-initWithObjCProtocol:
-initWithName:

-objCProtocol
-name
-incorporatedProtocols
-methodsRequired:instance:
```

- AGXIvar

    运行时 - 实例变量对象.

```objectivec
+ivarWithObjCIvar:
+instanceIvarWithName:inClass:
+classIvarWithName:inClass:
+instanceIvarWithName:inClassNamed:
+classIvarWithName:inClassNamed:
+ivarWithName:typeEncoding:
+ivarWithName:encode:

-initWithObjCIvar:
-initInstanceIvarWithName:inClass:
-initClassIvarWithName:inClass:
-initInstanceIvarWithName:inClassNamed:
-initClassIvarWithName:inClassNamed:
-initWithName:typeEncoding:

-name
-typeName
-typeEncoding
-offset
```

- AGXProperty

    运行时 - 属性对象.

```objectivec
+propertyWithObjCProperty:
+propertyWithName:inClass:
+propertyWithName:inClassNamed:
+propertyWithName:attributes:

-initWithObjCProperty:
-initWithName:inClass:
-initWithName:inClassNamed:
-initWithName:attributes:

-property
-attributes
-addToClass:

-attributeEncodings
-isReadOnly
-isNonAtomic
-isWeakReference
-isEligibleForGarbageCollection
-isDynamic
-memoryManagementPolicy
-getter
-setter
-name
-ivarName
-typeName
-typeEncoding
-objectClass

// 属性内存策略枚举
AGXPropertyMemoryManagementPolicy
```

- AGXMethod

    运行时 - 方法对象.

```objectivec
+methodWithObjCMethod:
+instanceMethodWithName:inClass:
+classMethodWithName:inClass:
+instanceMethodWithName:inClassNamed:
+classMethodWithName:inClassNamed:
+methodWithSelector:implementation:signature:

-initWithObjCMethod:
-initInstanceMethodWithName:inClass:
-initClassMethodWithName:inClass:
-initInstanceMethodWithName:inClassNamed:
-initClassMethodWithName:inClassNamed:
-initWithSelector:implementation:signature:

-selector
-selectorName
-implementation
-setImplementation:
-signature
-purifiedSignature // 仅含类型编码
```

##### Categories

- NSObject+AGXRuntime

```objectivec
// 运行时工具方法, 返回的运行时对象(列表)仅限于当前类, 不包含父类定义的运行时对象(列表).
+agxProtocols
+enumerateAGXProtocolsWithBlock:
-agxProtocols
-enumerateAGXProtocolsWithBlock:

+agxIvars
+agxIvarForName:
+enumerateAGXIvarsWithBlock:
-agxIvars
-agxIvarForName:
-enumerateAGXIvarsWithBlock:

+agxProperties
+agxPropertyForName:
+enumerateAGXPropertiesWithBlock:
-agxProperties
-agxPropertyForName:
-enumerateAGXPropertiesWithBlock:

+agxInstanceMethods
+agxInstanceMethodForName:
+enumerateAGXInstanceMethodsWithBlock:
-agxInstanceMethods
-agxInstanceMethodForName:
-enumerateAGXInstanceMethodsWithBlock:

+agxClassMethods
+agxClassMethodForName:
+enumerateAGXClassMethodsWithBlock:
-agxClassMethods
-agxClassMethodForName:
-enumerateAGXClassMethodsWithBlock:

+respondsToAGXClassMethodForName:
-respondsToAGXInstanceMethodForName:

+performAGXClassMethodForName:
+performAGXClassMethodForName:withObject:
+performAGXClassMethodForName:withObjects:
+performAGXClassMethodForName:withObjectsArray:
-performAGXInstanceMethodForName:
-performAGXInstanceMethodForName:withObject:
-performAGXInstanceMethodForName:withObjects:
-performAGXInstanceMethodForName:withObjectsArray:
```

- UIViewController+AGXRuntime

```objectivec
// 激活此Category后, UIViewController的子类将自动按照其覆盖声明的主view属性类型, 创建UIView子类的对象, 并自动注入控制器的主view属性.
@interface XView : UIView
@end
@implementation XView
@end

@interface XViewController : UIViewController
@property (nonatomic, strong) XView* view;
@end
@implementation XViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.view.class); // OUTPUT: XView
}
@end
```
