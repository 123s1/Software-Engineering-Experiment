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

### 1.1 实体清单（8个）

| 序号 | 实体名称 | 中文名 | 主要属性 |
| --- | --- | --- | --- |
| 1 | User | 用户（父实体） | user_id, account, user_name, password, contact_info, user_status |
| 2 | Administrator | 管理员 | admin_id（继承自User） |
| 3 | TeacherStudent | 师生用户 | ts_id（继承自User）, identity_type |
| 4 | Classroom | 教室 | classroom_id, classroom_name, location, capacity, equipment_info, classroom_status |
| 5 | ClassroomTimeSlot | 教室可用时间段 | slot_id, use_date, start_section, end_section, slot_status |
| 6 | Reservation | 预订记录 | reservation_id, purpose, reservation_status, create_time |
| 7 | ClassroomMgmtRecord | 教室管理记录 | record_id, operation_type, operation_time, remarks |
| 8 | UserMgmtRecord | 用户管理记录 | record_id, operation_type, operation_time, remarks |

> **说明**：User 是父实体，Administrator 和 TeacherStudent 是子实体，对应实验2类图中的继承关系。管理员和师生的功能不同（管理员可以管理用户/教室，师生可以查询/预订教室），所以要分开建实体。

### 1.2 关系清单（10条）

| 序号 | 关系 | 类型 | 说明 |
| --- | --- | --- | --- |
| 1 | User → Administrator | 继承 | 管理员是用户的一种 |
| 2 | User → TeacherStudent | 继承 | 师生是用户的一种 |
| 3 | 教室 → 教室可用时间段 | 一对多 (1:N) | 一个教室有多个时间段 |
| 4 | 师生 → 预订记录 | 一对多 (1:N) | 一个师生发起多条预订 |
| 5 | 教室 → 预订记录 | 一对多 (1:N) | 一个教室被多次预订 |
| 6 | 教室可用时间段 → 预订记录 | 一对多 (1:N) | 一个时间段对应多条预订 |
| 7 | 管理员 → 教室管理记录 | 一对多 (1:N) | 一个管理员产生多条教室管理记录 |
| 8 | 教室 → 教室管理记录 | 一对多 (1:N) | 一个教室有多条被管理记录 |
| 9 | 管理员 → 用户管理记录 | 一对多 (1:N) | 一个管理员产生多条用户管理记录 |
| 10 | 师生 → 用户管理记录 | 一对多 (1:N) | 一个师生有多条被管理记录 |

### 1.3 纸上画法

在纸上用以下规则画：

- **矩形** = 实体（写上实体名）
- **椭圆** = 属性（连到实体上，主键属性加下划线）
- **菱形** = 关系（连接两个实体，旁边标 1 和 N）
- **三角形 + "ISA"** = 继承关系（User 下面画一个三角形，分别连到 Administrator 和 TeacherStudent）

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

你需要创建 **8个实体**，以下是每个实体的操作步骤：

#### 实体1：User（用户，父实体）

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
| 联系方式 | contact_info | Variable characters(100) | | |
| 用户状态 | user_status | Variable characters(20) | | ✓ |

> **操作提示**：在属性列表中点击空白行即可添加新属性。勾选 **P** 列表示该属性是主标识符（主键）。勾选 **M** 列表示该属性必填（NOT NULL）。

5. 点击 **确定** 保存

#### 实体2：Administrator（管理员，子实体）

1. 在画布上新建一个实体
2. 双击打开属性窗口
3. **常规** 选项卡：
   - 名称：`Administrator`
   - 代码：`Administrator`
4. **属性** 选项卡：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 管理员编号 | admin_id | Variable characters(32) | ✓ | ✓ |

> **说明**：管理员自身只需要一个主键标识，其他属性（account、user_name、password 等）通过继承从 User 获得。

5. 确定

#### 实体3：TeacherStudent（师生用户，子实体）

1. 新建实体
2. 双击设置：
   - 名称：`TeacherStudent`
   - 代码：`TeacherStudent`
3. 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 师生编号 | ts_id | Variable characters(32) | ✓ | ✓ |
| 身份类型 | identity_type | Variable characters(20) | | ✓ |

> **说明**：`identity_type` 用于区分教师和学生，这是师生用户独有的属性。

4. 确定

#### 实体4：Classroom（教室）

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

#### 实体5：ClassroomTimeSlot（教室可用时间段）

