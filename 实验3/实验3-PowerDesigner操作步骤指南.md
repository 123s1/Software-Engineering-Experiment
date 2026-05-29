# 实验3：Power Designer 15.1 中文版操作步骤指南

## 0. 先理解两个概念：CDM 和 PDM

### CDM（概念数据模型，Conceptual Data Model）

CDM 就是用**实体（Entity）和关系（Relationship）画出来的 ER 图**。

- 它只关心"业务上有哪些东西、它们之间是什么关系"
- **不涉及具体数据库技术**，不需要写字段类型（VARCHAR、INT 之类的）
- 你在里面画的是"实体"（比如"用户"、"教室"），不是"表"
- 关系用"一对多"、"多对多"来表达

**简单理解：CDM = 业务层面的 ER 图，给人看的**

### PDM（物理数据模型，Physical Data Model）

PDM 是**针对某个具体数据库（如 MySQL）的表结构设计**。

- 它里面是真正的"表"，有具体的字段名、字段类型、主键、外键、索引
- 可以直接从 PDM 生成 SQL 建表语句
- **CDM 可以一键生成 PDM**，然后你在 PDM 里微调字段类型就行

**简单理解：PDM = 数据库层面的表结构图，给数据库看的**

### 它们之间的关系

```
实验1（用例图）→ 实验2（类图）→ CDM（概念模型）→ PDM（物理模型）→ SQL建表语句
```

你要做的就是：**先画 CDM，再从 CDM 生成 PDM，最后在 PDM 里补充视图和存储过程**。

---

## 1. 在纸上先画 ER 图（准备工作）

在打开 Power Designer 之前，先在纸上把 ER 图的要素理清楚。根据实验1和实验2的设计，你的系统有以下实体和关系：

### 1.1 实体清单（6个）

| 序号 | 实体名称 | 中文名 | 主要属性 |
| --- | --- | --- | --- |
| 1 | User | 用户 | user_id, account, user_name, password, role, identity_type, contact_info, user_status |
| 2 | Classroom | 教室 | classroom_id, classroom_name, location, capacity, equipment_info, classroom_status |
| 3 | ClassroomTimeSlot | 教室可用时间段 | slot_id, use_date, start_section, end_section, slot_status |
| 4 | Reservation | 预订记录 | reservation_id, purpose, reservation_status, create_time |
| 5 | ClassroomMgmtRecord | 教室管理记录 | record_id, operation_type, operation_time, remarks |
| 6 | UserMgmtRecord | 用户管理记录 | record_id, operation_type, operation_time, remarks |

### 1.2 关系清单（8条）

| 序号 | 关系 | 类型 | 说明 |
| --- | --- | --- | --- |
| 1 | 教室 → 教室可用时间段 | 一对多 (1:N) | 一个教室有多个时间段 |
| 2 | 用户 → 预订记录 | 一对多 (1:N) | 一个师生发起多条预订 |
| 3 | 教室 → 预订记录 | 一对多 (1:N) | 一个教室被多次预订 |
| 4 | 教室可用时间段 → 预订记录 | 一对多 (1:N) | 一个时间段对应多条预订 |
| 5 | 用户(管理员) → 教室管理记录 | 一对多 (1:N) | 一个管理员产生多条教室管理记录 |
| 6 | 教室 → 教室管理记录 | 一对多 (1:N) | 一个教室有多条被管理记录 |
| 7 | 用户(管理员) → 用户管理记录 | 一对多 (1:N) | 一个管理员产生多条用户管理记录 |
| 8 | 用户(目标用户) → 用户管理记录 | 一对多 (1:N) | 一个用户有多条被管理记录 |

### 1.3 纸上画法

在纸上用以下规则画：

- **矩形** = 实体（写上实体名）
- **椭圆** = 属性（连到实体上，主键属性加下划线）
- **菱形** = 关系（连接两个实体，旁边标 1 和 N）

