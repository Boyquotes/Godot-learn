# 组件的使用
- Path2D
```
Contains a Curve2D path for PathFollow2D nodes to follow，Describes a Bézier curve in 2D space.
```

- PathFollow2D
```
This node takes its parent Path2D, and returns the coordinates of a point within it, given a distance from the first vertex.


It is useful for making other nodes follow a path, without coding the movement pattern. For that, the nodes must be children of this node.
The descendant nodes will then move accordingly when setting an offset in this node.
```

- RemoteTransform2D，类似与设计模式中的代理模式
```
RemoteTransform2D pushes its own Transform2D to another CanvasItem derived Node in the scene.

It can be set to update another Node's position, rotation and/or scale. It can use either global or local coordinates.
```
