---
title: "两数之和：用字典记住已经见过的数"
summary: "遍历时查询当前数字需要的搭档，再保存当前数字的下标。"
category: "算法笔记"
tags: ["Python", "哈希表"]
---

## 先查，后存

读到数字 `x` 时，先查字典里是否已经出现 `target - x`。查不到再存当前数字和下标。这样保证了找到的是两个不同的位置。

```python
def two_sum(nums, target):
    seen = {}
    for i, x in enumerate(nums):
        other = target - x
        if other in seen:
            return [seen[other], i]
        seen[x] = i
    return []

assert two_sum([3, 3], 6) == [0, 1]
assert two_sum([2, 7, 11, 15], 9) == [0, 1]
```

## 用重复值检验顺序

拿 `[3, 3]` 和目标 `6` 试一下。第一个 3 加进字典之前找不到搭档。第二个 3 刚好能找到下标 0。如果先写再查，就可能把同一个位置用两次。