画完后拍照留存，后面写报告可以放进去。

---

## 2. 创建 CDM（概念数据模型）

### 2.1 新建 CDM 文件

1. 打开 **Power Designer 15.1**
2. 菜单栏点击 **文件** → **新建模型**（或快捷键 `Ctrl+N`）
3. 在弹出窗口中：
   - 左侧选择 **概念数据模型（Conceptual Data Model）**
   - 模型名称填：`教室预订系统CDM`
   - 点击 **确定**

### 2.2 创建实体

工具栏上找到 **实体（Entity）** 工具（一个小矩形图标），然后在画布上单击创建实体。

你需要创建 **6个实体**，以下是每个实体的操作步骤：

#### 实体1：User（用户）

1. 在工具栏选择 **实体** 工具，在画布上单击
2. 双击刚创建的实体，打开属性窗口
3. **常规** 选项卡：
   - 名称（Name）：`User`
   - 代码（Code）：`User`
4. 切换到 **属性（Attributes）** 选项卡，逐行添加属性：

| 名称（Name） | 代码（Code） | 数据类型 | 主标识符（P） | 必填（M） |
| --- | --- | --- | --- | --- |
| 用户编号 | user_id | Variable characters(32) | ✓ | ✓ |
| 登录账号 | account | Variable characters(50) | | ✓ |
| 用户姓名 | user_name | Variable characters(50) | | ✓ |
| 密码 | password | Variable characters(128) | | ✓ |
| 角色 | role | Variable characters(20) | | ✓ |
| 身份类型 | identity_type | Variable characters(20) | | |
| 联系方式 | contact_info | Variable characters(100) | | |
| 用户状态 | user_status | Variable characters(20) | | ✓ |

> **操作提示**：在属性列表中点击空白行即可添加新属性。勾选 **P** 列表示该属性是主标识符（主键）。勾选 **M** 列表示该属性必填（NOT NULL）。

5. 点击 **确定** 保存

#### 实体2：Classroom（教室）

双击新建实体，设置：
- 名称：`Classroom`，代码：`Classroom`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 教室编号 | classroom_id | Variable characters(32) | ✓ | ✓ |
| 教室名称 | classroom_name | Variable characters(50) | | ✓ |
| 教室位置 | location | Variable characters(100) | | ✓ |
| 教室容量 | capacity | Integer | | ✓ |
| 设备信息 | equipment_info | Variable characters(200) | | |
| 教室状态 | classroom_status | Variable characters(20) | | ✓ |

#### 实体3：ClassroomTimeSlot（教室可用时间段）

- 名称：`ClassroomTimeSlot`，代码：`ClassroomTimeSlot`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 时间段编号 | slot_id | Variable characters(32) | ✓ | ✓ |
| 使用日期 | use_date | Date | | ✓ |
| 开始课时 | start_section | Integer | | ✓ |
| 结束课时 | end_section | Integer | | ✓ |
| 时间段状态 | slot_status | Variable characters(20) | | ✓ |

#### 实体4：Reservation（预订记录）

- 名称：`Reservation`，代码：`Reservation`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 预订编号 | reservation_id | Variable characters(32) | ✓ | ✓ |
| 预订用途 | purpose | Variable characters(200) | | |
| 预订状态 | reservation_status | Variable characters(20) | | ✓ |
| 创建时间 | create_time | Timestamp | | ✓ |

#### 实体5：ClassroomMgmtRecord（教室管理记录）

- 名称：`ClassroomMgmtRecord`，代码：`ClassroomMgmtRecord`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 记录编号 | record_id | Variable characters(32) | ✓ | ✓ |
| 操作类型 | operation_type | Variable characters(20) | | ✓ |
| 操作时间 | operation_time | Timestamp | | ✓ |
| 备注 | remarks | Variable characters(500) | | |

#### 实体6：UserMgmtRecord（用户管理记录）

