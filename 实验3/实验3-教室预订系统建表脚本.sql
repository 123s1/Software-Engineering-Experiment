-- ============================================================
-- 教室预订系统 数据库建表脚本
-- 实验3：持久化设计（多表继承方案）
-- ============================================================

-- ------------------------------------------------------------
-- 1. 用户主表 (t_user)
-- 说明：存放所有用户的公共属性（父表）
-- ------------------------------------------------------------
CREATE TABLE t_user (
    user_id         VARCHAR(32)     NOT NULL,
    account         VARCHAR(50)     NOT NULL,
    user_name       VARCHAR(50)     NOT NULL,
    password        VARCHAR(128)    NOT NULL,
    contact_info    VARCHAR(100)    NULL,
    user_status     VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uk_user_account UNIQUE (account)
);

CREATE INDEX idx_user_status ON t_user (user_status);

-- ------------------------------------------------------------
-- 2. 管理员子表 (t_administrator)
-- 说明：继承自 t_user，通过外键关联
-- ------------------------------------------------------------
CREATE TABLE t_administrator (
    admin_id        VARCHAR(32)     NOT NULL,
    user_id         VARCHAR(32)     NOT NULL,
    CONSTRAINT pk_administrator PRIMARY KEY (admin_id),
    CONSTRAINT fk_admin_user FOREIGN KEY (user_id)
        REFERENCES t_user (user_id)
);

CREATE INDEX idx_admin_user ON t_administrator (user_id);

-- ------------------------------------------------------------
-- 3. 师生用户子表 (t_teacher_student)
-- 说明：继承自 t_user，通过外键关联，含师生独有属性
-- ------------------------------------------------------------
CREATE TABLE t_teacher_student (
    ts_id           VARCHAR(32)     NOT NULL,
    user_id         VARCHAR(32)     NOT NULL,
    identity_type   VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_teacher_student PRIMARY KEY (ts_id),
    CONSTRAINT fk_ts_user FOREIGN KEY (user_id)
        REFERENCES t_user (user_id)
);

CREATE INDEX idx_ts_user ON t_teacher_student (user_id);
CREATE INDEX idx_ts_identity_type ON t_teacher_student (identity_type);

-- ------------------------------------------------------------
-- 4. 教室表 (t_classroom)
-- ------------------------------------------------------------
CREATE TABLE t_classroom (
    classroom_id        VARCHAR(32)     NOT NULL,
    classroom_name      VARCHAR(50)     NOT NULL,
    location            VARCHAR(100)    NOT NULL,
    capacity            INT             NOT NULL,
    equipment_info      VARCHAR(200)    NULL,
    classroom_status    VARCHAR(20)     NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT pk_classroom PRIMARY KEY (classroom_id)
);

CREATE INDEX idx_classroom_status ON t_classroom (classroom_status);

-- ------------------------------------------------------------
-- 5. 教室可用时间段表 (t_classroom_time_slot)
-- 外键：classroom_id → t_classroom
-- ------------------------------------------------------------
CREATE TABLE t_classroom_time_slot (
    slot_id         VARCHAR(32)     NOT NULL,
    classroom_id    VARCHAR(32)     NOT NULL,
    use_date        DATE            NOT NULL,
    start_section   INT             NOT NULL,
    end_section     INT             NOT NULL,
    slot_status     VARCHAR(20)     NOT NULL DEFAULT 'FREE',
    CONSTRAINT pk_time_slot PRIMARY KEY (slot_id),
    CONSTRAINT fk_slot_classroom FOREIGN KEY (classroom_id)
        REFERENCES t_classroom (classroom_id),
    CONSTRAINT ck_section_range CHECK (start_section <= end_section)
);

CREATE INDEX idx_slot_classroom_date ON t_classroom_time_slot (classroom_id, use_date);
CREATE INDEX idx_slot_status ON t_classroom_time_slot (slot_status);

-- ------------------------------------------------------------
-- 6. 预订记录表 (t_reservation)
-- 核心作用：拆分 师生用户 与 教室 的 N:M 预订关系
--   t_teacher_student (1) → (0..*) t_reservation (0..*) → (1) t_classroom
-- 外键：ts_id → t_teacher_student, classroom_id → t_classroom, slot_id → t_classroom_time_slot
-- ------------------------------------------------------------
CREATE TABLE t_reservation (
    reservation_id      VARCHAR(32)     NOT NULL,
    ts_id               VARCHAR(32)     NOT NULL,
    classroom_id        VARCHAR(32)     NOT NULL,
    slot_id             VARCHAR(32)     NOT NULL,
    purpose             VARCHAR(200)    NULL,
    reservation_status  VARCHAR(20)     NOT NULL DEFAULT 'CREATED',
    create_time         DATETIME        NOT NULL,
    CONSTRAINT pk_reservation PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_ts FOREIGN KEY (ts_id)
        REFERENCES t_teacher_student (ts_id),
    CONSTRAINT fk_reservation_classroom FOREIGN KEY (classroom_id)
        REFERENCES t_classroom (classroom_id),
    CONSTRAINT fk_reservation_slot FOREIGN KEY (slot_id)
        REFERENCES t_classroom_time_slot (slot_id)
);

