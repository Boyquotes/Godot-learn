# camera
![Image text](image/camera1.png)
![Image text](image/camera2.png)
![Image text](image/camera3.png)
![Image text](image/camera4.png)
![Image text](image/camera5.png)
![Image text](image/camera6.png)



# viewport(视口，可视化窗口)
- root就是根节点的viewport
  ![Image text](image/viewport1.png)
  ![Image text](image/viewport2.png)
  ![Image text](image/viewport3.png)
  ![Image text](image/viewport4.png)
  ![Image text](image/viewport5.png)
  ![Image text](image/viewport6.png)
  ![Image text](image/viewport7.png)
  ![Image text](image/viewport8.png)
  ![Image text](image/viewport9.png)
  ![Image text](image/viewport10.png)
  ![Image text](image/viewport11.png)

# canvas layer
-  它是一个节点, 为所有子代和孙代添加一个单独的2D渲染层.Viewport的子节点默认在图层 "0 " 处绘制, 而CanvasLayer将在任何数字层处绘制.
- 数字较大的图层将绘制在数字较小的图层之上.CanvasLayers也有自己的变换, 不依赖于其他层的变换. 这使得当我们对游戏世界的观察发生变化时,UI可以固定在屏幕空间中.

![Image text](image/canvaslayers.png)