- 名称：`UserMgmtRecord`，代码：`UserMgmtRecord`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 记录编号 | record_id | Variable characters(32) | ✓ | ✓ |
| 操作类型 | operation_type | Variable characters(20) | | ✓ |
| 操作时间 | operation_time | Timestamp | | ✓ |
| 备注 | remarks | Variable characters(500) | | |

### 2.3 创建关系

工具栏上找到 **关系（Relationship）** 工具（一条带箭头的线），然后按住鼠标从一个实体拖到另一个实体来创建关系。

你需要创建 **8条关系**：

#### 关系1：教室 → 教室可用时间段（1:N）

1. 选择关系工具
2. 从 **Classroom** 拖到 **ClassroomTimeSlot**
3. 双击关系线，打开属性窗口
4. 设置：
   - 名称：`教室包含时间段`
   - **基数（Cardinality）**：
     - Classroom 端：`1,1`（一个时间段必须属于一个教室）
     - ClassroomTimeSlot 端：`0,n`（一个教室可以有0到多个时间段）
5. 确定

#### 关系2：用户 → 预订记录（1:N）

1. 从 **User** 拖到 **Reservation**
2. 双击设置：
   - 名称：`用户发起预订`
   - User 端：`1,1`
   - Reservation 端：`0,n`

#### 关系3：教室 → 预订记录（1:N）

1. 从 **Classroom** 拖到 **Reservation**
2. 双击设置：
   - 名称：`教室被预订`
   - Classroom 端：`1,1`
   - Reservation 端：`0,n`

#### 关系4：教室可用时间段 → 预订记录（1:N）

1. 从 **ClassroomTimeSlot** 拖到 **Reservation**
2. 双击设置：
   - 名称：`时间段被占用`
   - ClassroomTimeSlot 端：`1,1`
   - Reservation 端：`0,n`

#### 关系5：用户(管理员) → 教室管理记录（1:N）

1. 从 **User** 拖到 **ClassroomMgmtRecord**
2. 双击设置：
   - 名称：`管理员管理教室`
   - User 端：`1,1`
   - ClassroomMgmtRecord 端：`0,n`

#### 关系6：教室 → 教室管理记录（1:N）

1. 从 **Classroom** 拖到 **ClassroomMgmtRecord**
2. 双击设置：
   - 名称：`教室被管理`
   - Classroom 端：`1,1`
   - ClassroomMgmtRecord 端：`0,n`

#### 关系7：用户(管理员) → 用户管理记录（1:N）

1. 从 **User** 拖到 **UserMgmtRecord**
2. 双击设置：
   - 名称：`管理员管理用户`
   - User 端：`1,1`
   - UserMgmtRecord 端：`0,n`

#### 关系8：用户(目标用户) → 用户管理记录（1:N）

1. 从 **User** 拖到 **UserMgmtRecord**
2. 双击设置：
   - 名称：`用户被管理`
   - User 端：`1,1`
   - UserMgmtRecord 端：`0,n`

### 2.4 调整 CDM 布局

把实体摆放整齐，建议按以下层次布局：

```
第一层（顶部）：      User
第二层（中间）：      Classroom          UserMgmtRecord
第三层（中间）：      ClassroomTimeSlot   ClassroomMgmtRecord
第四层（底部）：      Reservation
```

### 2.5 保存 CDM

菜单 **文件** → **保存**，文件名：`教室预订系统CDM`

### 2.6 截图

截取完整的 CDM 图，放入实验报告。

---

## 3. 从 CDM 生成 PDM（物理数据模型）

### 3.1 生成 PDM

1. 确保当前打开的是刚才创建的 CDM
2. 菜单栏点击 **工具** → **生成物理数据模型...**（或者英文版是 Tools → Generate Physical Data Model）
3. 在弹出窗口中：
   - **常规** 选项卡：
     - 选择 **生成新的物理数据模型**
     - 名称：`教室预订系统PDM`
     - DBMS（数据库类型）：选择 **MySQL 5.0**（或你熟悉的数据库）
   - 其他选项保持默认