- 名称：`ClassroomTimeSlot`，代码：`ClassroomTimeSlot`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 时间段编号 | slot_id | Variable characters(32) | ✓ | ✓ |
| 使用日期 | use_date | Date | | ✓ |
| 开始课时 | start_section | Integer | | ✓ |
| 结束课时 | end_section | Integer | | ✓ |
| 时间段状态 | slot_status | Variable characters(20) | | ✓ |

#### 实体6：Reservation（预订记录）

- 名称：`Reservation`，代码：`Reservation`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 预订编号 | reservation_id | Variable characters(32) | ✓ | ✓ |
| 预订用途 | purpose | Variable characters(200) | | |
| 预订状态 | reservation_status | Variable characters(20) | | ✓ |
| 创建时间 | create_time | Timestamp | | ✓ |

#### 实体7：ClassroomMgmtRecord（教室管理记录）

- 名称：`ClassroomMgmtRecord`，代码：`ClassroomMgmtRecord`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 记录编号 | record_id | Variable characters(32) | ✓ | ✓ |
| 操作类型 | operation_type | Variable characters(20) | | ✓ |
| 操作时间 | operation_time | Timestamp | | ✓ |
| 备注 | remarks | Variable characters(500) | | |

#### 实体8：UserMgmtRecord（用户管理记录）

- 名称：`UserMgmtRecord`，代码：`UserMgmtRecord`
- 属性：

| 名称 | 代码 | 数据类型 | P | M |
| --- | --- | --- | --- | --- |
| 记录编号 | record_id | Variable characters(32) | ✓ | ✓ |
| 操作类型 | operation_type | Variable characters(20) | | ✓ |
| 操作时间 | operation_time | Timestamp | | ✓ |
| 备注 | remarks | Variable characters(500) | | |

### 2.3 创建继承关系（User → Administrator / TeacherStudent）

Power Designer 的 CDM 支持继承（Inheritance），这一步非常重要！

#### 操作步骤：

1. 在工具栏上找到 **继承（Inheritance）** 工具
   - 图标样子：一个带三角形的线（类似 UML 中的继承箭头）
   - 如果找不到，可以在工具栏空白处 **右键** → 勾选显示更多工具
2. **先点击父实体 `User`**，然后点击画布空白处放置继承符号（会出现一个小半圆或三角形）
3. 然后分别将继承符号连接到子实体 **`Administrator`** 和 **`TeacherStudent`**

#### 详细操作（另一种方式）：

如果上面的方式不太方便，可以用以下方式：

1. 在工具栏选择 **继承** 工具
2. 在画布上，**从 `Administrator` 拖到 `User`**（表示 Administrator 继承自 User）
3. 会自动在两个实体之间画出一个带半圆/三角的继承线
4. 再用同样的方式，**从 `TeacherStudent` 拖到 `User`**

#### 检查继承设置：

双击继承符号（三角形/半圆），可以看到属性窗口：
- 父实体（Parent）应该是 `User`
- 子实体（Children）应该包含 `Administrator` 和 `TeacherStudent`

> **这一步的意义**：继承关系说明管理员和师生都是用户的子类型，生成 PDM 时 Power Designer 会自动在子表中创建指向父表的外键。

### 2.4 创建普通关系

工具栏上找到 **关系（Relationship）** 工具（一条带箭头的线），然后按住鼠标从一个实体拖到另一个实体来创建关系。

你需要创建 **8条普通关系**：

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

#### 关系2：师生 → 预订记录（1:N）

1. 从 **TeacherStudent** 拖到 **Reservation**
2. 双击设置：
   - 名称：`师生发起预订`
   - TeacherStudent 端：`1,1`
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

#### 关系5：管理员 → 教室管理记录（1:N）

1. 从 **Administrator** 拖到 **ClassroomMgmtRecord**
2. 双击设置：
   - 名称：`管理员管理教室`
   - Administrator 端：`1,1`
   - ClassroomMgmtRecord 端：`0,n`

#### 关系6：教室 → 教室管理记录（1:N）

1. 从 **Classroom** 拖到 **ClassroomMgmtRecord**
2. 双击设置：
   - 名称：`教室被管理`
   - Classroom 端：`1,1`
   - ClassroomMgmtRecord 端：`0,n`

#### 关系7：管理员 → 用户管理记录（1:N）

