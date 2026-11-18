---
title: "用 deque 写 BFS：什么时候标记已访问？"
summary: "从一个四节点图出发，解释为什么入队时就应该标记 visited。"
category: "算法笔记"
tags: ["Python", "BFS"]
---

广度优先搜索（BFS）一层一层向外走。在无权图里，第一次发现一个节点时，就知道了从起点到它的最短距离。

## 一个会重复入队的例子

假设 A 可以到 B、C，B 和 C 都可以到 D。如果等到 D 出队才标记它，处理 B 时会把 D 放进队列，接着处理 C 时还会再放一次。把标记放到入队时，这两个分支就不会重复排队。

```python
from collections import deque

graph = {"A": ["B", "C"], "B": ["D"], "C": ["D"], "D": []}
queue = deque(["A"])
distance = {"A": 0}

while queue:
    node = queue.popleft()
    for neighbor in graph[node]:
        if neighbor in distance:
            continue
        distance[neighbor] = distance[node] + 1
        queue.append(neighbor)

print(distance)  # {'A': 0, 'B': 1, 'C': 1, 'D': 2}
```

这里的 `distance` 同时记录距离和访问状态。对于队列，用 `deque.popleft()` 能避免用列表 `pop(0)` 时搬动后面的元素。

## 小练习

给 D 加一条回到 A 的边，再运行一次。想一想：如果忘了在开始时把 A 放进 `distance`，结果会有什么变化？