4. 点击 **确定**

Power Designer 会自动根据 CDM 中的实体和关系生成对应的数据库表、字段、主键和外键。

### 3.2 检查生成结果

生成完成后，Power Designer 会自动打开 PDM 窗口。你需要检查以下内容：

#### 检查表是否齐全（应该有6张表）

| CDM 实体 | PDM 表名 |
| --- | --- |
| User | User |
| Classroom | Classroom |
| ClassroomTimeSlot | ClassroomTimeSlot |
| Reservation | Reservation |
| ClassroomMgmtRecord | ClassroomMgmtRecord |
| UserMgmtRecord | UserMgmtRecord |

#### 检查外键是否自动生成

生成 PDM 时，CDM 中的一对多关系会自动变成外键。你应该能看到：

- Reservation 表中自动出现了 `user_id`、`classroom_id`、`slot_id` 外键字段
- ClassroomTimeSlot 表中自动出现了 `classroom_id` 外键字段
- ClassroomMgmtRecord 表中自动出现了 `operator_id`（来自User）、`classroom_id` 外键字段
- UserMgmtRecord 表中自动出现了 `operator_id`（来自User）、`target_user_id`（来自User）外键字段

> **注意**：Power Designer 自动生成的外键字段名称可能和你预期的不完全一样，你可以双击表来修改字段名称。

### 3.3 修改/确认字段名称

双击 PDM 中的每张表，检查并修改外键字段名称，使其与我们的设计一致：

**Reservation 表**：确认有以下外键字段
- `user_id`（指向 User 表）
- `classroom_id`（指向 Classroom 表）
- `slot_id`（指向 ClassroomTimeSlot 表）

**ClassroomTimeSlot 表**：确认有
- `classroom_id`（指向 Classroom 表）

**ClassroomMgmtRecord 表**：确认有
- `operator_id`（指向 User 表）— 如果自动生成的名称是 `user_id`，改成 `operator_id`
- `classroom_id`（指向 Classroom 表）

**UserMgmtRecord 表**：确认有
- `operator_id`（指向 User 表）— 操作人
- `target_user_id`（指向 User 表）— 被操作的目标用户

> **修改方法**：双击表 → 切到 **列（Columns）** 选项卡 → 找到要改的字段 → 修改名称和代码

---

## 4. 在 PDM 中创建视图（View）

老师要求 PDM 中包含视图，我们创建两个常用的业务视图。

### 4.1 视图1：空闲教室查询视图（v_available_classroom）

这个视图用于查询某个时间段内的空闲教室。

1. 在 PDM 工作区，菜单 **模型** → **视图...**（或者右键工作区空白处 → **新建** → **视图**）
2. 也可以在工具栏找到 **视图（View）** 工具图标，在画布上单击创建
3. 双击视图，打开属性窗口
4. **常规** 选项卡：
   - 名称（Name）：`空闲教室查询视图`
   - 代码（Code）：`v_available_classroom`
5. 切到 **SQL查询（SQL Query）** 选项卡（或者叫 **定义/Definition**）
6. 在 SQL 查询框中输入：

```sql
SELECT 
    c.classroom_id,
    c.classroom_name,
    c.location,
    c.capacity,
    c.equipment_info,
    ts.slot_id,
    ts.use_date,
    ts.start_section,
    ts.end_section
FROM Classroom c
INNER JOIN ClassroomTimeSlot ts ON c.classroom_id = ts.classroom_id
WHERE c.classroom_status = 'AVAILABLE'
  AND ts.slot_status = 'FREE'
```

7. 点击 **确定**

### 4.2 视图2：预订情况查询视图（v_reservation_detail）

这个视图用于管理员查看预订详情。

