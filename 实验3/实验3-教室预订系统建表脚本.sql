-- ============================================================
-- 教室预订系统 数据库建表脚本（MySQL 版）
-- 实验3：持久化设计（多表继承方案）
-- 目标 DBMS：MySQL 5.x（兼容 PowerDesigner 15.1 的 MySQL 5.0 反向工程）
-- 存储引擎：InnoDB（支持外键 + 事务）
-- 字符集：utf8（MySQL 5.5.3+ 可改为 utf8mb4）
-- 内容：8 张表 + 2 个视图 + 3 个存储过程
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. 用户主表 t_user（父表，存放所有用户公共属性）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
    user_id       VARCHAR(32)  NOT NULL COMMENT '用户唯一编号',
    account       VARCHAR(50)  NOT NULL COMMENT '登录账号',
    user_name     VARCHAR(50)  NOT NULL COMMENT '用户姓名',
    password      VARCHAR(128) NOT NULL COMMENT '密码（建议哈希存储）',
    contact_info  VARCHAR(100) NULL     COMMENT '联系方式',
    user_status   VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/DISABLED',
    PRIMARY KEY (user_id),
    UNIQUE KEY uk_user_account (account),
    KEY idx_user_status (user_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户主表';

-- ------------------------------------------------------------
-- 2. 管理员子表 t_administrator（继承 t_user，1:1）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_administrator;
CREATE TABLE t_administrator (
    admin_id  VARCHAR(32) NOT NULL COMMENT '管理员唯一编号',
    user_id   VARCHAR(32) NOT NULL COMMENT '关联用户编号（继承）',
    PRIMARY KEY (admin_id),
    UNIQUE KEY uk_admin_user (user_id),
    CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES t_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='管理员子表';

-- ------------------------------------------------------------
-- 3. 师生用户子表 t_teacher_student（继承 t_user，1:1）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_teacher_student;
CREATE TABLE t_teacher_student (
    ts_id          VARCHAR(32) NOT NULL COMMENT '师生用户唯一编号',
    user_id        VARCHAR(32) NOT NULL COMMENT '关联用户编号（继承）',
    identity_type  VARCHAR(20) NOT NULL COMMENT '身份类型：TEACHER/STUDENT',
    PRIMARY KEY (ts_id),
    UNIQUE KEY uk_ts_user (user_id),
    KEY idx_ts_identity_type (identity_type),
    CONSTRAINT fk_ts_user FOREIGN KEY (user_id) REFERENCES t_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='师生用户子表';

-- ------------------------------------------------------------
-- 4. 教室表 t_classroom
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_classroom;
CREATE TABLE t_classroom (
    classroom_id      VARCHAR(32)  NOT NULL COMMENT '教室唯一编号',
    classroom_name    VARCHAR(50)  NOT NULL COMMENT '教室名称',
    location          VARCHAR(100) NOT NULL COMMENT '教室位置',
    capacity          INT          NOT NULL COMMENT '教室容量（座位数）',
    equipment_info    VARCHAR(200) NULL     COMMENT '设备信息',
    classroom_status  VARCHAR(20)  NOT NULL DEFAULT 'AVAILABLE' COMMENT '状态：AVAILABLE/DISABLED',
    PRIMARY KEY (classroom_id),
    KEY idx_classroom_status (classroom_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='教室表';

-- ------------------------------------------------------------
-- 5. 教室可用时间段表 t_classroom_time_slot
--    外键：classroom_id -> t_classroom（1:N）
--    业务规则：start_section <= end_section；同一教室同一日期课时不重叠（在应用/存储过程层校验）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_classroom_time_slot;
CREATE TABLE t_classroom_time_slot (
    slot_id        VARCHAR(32) NOT NULL COMMENT '时间段唯一编号',
    classroom_id   VARCHAR(32) NOT NULL COMMENT '所属教室编号',
    use_date       DATE        NOT NULL COMMENT '使用日期',
    start_section  INT         NOT NULL COMMENT '开始课时',
    end_section    INT         NOT NULL COMMENT '结束课时',
    slot_status    VARCHAR(20) NOT NULL DEFAULT 'FREE' COMMENT '状态：FREE/RESERVED/UNAVAILABLE',
    PRIMARY KEY (slot_id),
    KEY idx_slot_classroom_date (classroom_id, use_date),
    KEY idx_slot_date_status (use_date, slot_status),
    CONSTRAINT fk_slot_classroom FOREIGN KEY (classroom_id) REFERENCES t_classroom (classroom_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='教室可用时间段表';

-- ------------------------------------------------------------
-- 6. 预订记录表 t_reservation（拆分 师生用户 与 教室 的 N:M 预订关系）
--    外键：ts_id -> t_teacher_student, classroom_id -> t_classroom, slot_id -> t_classroom_time_slot
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_reservation;
CREATE TABLE t_reservation (
    reservation_id      VARCHAR(32)  NOT NULL COMMENT '预订记录唯一编号',
    ts_id               VARCHAR(32)  NOT NULL COMMENT '申请人（师生）编号',
    classroom_id        VARCHAR(32)  NOT NULL COMMENT '被预订教室编号',
    slot_id             VARCHAR(32)  NOT NULL COMMENT '占用时间段编号',
    purpose             VARCHAR(200) NULL     COMMENT '预订用途',
    reservation_status  VARCHAR(20)  NOT NULL DEFAULT 'CREATED' COMMENT '状态：CREATED/CANCELLED/FINISHED',
    create_time         DATETIME     NOT NULL COMMENT '预订创建时间',
    PRIMARY KEY (reservation_id),
    KEY idx_reservation_ts (ts_id),
    KEY idx_reservation_classroom_slot (classroom_id, slot_id),
    KEY idx_reservation_status (reservation_status),
    KEY idx_reservation_create_time (create_time),
    CONSTRAINT fk_reservation_ts FOREIGN KEY (ts_id) REFERENCES t_teacher_student (ts_id),
    CONSTRAINT fk_reservation_classroom FOREIGN KEY (classroom_id) REFERENCES t_classroom (classroom_id),
    CONSTRAINT fk_reservation_slot FOREIGN KEY (slot_id) REFERENCES t_classroom_time_slot (slot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='预订记录表';

-- ------------------------------------------------------------
-- 7. 教室管理记录表 t_classroom_mgmt_record（拆分 管理员 与 教室 的 N:M 管理关系）
--    外键：admin_id -> t_administrator, classroom_id -> t_classroom
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_classroom_mgmt_record;
CREATE TABLE t_classroom_mgmt_record (
    record_id       VARCHAR(32)  NOT NULL COMMENT '管理记录唯一编号',
    admin_id        VARCHAR(32)  NOT NULL COMMENT '操作人（管理员）编号',
    classroom_id    VARCHAR(32)  NOT NULL COMMENT '被操作教室编号',
    operation_type  VARCHAR(20)  NOT NULL COMMENT '操作类型：ADD/DELETE/SET_TIMESLOT',
    operation_time  DATETIME     NOT NULL COMMENT '操作时间',
    remarks         VARCHAR(500) NULL     COMMENT '备注信息',
    PRIMARY KEY (record_id),
    KEY idx_classroom_mgmt_admin (admin_id),
    KEY idx_classroom_mgmt_classroom (classroom_id),
    KEY idx_classroom_mgmt_time (operation_time),
    CONSTRAINT fk_classroom_mgmt_admin FOREIGN KEY (admin_id) REFERENCES t_administrator (admin_id),
    CONSTRAINT fk_classroom_mgmt_classroom FOREIGN KEY (classroom_id) REFERENCES t_classroom (classroom_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='教室管理记录表';

-- ------------------------------------------------------------
-- 8. 用户管理记录表 t_user_mgmt_record（拆分 管理员 与 师生用户 的 N:M 管理关系）
--    外键：admin_id -> t_administrator, target_ts_id -> t_teacher_student
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_user_mgmt_record;
CREATE TABLE t_user_mgmt_record (
    record_id       VARCHAR(32)  NOT NULL COMMENT '管理记录唯一编号',
    admin_id        VARCHAR(32)  NOT NULL COMMENT '操作人（管理员）编号',
    target_ts_id    VARCHAR(32)  NOT NULL COMMENT '被操作目标师生编号',
    operation_type  VARCHAR(20)  NOT NULL COMMENT '操作类型：ENABLE/DISABLE',
    operation_time  DATETIME     NOT NULL COMMENT '操作时间',
    remarks         VARCHAR(500) NULL     COMMENT '备注信息',
    PRIMARY KEY (record_id),
    KEY idx_user_mgmt_admin (admin_id),
    KEY idx_user_mgmt_target (target_ts_id),
    KEY idx_user_mgmt_time (operation_time),
    CONSTRAINT fk_user_mgmt_admin FOREIGN KEY (admin_id) REFERENCES t_administrator (admin_id),
    CONSTRAINT fk_user_mgmt_target FOREIGN KEY (target_ts_id) REFERENCES t_teacher_student (ts_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户管理记录表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 视图
-- ============================================================

-- 空闲教室查询视图：状态可用的教室 + 状态空闲的时间段
DROP VIEW IF EXISTS v_available_classroom;
CREATE VIEW v_available_classroom AS
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
FROM t_classroom c
JOIN t_classroom_time_slot ts ON c.classroom_id = ts.classroom_id
WHERE c.classroom_status = 'AVAILABLE'
  AND ts.slot_status = 'FREE';

-- 预订情况查询视图：预订记录 + 申请人 + 教室 + 时间段
DROP VIEW IF EXISTS v_reservation_detail;
CREATE VIEW v_reservation_detail AS
SELECT
    r.reservation_id,
    u.user_name    AS applicant_name,
    u.account      AS applicant_account,
    t.identity_type,
    c.classroom_name,
    c.location,
    ts.use_date,
    ts.start_section,
    ts.end_section,
    r.purpose,
    r.reservation_status,
    r.create_time
FROM t_reservation r
JOIN t_teacher_student t ON r.ts_id = t.ts_id
JOIN t_user u           ON t.user_id = u.user_id
JOIN t_classroom c      ON r.classroom_id = c.classroom_id
JOIN t_classroom_time_slot ts ON r.slot_id = ts.slot_id;

-- ============================================================
-- 存储过程
-- ============================================================

-- 1) 预订教室：在一个事务内锁定时间段、校验空闲、写入预订、置时间段为已预订
--    p_result: 1=预订成功, 0=时间段不可用, -1=异常已回滚
DROP PROCEDURE IF EXISTS sp_reserve_classroom;
DELIMITER $$
CREATE PROCEDURE sp_reserve_classroom(
    IN  p_reservation_id VARCHAR(32),
    IN  p_ts_id          VARCHAR(32),
    IN  p_slot_id        VARCHAR(32),
    IN  p_purpose        VARCHAR(200),
    OUT p_result         INT
)
BEGIN
    DECLARE v_classroom_id VARCHAR(32);
    DECLARE v_slot_status  VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -1;
    END;

    START TRANSACTION;

    -- 锁定目标时间段，读取所属教室与状态（FOR UPDATE 防止并发重复预订）
    SELECT classroom_id, slot_status
      INTO v_classroom_id, v_slot_status
      FROM t_classroom_time_slot
     WHERE slot_id = p_slot_id
     FOR UPDATE;

    IF v_slot_status = 'FREE' THEN
        INSERT INTO t_reservation(
            reservation_id, ts_id, classroom_id, slot_id,
            purpose, reservation_status, create_time)
        VALUES (
            p_reservation_id, p_ts_id, v_classroom_id, p_slot_id,
            p_purpose, 'CREATED', NOW());

        UPDATE t_classroom_time_slot
           SET slot_status = 'RESERVED'
         WHERE slot_id = p_slot_id;

        SET p_result = 1;
        COMMIT;
    ELSE
        SET p_result = 0;
        ROLLBACK;
    END IF;
END$$
DELIMITER ;

-- 2) 取消预订：把预订置为已取消，并释放对应时间段
--    p_result: 1=取消成功, 0=预订不存在或非可取消状态, -1=异常已回滚
DROP PROCEDURE IF EXISTS sp_cancel_reservation;
DELIMITER $$
CREATE PROCEDURE sp_cancel_reservation(
    IN  p_reservation_id VARCHAR(32),
    OUT p_result         INT
)
BEGIN
    DECLARE v_slot_id            VARCHAR(32);
    DECLARE v_reservation_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -1;
    END;

    START TRANSACTION;

    SELECT slot_id, reservation_status
      INTO v_slot_id, v_reservation_status
      FROM t_reservation
     WHERE reservation_id = p_reservation_id
     FOR UPDATE;

    IF v_reservation_status = 'CREATED' THEN
        UPDATE t_reservation
           SET reservation_status = 'CANCELLED'
         WHERE reservation_id = p_reservation_id;

        UPDATE t_classroom_time_slot
           SET slot_status = 'FREE'
         WHERE slot_id = v_slot_id;

        SET p_result = 1;
        COMMIT;
    ELSE
        SET p_result = 0;
        ROLLBACK;
    END IF;
END$$
DELIMITER ;

-- 3) 按日期查询空闲教室（演示带查询结果集的存储过程）
DROP PROCEDURE IF EXISTS sp_query_available_classroom;
DELIMITER $$
CREATE PROCEDURE sp_query_available_classroom(
    IN p_use_date DATE
)
BEGIN
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
    FROM t_classroom c
    JOIN t_classroom_time_slot ts ON c.classroom_id = ts.classroom_id
    WHERE c.classroom_status = 'AVAILABLE'
      AND ts.slot_status = 'FREE'
      AND ts.use_date = p_use_date
    ORDER BY c.classroom_id, ts.start_section;
END$$
DELIMITER ;