CREATE INDEX idx_reservation_ts ON t_reservation (ts_id);
CREATE INDEX idx_reservation_classroom_slot ON t_reservation (classroom_id, slot_id);
CREATE INDEX idx_reservation_status ON t_reservation (reservation_status);
CREATE INDEX idx_reservation_create_time ON t_reservation (create_time);

-- ------------------------------------------------------------
-- 7. 教室管理记录表 (t_classroom_mgmt_record)
-- 核心作用：拆分 管理员 与 教室 的 N:M 管理关系
--   t_administrator (1) → (0..*) t_classroom_mgmt_record (0..*) → (1) t_classroom
-- 外键：admin_id → t_administrator, classroom_id → t_classroom
-- ------------------------------------------------------------
CREATE TABLE t_classroom_mgmt_record (
    record_id       VARCHAR(32)     NOT NULL,
    admin_id        VARCHAR(32)     NOT NULL,
    classroom_id    VARCHAR(32)     NOT NULL,
    operation_type  VARCHAR(20)     NOT NULL,
    operation_time  DATETIME        NOT NULL,
    remarks         VARCHAR(500)    NULL,
    CONSTRAINT pk_classroom_mgmt PRIMARY KEY (record_id),
    CONSTRAINT fk_classroom_mgmt_admin FOREIGN KEY (admin_id)
        REFERENCES t_administrator (admin_id),
    CONSTRAINT fk_classroom_mgmt_classroom FOREIGN KEY (classroom_id)
        REFERENCES t_classroom (classroom_id)
);

CREATE INDEX idx_classroom_mgmt_admin ON t_classroom_mgmt_record (admin_id);
CREATE INDEX idx_classroom_mgmt_classroom ON t_classroom_mgmt_record (classroom_id);
CREATE INDEX idx_classroom_mgmt_time ON t_classroom_mgmt_record (operation_time);

-- ------------------------------------------------------------
-- 8. 用户管理记录表 (t_user_mgmt_record)
-- 核心作用：拆分 管理员 与 师生用户 的 N:M 管理关系
--   t_administrator (1) → (0..*) t_user_mgmt_record (0..*) → (1) t_teacher_student
-- 外键：admin_id → t_administrator, target_ts_id → t_teacher_student
-- ------------------------------------------------------------
CREATE TABLE t_user_mgmt_record (
    record_id       VARCHAR(32)     NOT NULL,
    admin_id        VARCHAR(32)     NOT NULL,
    target_ts_id    VARCHAR(32)     NOT NULL,
    operation_type  VARCHAR(20)     NOT NULL,
    operation_time  DATETIME        NOT NULL,
    remarks         VARCHAR(500)    NULL,
    CONSTRAINT pk_user_mgmt PRIMARY KEY (record_id),
    CONSTRAINT fk_user_mgmt_admin FOREIGN KEY (admin_id)
        REFERENCES t_administrator (admin_id),
    CONSTRAINT fk_user_mgmt_target FOREIGN KEY (target_ts_id)
        REFERENCES t_teacher_student (ts_id)
);

CREATE INDEX idx_user_mgmt_admin ON t_user_mgmt_record (admin_id);
CREATE INDEX idx_user_mgmt_target ON t_user_mgmt_record (target_ts_id);
CREATE INDEX idx_user_mgmt_time ON t_user_mgmt_record (operation_time);

-- ============================================================
-- 视图
-- ============================================================

-- 空闲教室查询视图
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
INNER JOIN t_classroom_time_slot ts ON c.classroom_id = ts.classroom_id
WHERE c.classroom_status = 'AVAILABLE'
  AND ts.slot_status = 'FREE';

-- 预订情况查询视图
CREATE VIEW v_reservation_detail AS
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
FROM t_reservation r
INNER JOIN t_teacher_student t ON r.ts_id = t.ts_id
INNER JOIN t_user u ON t.user_id = u.user_id
INNER JOIN t_classroom c ON r.classroom_id = c.classroom_id
INNER JOIN t_classroom_time_slot ts ON r.slot_id = ts.slot_id;