1. 新建视图
2. 设置：
   - 名称：`预订情况查询视图`
   - 代码：`v_reservation_detail`
3. SQL 查询：

```sql
SELECT 
    r.reservation_id,
    u.user_name AS applicant_name,
    u.account AS applicant_account,
    c.classroom_name,
    c.location,
    ts.use_date,
    ts.start_section,
    ts.end_section,
    r.purpose,
    r.reservation_status,
    r.create_time
FROM Reservation r
INNER JOIN User u ON r.user_id = u.user_id
INNER JOIN Classroom c ON r.classroom_id = c.classroom_id
INNER JOIN ClassroomTimeSlot ts ON r.slot_id = ts.slot_id
```

4. 确定

---

## 5. 在 PDM 中创建存储过程（Stored Procedure）

老师要求包含存储过程，我们创建两个核心业务存储过程。

### 5.1 存储过程1：预订教室（sp_create_reservation）

1. 在 PDM 中，菜单 **模型** → **存储过程...**
2. 也可以在左侧浏览器（Browser）面板中，展开 PDM → 右键 **存储过程（Stored Procedures）** → **新建存储过程**
3. 双击打开属性窗口
4. **常规** 选项卡：
   - 名称：`预订教室`
   - 代码：`sp_create_reservation`
5. 切到 **定义（Definition）** 选项卡
6. 输入存储过程代码：

```sql
CREATE PROCEDURE sp_create_reservation(
    IN p_reservation_id VARCHAR(32),
    IN p_user_id VARCHAR(32),
    IN p_classroom_id VARCHAR(32),
    IN p_slot_id VARCHAR(32),
    IN p_purpose VARCHAR(200)
)
BEGIN
    DECLARE v_slot_status VARCHAR(20);
    
    -- 检查时间段是否空闲
    SELECT slot_status INTO v_slot_status 
    FROM ClassroomTimeSlot 
    WHERE slot_id = p_slot_id AND classroom_id = p_classroom_id;
    
    IF v_slot_status = 'FREE' THEN
        -- 插入预订记录
        INSERT INTO Reservation (reservation_id, user_id, classroom_id, slot_id, purpose, reservation_status, create_time)
        VALUES (p_reservation_id, p_user_id, p_classroom_id, p_slot_id, p_purpose, 'CREATED', NOW());
        
        -- 更新时间段状态为已预订
        UPDATE ClassroomTimeSlot 
        SET slot_status = 'RESERVED' 
        WHERE slot_id = p_slot_id;
        
        SELECT '预订成功' AS result;
    ELSE
        SELECT '预订失败：该时间段不可用' AS result;
    END IF;
END
```

7. 确定

### 5.2 存储过程2：取消预订（sp_cancel_reservation）

1. 新建存储过程
2. 设置：
   - 名称：`取消预订`
   - 代码：`sp_cancel_reservation`
3. 定义：

```sql
CREATE PROCEDURE sp_cancel_reservation(
    IN p_reservation_id VARCHAR(32)
)
BEGIN
    DECLARE v_slot_id VARCHAR(32);
    DECLARE v_status VARCHAR(20);
    
    -- 查询预订记录
    SELECT slot_id, reservation_status INTO v_slot_id, v_status
    FROM Reservation 
    WHERE reservation_id = p_reservation_id;
    
    IF v_status = 'CREATED' THEN
        -- 更新预订状态为已取消
        UPDATE Reservation 
        SET reservation_status = 'CANCELLED' 
        WHERE reservation_id = p_reservation_id;
        
        -- 释放时间段
        UPDATE ClassroomTimeSlot 
        SET slot_status = 'FREE' 
        WHERE slot_id = v_slot_id;
        
        SELECT '取消成功' AS result;
    ELSE
        SELECT '取消失败：预订状态不允许取消' AS result;
    END IF;
END
```

4. 确定

---

## 6. 保存并截图

### 6.1 保存 PDM