1. 从 **Administrator** 拖到 **UserMgmtRecord**
2. 双击设置：
   - 名称：`管理员管理用户`
   - Administrator 端：`1,1`
   - UserMgmtRecord 端：`0,n`

#### 关系8：师生 → 用户管理记录（1:N）

1. 从 **TeacherStudent** 拖到 **UserMgmtRecord**
2. 双击设置：
   - 名称：`师生被管理`
   - TeacherStudent 端：`1,1`
   - UserMgmtRecord 端：`0,n`

### 2.5 调整 CDM 布局

把实体摆放整齐，建议按以下层次布局：

```
                  ┌──────────┐
                  │   User   │
                  └──────────┘
                 ↙ (继承)  ↘
     ┌───────────────┐  ┌──────────────┐
     │ Administrator │  │TeacherStudent│
     └───────────────┘  └──────────────┘
      ↓            ↓      ↓           ↓
┌──────────┐ ┌──────────┐ ┌────────────┐
│UserMgmt  │ │Classroom │ │Reservation │
│Record    │ │MgmtRecord│ │            │
└──────────┘ └──────────┘ └────────────┘
                  ↑               ↑
             ┌──────────┐        │
             │Classroom │────────┘
             └──────────┘
                  ↓
         ┌───────────────┐
         │ClassroomTime  │
         │Slot           │
         └───────────────┘
```

### 2.6 保存 CDM

菜单 **文件** → **保存**，文件名：`教室预订系统CDM`

### 2.7 截图

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

Power Designer 会自动根据 CDM 中的实体、继承和关系生成对应的数据库表、字段、主键和外键。

### 3.2 检查生成结果

生成完成后，Power Designer 会自动打开 PDM 窗口。你需要检查以下内容：

#### 检查表是否齐全（应该有8张表）

| CDM 实体 | PDM 表名 | 说明 |
| --- | --- | --- |
| User | User | 用户主表（父表） |
| Administrator | Administrator | 管理员子表 |
| TeacherStudent | TeacherStudent | 师生用户子表 |
| Classroom | Classroom | 教室表 |
| ClassroomTimeSlot | ClassroomTimeSlot | 教室可用时间段表 |
| Reservation | Reservation | 预订记录表 |
| ClassroomMgmtRecord | ClassroomMgmtRecord | 教室管理记录表 |
| UserMgmtRecord | UserMgmtRecord | 用户管理记录表 |

#### 检查继承产生的外键

由于 CDM 中有继承关系，PDM 生成时会自动处理：

- **Administrator 表**：应该有一个外键字段指向 User 表的 `user_id`（表示管理员是用户的子类）
- **TeacherStudent 表**：应该有一个外键字段指向 User 表的 `user_id`（表示师生是用户的子类）

#### 检查普通关系产生的外键

- **ClassroomTimeSlot 表**：有 `classroom_id` 外键 → Classroom 表
- **Reservation 表**：有 `ts_id` 外键 → TeacherStudent 表、`classroom_id` 外键 → Classroom 表、`slot_id` 外键 → ClassroomTimeSlot 表
- **ClassroomMgmtRecord 表**：有 `admin_id` 外键 → Administrator 表、`classroom_id` 外键 → Classroom 表
- **UserMgmtRecord 表**：有 `admin_id` 外键 → Administrator 表（操作人）、`ts_id` 外键 → TeacherStudent 表（被操作的师生）

> **注意**：Power Designer 自动生成的外键字段名称可能和你预期的不完全一样，你可以双击表来修改。

### 3.3 修改/确认字段名称

双击 PDM 中的每张表，检查并修改外键字段名称，使其含义清晰：

**Administrator 表**：
- `user_id`（外键指向 User 表）— 继承关系产生的

**TeacherStudent 表**：
- `user_id`（外键指向 User 表）— 继承关系产生的

**Reservation 表**：
- `ts_id`（指向 TeacherStudent 表）— 申请人
- `classroom_id`（指向 Classroom 表）— 被预订教室
- `slot_id`（指向 ClassroomTimeSlot 表）— 占用时间段

**ClassroomMgmtRecord 表**：
- `admin_id`（指向 Administrator 表）— 操作的管理员
- `classroom_id`（指向 Classroom 表）— 被操作的教室

**UserMgmtRecord 表**：
- `admin_id`（指向 Administrator 表）— 操作的管理员
- `ts_id`（指向 TeacherStudent 表）— 被管理的师生用户

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
    t.identity_type,
    c.classroom_name,
    c.location,
    ts.use_date,
    ts.start_section,
    ts.end_section,
    r.purpose,
    r.reservation_status,
    r.create_time
