-- ============================================================
-- 教室预订系统 数据库建表脚本
-- 实验3：持久化设计
-- ============================================================

-- ------------------------------------------------------------
-- 1. 用户表 (t_user)
-- 说明：采用单表继承策略，用 role 字段区分管理员和师生
-- ------------------------------------------------------------
CREATE TABLE t_user (
    user_id         VARCHAR(32)     NOT NULL,
    account         VARCHAR(50)     NOT NULL,
    user_name       VARCHAR(50)     NOT NULL,
    password        VARCHAR(128)    NOT NULL,
    role            VARCHAR(20)     NOT NULL,
    identity_type   VARCHAR(20)     NULL,
    contact_info    VARCHAR(100)    NULL,
    user_status     VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uk_user_account UNIQUE (account)
);

CREATE INDEX idx_user_role ON t_user (role);
CREATE INDEX idx_user_status ON t_user (user_status);

-- ------------------------------------------------------------
-- 2. 教室表 (t_classroom)
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
-- 3. 教室可用时间段表 (t_classroom_time_slot)
-- 说明：时间粒度精确到"课时"，用 start_section 和 end_section 表示
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
-- 4. 预订记录表 (t_reservation)
-- 核心作用：拆分 师生用户 与 教室 的 N:M 预订关系
--   t_user (1) → (0..*) t_reservation (0..*) → (1) t_classroom
-- 外键：user_id → t_user, classroom_id → t_classroom, slot_id → t_classroom_time_slot
-- ------------------------------------------------------------
CREATE TABLE t_reservation (
    reservation_id      VARCHAR(32)     NOT NULL,
    user_id             VARCHAR(32)     NOT NULL,
    classroom_id        VARCHAR(32)     NOT NULL,
    slot_id             VARCHAR(32)     NOT NULL,
    purpose             VARCHAR(200)    NULL,
    reservation_status  VARCHAR(20)     NOT NULL DEFAULT 'CREATED',
    create_time         DATETIME        NOT NULL,
    CONSTRAINT pk_reservation PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_user FOREIGN KEY (user_id)
        REFERENCES t_user (user_id),
    CONSTRAINT fk_reservation_classroom FOREIGN KEY (classroom_id)
        REFERENCES t_classroom (classroom_id),
    CONSTRAINT fk_reservation_slot FOREIGN KEY (slot_id)
        REFERENCES t_classroom_time_slot (slot_id)
);

CREATE INDEX idx_reservation_user ON t_reservation (user_id);
CREATE INDEX idx_reservation_classroom_slot ON t_reservation (classroom_id, slot_id);
CREATE INDEX idx_reservation_status ON t_reservation (reservation_status);
CREATE INDEX idx_reservation_create_time ON t_reservation (create_time);

-- ------------------------------------------------------------
-- 5. 教室管理记录表 (t_classroom_mgmt_record)
-- 核心作用：拆分 管理员 与 教室 的 N:M 管理关系
--   t_user[管理员] (1) → (0..*) t_classroom_mgmt_record (0..*) → (1) t_classroom
-- 外键：operator_id → t_user, classroom_id → t_classroom
-- ------------------------------------------------------------
CREATE TABLE t_classroom_mgmt_record (
    record_id       VARCHAR(32)     NOT NULL,
    operator_id     VARCHAR(32)     NOT NULL,
    classroom_id    VARCHAR(32)     NOT NULL,
    operation_type  VARCHAR(20)     NOT NULL,
    operation_time  DATETIME        NOT NULL,
    remarks         VARCHAR(500)    NULL,
    CONSTRAINT pk_classroom_mgmt PRIMARY KEY (record_id),
    CONSTRAINT fk_classroom_mgmt_operator FOREIGN KEY (operator_id)
        REFERENCES t_user (user_id),
    CONSTRAINT fk_classroom_mgmt_classroom FOREIGN KEY (classroom_id)
        REFERENCES t_classroom (classroom_id)
);

CREATE INDEX idx_classroom_mgmt_operator ON t_classroom_mgmt_record (operator_id);
CREATE INDEX idx_classroom_mgmt_classroom ON t_classroom_mgmt_record (classroom_id);
CREATE INDEX idx_classroom_mgmt_time ON t_classroom_mgmt_record (operation_time);

-- ------------------------------------------------------------
-- 6. 用户管理记录表 (t_user_mgmt_record)
-- 核心作用：拆分 管理员 与 师生用户 的 N:M 管理关系
--   t_user[管理员] (1) → (0..*) t_user_mgmt_record (0..*) → (1) t_user[目标用户]
-- 外键：operator_id → t_user, target_user_id → t_user
-- ------------------------------------------------------------
CREATE TABLE t_user_mgmt_record (
    record_id       VARCHAR(32)     NOT NULL,
    operator_id     VARCHAR(32)     NOT NULL,
    target_user_id  VARCHAR(32)     NOT NULL,
    operation_type  VARCHAR(20)     NOT NULL,
    operation_time  DATETIME        NOT NULL,
    remarks         VARCHAR(500)    NULL,
    CONSTRAINT pk_user_mgmt PRIMARY KEY (record_id),
    CONSTRAINT fk_user_mgmt_operator FOREIGN KEY (operator_id)
        REFERENCES t_user (user_id),
    CONSTRAINT fk_user_mgmt_target FOREIGN KEY (target_user_id)
        REFERENCES t_user (user_id)
);

CREATE INDEX idx_user_mgmt_operator ON t_user_mgmt_record (operator_id);
CREATE INDEX idx_user_mgmt_target ON t_user_mgmt_record (target_user_id);
CREATE INDEX idx_user_mgmt_time ON t_user_mgmt_record (operation_time);