菜单 **文件** → **保存**，文件名：`教室预订系统PDM`

### 6.2 调整 PDM 布局

在 PDM 中把表的位置摆好，建议布局：

```
        ┌──────────┐
        │   User   │
        └──────────┘
       ↙      ↓       ↘
┌────────────┐ ┌────────────┐ ┌─────────────┐
│UserMgmt    │ │ Classroom  │ │ClassroomMgmt│
│Record      │ └────────────┘ │Record       │
└────────────┘      ↓         └─────────────┘
              ┌──────────────┐
              │ClassroomTime │
              │Slot          │
              └──────────────┘
                    ↓
              ┌──────────────┐
              │ Reservation  │
              └──────────────┘
```

### 6.3 需要截图的内容

你需要截取以下内容放入实验报告：

1. **CDM 概念数据模型全图**（包含所有实体和关系）
2. **PDM 物理数据模型全图**（包含所有表、外键连线）
3. **视图的 SQL 定义**（双击视图截图 SQL 内容）
4. **存储过程的定义**（双击存储过程截图代码）
5. **某张表的列定义**（如双击 Reservation 表，截图字段列表，展示主外键）

---

## 7. 生成 SQL 脚本（可选加分项）

如果老师要求或者你想展示，可以从 PDM 直接生成 SQL：

1. 确保当前打开的是 PDM
2. 菜单 **数据库** → **生成数据库...**（Database → Generate Database）
3. 设置：
   - 输出文件路径和文件名
   - 勾选需要生成的内容（表、视图、存储过程等）
4. 点击 **确定**

生成的 SQL 文件可以直接在 MySQL 中执行建表。

---

## 8. 常见问题

### Q：创建关系时，基数（Cardinality）怎么选？

- `1,1` 表示"必须且只能有一个"（必填的一端）
- `0,n` 表示"可以有零个或多个"（多的一端）
- `0,1` 表示"可以有零个或一个"

本系统所有关系都是 **一端 `1,1`，多端 `0,n`**。

### Q：User 表到 UserMgmtRecord 需要拉两条关系线吗？

是的。因为 UserMgmtRecord 有两个外键都指向 User 表：
- `operator_id`（操作人，管理员）
- `target_user_id`（被操作的用户）

所以你需要从 User 到 UserMgmtRecord 拉 **两条** 关系线，分别代表这两个不同含义的关联。

### Q：CDM 生成 PDM 后，外键字段名不对怎么办？

直接在 PDM 中双击表，修改字段的名称和代码即可。Power Designer 自动生成的外键名称可能会用默认规则命名（如 `User_user_id`），你改成 `operator_id`、`target_user_id` 等即可。

### Q：视图和存储过程在 PDM 图上看不到怎么办？

视图和存储过程不一定会显示在图上。你可以在左侧 **浏览器（Browser）** 面板中，展开 PDM 模型 → 找到 **视图** 和 **存储过程** 节点 → 双击查看和编辑。截图时直接截属性窗口中的 SQL 定义即可。

### Q：Power Designer 15.1 没有找到"视图"或"存储过程"选项？

尝试以下方式：
- 在左侧浏览器面板中右键 PDM 模型名称 → **新建** → 找 **View** 或 **Stored Procedure**
- 或者菜单 **模型** → **视图** / **存储过程**

---

## 9. 实验报告写作建议

建议按以下顺序写实验3报告：

1. **实验目的**：掌握 Power Designer 建模方法，学会数据库设计
2. **设计思路**：简述从类图到数据表的映射过程，重点说明三组多对多关系如何通过中间表拆分
3. **CDM 概念数据模型**：放CDM截图 + 简要说明实体和关系
4. **PDM 物理数据模型**：放PDM截图 + 各表字段说明
5. **视图设计**：放视图SQL截图 + 说明用途
6. **存储过程设计**：放存储过程截图 + 说明用途
7. **总结**：说明设计如何支撑系统功能需求