FROM Reservation r
INNER JOIN TeacherStudent t ON r.ts_id = t.ts_id
INNER JOIN User u ON t.user_id = u.user_id
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
    IN p_ts_id VARCHAR(32),
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
        INSERT INTO Reservation (reservation_id, ts_id, classroom_id, slot_id, purpose, reservation_status, create_time)
        VALUES (p_reservation_id, p_ts_id, p_classroom_id, p_slot_id, p_purpose, 'CREATED', NOW());
        
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
                 ↙           ↘
     ┌───────────────┐  ┌──────────────┐
     │ Administrator │  │TeacherStudent│
     └───────────────┘  └──────────────┘
      ↓            ↓      ↓           ↓
┌──────────┐ ┌──────────┐ ┌────────────┐
│UserMgmt  │ │Classroom │ │Reservation │
│Record    │ │MgmtRecord│ │            │
└──────────┘ └──────────┘ └────────────┘
                  ↑               ↑
             ┌──────────┐        │
             │Classroom │────────┘
             └──────────┘
                  ↓
         ┌───────────────┐
         │ClassroomTime  │
         │Slot           │
         └───────────────┘
```

### 6.3 需要截图的内容

你需要截取以下内容放入实验报告：

1. **CDM 概念数据模型全图**（包含所有实体、继承关系和普通关系）
2. **PDM 物理数据模型全图**（包含所有表、外键连线）
3. **视图的 SQL 定义**（双击视图截图 SQL 内容）
4. **存储过程的定义**（双击存储过程截图代码）
5. **某张表的列定义**（如双击 Reservation 表，截图字段列表，展示主外键）
6. **继承关系的截图**（展示 User、Administrator、TeacherStudent 之间的继承线）

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

### Q：创建继承关系时找不到继承工具怎么办？

在 Power Designer 15.1 中文版中：
- 工具栏上的继承工具图标可能不太明显
- 你也可以通过菜单方式：先选中父实体 `User`，然后右键 → 选择相关的继承操作
- 或者在左侧浏览器面板中，右键 CDM 模型 → **新建** → **继承**
- 还有一种方法：工具栏上点击鼠标右键，可以看到所有可用工具，找到"继承"

### Q：基数（Cardinality）怎么选？

- `1,1` 表示"必须且只能有一个"（必填的一端）
- `0,n` 表示"可以有零个或多个"（多的一端）
- `0,1` 表示"可以有零个或一个"

本系统的普通关系都是 **一端 `1,1`，多端 `0,n`**。

### Q：为什么 Administrator 和 TeacherStudent 要单独建实体？

因为管理员和师生的**功能完全不同**：
- **管理员**：管理用户、管理教室、设置时间段、查看预订情况
- **师生**：查询空闲教室、预订教室

在实验2的类图中，它们就是 User 的两个子类（继承关系）。在 CDM 中用继承来体现这种关系，生成 PDM 时会自动产生父子表的外键关联。

### Q：CDM 生成 PDM 后，外键字段名不对怎么办？

直接在 PDM 中双击表，修改字段的名称和代码即可。Power Designer 自动生成的外键名称可能会用默认规则命名，你改成 `admin_id`、`ts_id` 等即可。

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
2. **设计思路**：
   - 从实验2类图中提取实体和关系
   - 说明继承关系（User → Administrator / TeacherStudent）在数据库中如何表达
   - 说明三组多对多关系如何通过中间表拆分
3. **CDM 概念数据模型**：放CDM截图 + 简要说明实体和关系
4. **PDM 物理数据模型**：放PDM截图 + 各表字段说明
5. **视图设计**：放视图SQL截图 + 说明用途
6. **存储过程设计**：放存储过程截图 + 说明用途
7. **总结**：说明设计如何支撑系统功能需求

### 关于三组多对多关系的报告写法

在报告中可以这样描述：

> 本系统中存在三组多对多关系，通过引入中间实体拆分为一对多关系：
>
> 1. **师生 ↔ 教室（预订关系）**：多名师生可预订多间教室。通过 `Reservation`（预订记录）拆分为：TeacherStudent (1) → (0..*) Reservation，Reservation (0..*) → (1) Classroom。
>
> 2. **管理员 ↔ 教室（管理关系）**：多个管理员可管理多个教室。通过 `ClassroomMgmtRecord`（教室管理记录）拆分为：Administrator (1) → (0..*) ClassroomMgmtRecord，ClassroomMgmtRecord (0..*) → (1) Classroom。
>
> 3. **管理员 ↔ 师生（管理关系）**：多个管理员可管理多名师生。通过 `UserMgmtRecord`（用户管理记录）拆分为：Administrator (1) → (0..*) UserMgmtRecord，UserMgmtRecord (0..*) → (1) TeacherStudent。


---

## 10. 用 SQL 反向工程生成 PDM（本次推荐流程）

第 2~6 节是“先画 CDM，再正向生成 PDM”的做法。如果你想**直接用现成的 MySQL 建表脚本反向生成 PDM**（本次实验采用的方式），按下面步骤操作。建表脚本见 `实验3-教室预订系统建表脚本.sql`，已是 MySQL 格式（InnoDB + utf8 + 列注释），并包含 8 张表、2 个视图、3 个存储过程。

### 10.1 反向工程步骤（Power Designer 15.1 中文版）

1. 打开 Power Designer 15.1。
2. 菜单 **文件（File）** → **反向工程（Reverse Engineer）** → **数据库（Database...）**。
   - 也可以：**文件 → 新建模型 → Physical Data Model**，建好空 PDM 后，再用菜单 **数据库（Database）** → **反向工程数据库（Update Model from Database / Reverse Engineer Database）**。
3. 在弹出的 **New Physical Data Model** 窗口里：
   - **DBMS** 选择 **MySQL 5.0**（PD 15.1 内置的 MySQL 版本）。
   - Model name 填 `教室预订系统PDM`。
4. 选择反向工程来源为 **Using script files（使用脚本文件）**，点 **Add（添加）**，选中 `实验3-教室预订系统建表脚本.sql`。
5. 点 **确定（OK）**，PD 会解析脚本并自动生成：
   - 8 张表及其主键、唯一键、索引；
   - 表之间的外键连线（10 条）；
   - 2 个视图（View）；
   - 3 个存储过程（Procedure）。
6. 反向完成后，在画布上拖动表，把布局摆整齐（继承父表 t_user 放上方，子表/中间表放下方）。

### 10.2 查看视图与存储过程

视图和存储过程一般**不显示在关系图上**，到左侧 **浏览器（Browser）** 面板里看：

- 展开 PDM 模型 → **Views（视图）** 节点 → 双击 `v_available_classroom` / `v_reservation_detail` → 在属性窗口的 **SQL Query / Definition** 标签里能看到 SQL，可直接截图。
- 展开 PDM 模型 → **Procedures（存储过程）** 节点 → 双击 `sp_reserve_classroom` 等 → 在 **Definition** 标签里能看到过程体，可直接截图。

### 10.3 需要截图放进报告的内容

1. 反向工程向导里 **DBMS=MySQL 5.0 + 选中 SQL 脚本** 的截图（证明是用 SQL 反向生成）。
2. PDM 物理模型全图（8 张表 + 外键连线）。
3. 某张含主外键的表（如 `t_reservation`）的列定义截图。
4. 2 个视图的 SQL 定义截图。
5. 3 个存储过程的定义截图。
6. 用户继承关系（t_user 与 t_administrator / t_teacher_student 的外键）截图。

### 10.4 注意事项（PD 15.1 + MySQL）

- DBMS 必须选 **MySQL 5.0**，否则解析 `ENGINE=InnoDB`、`KEY`、`AUTO_INCREMENT` 等 MySQL 方言时可能报错。
- 脚本里的存储过程使用了 `DELIMITER $$ ... $$`，这是 MySQL 客户端分隔符写法。PD 15.1 反向工程一般能识别；若个别版本未能把存储过程导入成 Procedure 对象，可改用**连接数据库反向工程**（先把脚本在 MySQL 里执行建好库，再用 PD 的 **Database → Reverse Engineer → Using a data source** 连库反向），或在 PDM 里手动新建 Procedure 把过程体粘进去。
- 列上的 `COMMENT` 会被 PD 反向成各字段的 **Comment（注释）**，报告里字段说明可直接用。
- 脚本已去掉 `CHECK` 约束（MySQL 5.x 不强制、且对 PD 反向工程不友好），“开始课时 ≤ 结束课时”“同教室同日期课时不重叠”改为业务规则，在应用层或存储过程中校验。
