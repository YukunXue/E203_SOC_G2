E203有俩块总线曲线区域

Ⅰ.外设 axi （桥接出来不可用？缺少相应的底层驱动函数？）

Ⅱ.存储 axi

测试1：对相应的地址写值（未引出相应的axi接口）

对于Ⅰ类总线 写值地址 0x4000_0000 写入0x1004_0000（有delay_1ms(100)）再读，无反应——>值为0

对于Ⅱ类总线 写值地址 0x1004_0000 写入 0x1004_0000 （有delay_1ms(100)）再读相应的地址，数值仍为 0x1004_0000



猜测：系统总线ICB和存储总线ICB 不一样，不可以混用？



Ⅲ . ila 挂不了，没办法调试



目前问题比较像的是![image-20220918154022774](C:\Users\XueYK\AppData\Roaming\Typora\typora-user-images\image-20220918154022774.png)

https://www.rvmcu.com/community-topic-id-743.html

解决方案：

1.（重要）**时钟问题**，引出aclk--->hfclk以及aresetn，连接到interconnect对应位置，

引出aresetn，参考icb总线的时钟wire

e203_subsys_clint

