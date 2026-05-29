# 实验2：Rational Rose 7.0 逆向生成类图说明

## 1. 目的

本说明用于指导你使用 `Rational Rose 7.0` 对实验2中提供的 `Java` 源代码进行逆向工程，从而生成教室预订系统的类图。

## 2. 已准备好的源码位置

本次用于逆向生成的 Java 源码建议放在：

`e:\软件工程实验\实验2\java-src\classroomreservation`

## 3. 逆向前准备

在进行逆向之前，建议先确认以下内容：

- `Rational Rose 7.0` 已正常安装
- Rose 已安装或启用了 Java / J2EE 相关支持
- 源码文件扩展名均为 `.java`
- 各 Java 文件中的 `package` 声明一致
- 目录结构与 `package` 对应正确

## 4. 推荐操作步骤

根据 Rational Rose 常见的 Java 逆向操作方式，可以按以下步骤进行：

### 第一步：新建模型

- 打开 `Rational Rose 7.0`
- 新建一个 `.mdl` 模型文件
- 建议将模型保存到实验2目录中，便于后续管理

### 第二步：进入 Java 逆向功能

常见入口一般为：

- `Tools` -> `Java/J2EE` -> `Reverse Engineer`

不同安装版本菜单名称可能略有差异，但通常都在 `Tools` 菜单下的 Java 相关功能中。

### 第三步：选择源码目录或源码文件

在逆向窗口中：

- 选择要导入的 `.java` 文件
- 或直接选择源码所在目录

本次建议你直接导入：

`e:\软件工程实验\实验2\java-src\classroomreservation`

### 第四步：检查包结构

- 确认 `package classroomreservation;` 能被工具识别
- 若 Rose 提示找不到类或包，请确认源码路径与包路径一致

### 第五步：执行逆向生成

- 确认选项后执行 Reverse Engineer
- 生成完成后，类通常会出现在 `Logical View` 中

### 第六步：绘制类图

逆向完成后：

- 在 `Logical View` 中找到生成的类
- 新建一个 Class Diagram
- 将相关类拖入图中
- 工具通常会自动连出部分关系

## 5. 逆向后需要人工检查的内容

Rational Rose 对 Java 逆向虽然能识别类、继承、字段和部分关联，但并不一定会完全按照理想 UML 效果展示，因此你需要重点检查：

### 5.1 继承关系

应确认：

- `Administrator` 是否继承 `User`
- `TeacherStudentUser` 是否继承 `User`

### 5.2 关联关系

应确认：

- `TeacherStudentUser` 与 `Reservation` 是否有关联
- `Reservation` 与 `Classroom` 是否有关联
- `Reservation` 与 `ClassroomTimeSlot` 是否有关联

### 5.3 组合关系

Java 逆向有时只能识别字段引用，不一定自动标出组合，因此你需要手工把：

- `Classroom` 与 `ClassroomTimeSlot`

调整为组合关系。

### 5.4 多重性

Rose 逆向后可能不会自动准确标出所有多重性，因此建议你手工补充：

- `Classroom 1` 对 `ClassroomTimeSlot 0..*`
- `TeacherStudentUser 1` 对 `Reservation 0..*`
- `Reservation 0..*` 对 `Classroom 1`
- `Reservation 0..*` 对 `ClassroomTimeSlot 1`

### 5.5 服务类依赖关系

`Service` 类与实体类的关系通常更适合表示为依赖而不是强关联。如果 Rose 没有自动生成依赖线，你可以手工补充。

## 6. 常见问题与处理建议

## 6.1 找不到源码文件

处理建议：

- 检查目录路径是否正确
- 检查文件是否为 `.java`
- 检查是否选择了正确文件夹

## 6.2 包路径不匹配

处理建议：

- 确保 Java 文件中声明的是：

```java
package classroomreservation;
```

- 并且文件真实路径位于：

`...\java-src\classroomreservation\`

## 6.3 关系没有完整生成

处理建议：

- Java 逆向主要擅长识别类结构和继承
- 组合、聚合、多重性经常需要手工调整
- 这是正常现象，不代表源码有问题

## 6.4 图太乱

处理建议：

建议按如下层次摆放类：

- 第一层：`User`
- 第二层：`Administrator`、`TeacherStudentUser`
- 第三层：`Classroom`、`ClassroomTimeSlot`、`Reservation`
- 第四层：各类 `Service`

这样图的结构会更清晰。

## 7. 建议的最终检查项

在提交实验2前，建议逐项检查：

- 类名是否齐全
- 属性是否完整
- 方法是否合理
- 继承关系是否正确
- 组合关系是否正确
- 关联关系是否清晰
- 多重性是否标注
- 图是否整洁、可读

## 8. 最后说明

本次提供的 Java 源码主要目的是：

- 让你能在 `Rational Rose 7.0` 中进行逆向工程
- 帮你快速生成类图骨架
- 减少手工从零建类的工作量

但逆向生成后的类图，通常仍需你在 Rose 中进行适当微调，尤其是：

- 组合关系
- 多重性
- 依赖关系
- 图形布局

只要你根据本说明检查并调整，最后得到的类图就会比较规范，适合作为实验2提交结果。
