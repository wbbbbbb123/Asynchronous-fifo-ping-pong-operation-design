设计了一个异步模块，该模块可以自定义数据位宽与数据深度，且可以输出可读数据数与已写数据数，当然用户也可以自定义满阈值数。
设计了两级fifo缓存器，当然在此基础上你也可以进行扩展与沿伸。
注意：此设计的读时钟应该比写时钟要快，否则会丢失一部分数据。
写入fifo状态转换：
![image](https://user-images.githubusercontent.com/71707557/183387512-fe753911-8ee2-4832-9df9-1857815f56af.png)
读出fifo状态转换：
![image](https://user-images.githubusercontent.com/71707557/183387602-85559181-7497-4644-99df-64c5e13adab6.png)
